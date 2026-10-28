
extends SceneTree

const LoggerTests = preload("res://tests/unit/test_logger.gd")

var suites: Array[RefCounted] = []


func _initialize() -> void:
	print("\n=== GameSandbox Unit Tests ===")

	suites.append(LoggerTests.new())

	var total_passed: int = 0
	var total_failed: int = 0

	for suite: RefCounted in suites:
		suite.run()

		total_passed += suite.assertions.passed
		total_failed += suite.assertions.failed

	print("\n=== Test Results ===")
	print("Passed: %d" % total_passed)
	print("Failed: %d" % total_failed)
	print("Total:  %d" % (total_passed + total_failed))

	if total_failed > 0:
		quit(1)
	else:
		quit(0)
