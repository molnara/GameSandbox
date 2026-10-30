extends "res://tests/framework/test_suite.gd"

const Fixture = preload("res://tests/framework/report_fixture.gd")
const Suite = preload("res://tests/framework/test_suite.gd")


func _init() -> void:
	suite_name = "Framework Unit Tests"
	register_test(test_case_reporting)
	register_test(test_empty_suite)


func test_case_reporting() -> void:
	var fixture := Fixture.new()
	var cases: Array[Dictionary] = fixture.run()
	assertions.equal(cases.size(), 2, "Two cases reported")
	assertions.check(cases[0].suite == "Framework Fixture" and cases[0].name == "first_case" and cases[1].name == "second_case", "Suite and case attribution")
	assertions.check(cases[0].assertions_passed == 1 and cases[0].assertions_failed == 1 and cases[1].assertions_passed == 1 and cases[1].assertions_failed == 0, "Assertions attributed to each case")
	assertions.check(cases[0].failures.size() == 1 and cases[0].failures[0].contains("fixture failure") and cases[0].failures[0].contains("expected: 2"), "Failure details retained")
	assertions.check(cases[0].duration_ms >= 0 and cases[1].duration_ms >= 0 and fixture.assertions.passed == 2 and fixture.assertions.failed == 1, "Durations and aggregate counts")


func test_empty_suite() -> void:
	var empty := Suite.new()
	assertions.check(empty.run().is_empty(), "Empty suite reports zero cases")
