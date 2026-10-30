extends RefCounted

var passed: int = 0
var failed: int = 0
var failures: Array[String] = []


func check(condition: bool, description: String) -> void:
	if condition:
		passed += 1
		print("PASS  ", description)
	else:
		failed += 1
		failures.append(description)
		printerr("FAIL  ", description)


func equal(actual: Variant, expected: Variant, description: String) -> void:
	if actual != expected:
		check(false, "%s (expected: %s; actual: %s)" % [description, str(expected), str(actual)])
	else:
		check(true, description)


func is_true(condition: bool, description: String) -> void:
	check(condition, description)


func is_false(condition: bool, description: String) -> void:
	check(not condition, description)
