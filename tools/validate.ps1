[CmdletBinding()]
param(
    [string]$Godot = 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe',
    [ValidateRange(1, 86400)][int]$VersionTimeoutSeconds = 30,
    [ValidateRange(1, 86400)][int]$ImportTimeoutSeconds = 120,
    [ValidateRange(1, 86400)][int]$TestTimeoutSeconds = 120
)
$ErrorActionPreference = 'Stop'
$project = Split-Path -Parent $PSScriptRoot
$artifact = Join-Path $project ('.validation/' + [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss-fff') + '-' + [guid]::NewGuid().ToString('N'))
$stages = [ordered]@{}
$failure = $null
try {
    New-Item -ItemType Directory -Path $artifact -Force | Out-Null
    Write-Host "Validation artifacts: $artifact"
    $userRoot = Join-Path $artifact 'user-data'
    New-Item -ItemType Directory -Path $userRoot -Force | Out-Null
    $probe = Join-Path $userRoot 'write-probe'
    [IO.File]::WriteAllText($probe, 'writable')
    Remove-Item -LiteralPath $probe
    if (-not (Test-Path -LiteralPath $Godot -PathType Leaf)) { throw "Setup: Godot executable not found: $Godot" }
    $reportPath = Join-Path $artifact 'report.json'
    function Invoke-Stage([string]$Name, [string[]]$Arguments, [int]$Timeout) {
        $start = [Diagnostics.Stopwatch]::StartNew()
        $info = [Diagnostics.ProcessStartInfo]::new()
        $info.FileName = $Godot
        $info.UseShellExecute = $false
        $info.RedirectStandardOutput = $true
        $info.RedirectStandardError = $true
        $info.CreateNoWindow = $true
        $info.WorkingDirectory = $project
        $info.Environment['APPDATA'] = $userRoot
        $info.Environment['GAMESANDBOX_TEST_REPORT'] = $reportPath
        foreach ($argument in $Arguments) { [void]$info.ArgumentList.Add($argument) }
        $process = [Diagnostics.Process]::new()
        $process.StartInfo = $info
        try {
            if (-not $process.Start()) { throw "Could not start $Name" }
            $stdout = $process.StandardOutput.ReadToEndAsync()
            $stderr = $process.StandardError.ReadToEndAsync()
            $timedOut = -not $process.WaitForExit($Timeout * 1000)
            if ($timedOut) { $process.Kill($true); $process.WaitForExit() }
            $outText = $stdout.GetAwaiter().GetResult()
            $errText = $stderr.GetAwaiter().GetResult()
            [IO.File]::WriteAllText((Join-Path $artifact "$Name.stdout.txt"), $outText)
            [IO.File]::WriteAllText((Join-Path $artifact "$Name.stderr.txt"), $errText)
            $start.Stop()
            $result = [ordered]@{ duration_ms = $start.ElapsedMilliseconds; exit_code = $process.ExitCode; timed_out = $timedOut }
            $stages[$Name] = $result
            if ($timedOut) { throw "$Name timed out after $Timeout seconds" }
            if ($process.ExitCode -ne 0) { throw "$Name exited with code $($process.ExitCode)" }
            $logPath = Join-Path $artifact "$Name.godot.log"
            $logText = if (Test-Path -LiteralPath $logPath) { [IO.File]::ReadAllText($logPath) } else { '' }
            if (($outText + "`n" + $errText + "`n" + $logText) -match '(?m)^\s*(SCRIPT ERROR:|ERROR:|Parse Error:)') { throw "$Name reported an engine or script error; inspect its diagnostics" }
            return $outText
        } finally { $process.Dispose() }
    }
    $version = Invoke-Stage 'version' @('--version') $VersionTimeoutSeconds
    if ([string]::IsNullOrWhiteSpace($version)) { throw 'Version stage returned no version' }
    $stages['version']['version'] = $version.Trim()
    $null = Invoke-Stage 'import' @('--headless', '--path', $project, '--log-file', (Join-Path $artifact 'import.godot.log'), '--import') $ImportTimeoutSeconds
    $null = Invoke-Stage 'test' @('--headless', '--path', $project, '--log-file', (Join-Path $artifact 'test.godot.log'), '--script', 'res://tests/framework/test_runner.gd') $TestTimeoutSeconds
    if (-not (Test-Path -LiteralPath $reportPath -PathType Leaf)) { throw 'Test report is missing' }
    try { $report = Get-Content -LiteralPath $reportPath -Raw | ConvertFrom-Json -ErrorAction Stop } catch { throw 'Test report is malformed JSON' }
    if ($report.version -ne 1 -or $null -eq $report.cases -or $report.case_count -isnot [ValueType] -or $report.assertions_passed -isnot [ValueType] -or $report.assertions_failed -isnot [ValueType] -or $report.duration_ms -isnot [ValueType]) { throw 'Test report has an invalid schema' }
    $cases = @($report.cases)
    if ($report.case_count -le 0 -or $cases.Count -ne $report.case_count) { throw 'Test report has zero cases or an inconsistent case count' }
    $passed = 0; $failed = 0
    foreach ($case in $cases) {
        if ([string]::IsNullOrWhiteSpace($case.suite) -or [string]::IsNullOrWhiteSpace($case.name) -or $case.duration_ms -isnot [ValueType] -or $case.duration_ms -lt 0 -or $case.assertions_passed -isnot [ValueType] -or $case.assertions_failed -isnot [ValueType] -or $case.assertions_passed -lt 0 -or $case.assertions_failed -lt 0 -or $null -eq $case.failures -or @($case.failures).Count -ne $case.assertions_failed) { throw 'Test report contains an invalid case' }
        $passed += $case.assertions_passed; $failed += $case.assertions_failed
    }
    if ($passed -ne $report.assertions_passed -or $failed -ne $report.assertions_failed -or $failed -ne 0) { throw 'Test report contains failed assertions or inconsistent totals' }
    $actualUser = [IO.Path]::GetFullPath($report.user_data_dir).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    $expectedRoot = [IO.Path]::GetFullPath($userRoot).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    if (-not $actualUser.StartsWith($expectedRoot, [StringComparison]::OrdinalIgnoreCase)) { throw "Setup: Godot used an unexpected user data directory: $actualUser" }
    Write-Host "Validation passed: $($report.case_count) cases, $passed assertions."
} catch {
    $failure = $_.Exception.Message
    Write-Error "Validation failed: $failure" -ErrorAction Continue
} finally {
    if (Test-Path -LiteralPath $artifact) {
        [ordered]@{ version = 1; success = ($null -eq $failure); failure = $failure; stages = $stages } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $artifact 'validation.json') -Encoding utf8
    }
}
if ($null -ne $failure) { exit 1 }
