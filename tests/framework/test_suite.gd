
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


func run() -> void:
	print("\nRunning %s..." % suite_name)

	setup_suite()

	for test: Callable in _tests:
		setup_test()
		test.call()
		teardown_test()

	teardown_suite()
