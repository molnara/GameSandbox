extends RefCounted

const Assertions = preload("res://tests/framework/test_assertions.gd")

var assertions = Assertions.new()
var suite_name: String = "Unnamed Suite"
var _tests: Array[Callable] = []


func register_test(test: Callable) -> void:
	_tests.append(test)


func setup_suite() -> void:
	pass


func teardown_suite() -> void:
	pass


func setup_test() -> void:
	pass


func teardown_test() -> void:
	pass


func run() -> Array[Dictionary]:
	print("\nRunning %s..." % suite_name)
	var cases: Array[Dictionary] = []
	setup_suite()
	for test: Callable in _tests:
		var start: int = Time.get_ticks_usec()
		var passed_before: int = assertions.passed
		var failed_before: int = assertions.failed
		var failures_before: int = assertions.failures.size()
		setup_test()
		test.call()
		teardown_test()
		cases.append({
			"suite": suite_name,
			"name": str(test.get_method()),
			"duration_ms": (Time.get_ticks_usec() - start) / 1000.0,
			"assertions_passed": assertions.passed - passed_before,
			"assertions_failed": assertions.failed - failed_before,
			"failures": assertions.failures.slice(failures_before),
		})
	teardown_suite()
	return cases
