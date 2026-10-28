
extends RefCounted

var passed: int = 0
var failed: int = 0


func check(condition: bool, description: String) -> void:
	if condition:
		passed += 1
		print("PASS  ", description)
	else:
		failed += 1
		printerr("FAIL  ", description)


func equal(
	actual: Variant,
	expected: Variant,
	description: String
) -> void:
	var condition: bool = actual == expected

	if not condition:
		printerr(
			"  Expected: %s | Actual: %s" % [
				str(expected),
				str(actual)
			]
		)

	check(condition, description)


func is_true(condition: bool, description: String) -> void:
	check(condition, description)


func is_false(condition: bool, description: String) -> void:
	check(not condition, description)
