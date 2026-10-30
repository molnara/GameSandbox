extends "res://tests/framework/test_suite.gd"


func _init() -> void:
	suite_name = "Framework Fixture"
	register_test(first_case)
	register_test(second_case)


func first_case() -> void:
	assertions.check(true, "fixture pass")
	assertions.equal(1, 2, "fixture failure")


func second_case() -> void:
	assertions.check(true, "second fixture pass")
