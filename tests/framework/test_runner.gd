extends SceneTree

const FrameworkTests = preload("res://tests/unit/test_framework.gd")
const LoggerTests = preload("res://tests/unit/test_logger.gd")

var suites: Array[RefCounted] = []


func _initialize() -> void:
	print("\n=== GameSandbox Unit Tests ===")
	suites.append(LoggerTests.new())
	suites.append(FrameworkTests.new())
	var cases: Array[Dictionary] = []
	var total_passed: int = 0
	var total_failed: int = 0
	var start: int = Time.get_ticks_usec()
	for suite: RefCounted in suites:
		cases.append_array(suite.run())
		total_passed += suite.assertions.passed
		total_failed += suite.assertions.failed
	var report: Dictionary = {
		"version": 1,
		"user_data_dir": ProjectSettings.globalize_path("user://"),
		"duration_ms": (Time.get_ticks_usec() - start) / 1000.0,
		"case_count": cases.size(),
		"assertions_passed": total_passed,
		"assertions_failed": total_failed,
		"cases": cases,
	}
	print("\n=== Test Results ===\nCases: %d\nPassed: %d\nFailed: %d" % [cases.size(), total_passed, total_failed])
	var report_path: String = OS.get_environment("GAMESANDBOX_TEST_REPORT")
	if not report_path.is_empty():
		var file := FileAccess.open(report_path, FileAccess.WRITE)
		if file == null:
			printerr("Cannot write test report: ", report_path)
			quit(1)
			return
		file.store_string(JSON.stringify(report, "\t"))
		file.close()
	quit(1 if total_failed > 0 or cases.is_empty() else 0)

