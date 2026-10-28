
extends "res://tests/framework/test_suite.gd"

const LoggerScript = preload("res://core/logging/log.gd")

var logger: Node
var captured_messages: Array[Dictionary] = []


func _init() -> void:
	suite_name = "Logger Unit Tests"

	register_test(test_default_level)
	register_test(test_set_level)
	register_test(test_suppress_below_minimum)
	register_test(test_emit_at_minimum)
	register_test(test_emit_above_minimum)
	register_test(test_normalize_category)
	register_test(test_preserve_message)
	register_test(test_off_suppresses_all)

	register_test(test_trace_severity)
	register_test(test_debug_severity)
	register_test(test_info_severity)
	register_test(test_warn_severity)
	register_test(test_error_severity)
	register_test(test_default_category)
	register_test(test_timestamp_format)
	register_test(test_multiple_messages)

	register_test(test_empty_message)
	register_test(test_empty_category)
	register_test(test_unicode_message)
	register_test(test_special_characters)
	register_test(test_all_severity_boundaries)
	register_test(test_exactly_once_emission)


func setup_suite() -> void:
	logger = LoggerScript.new()
	logger.message_logged.connect(_capture_message)


func teardown_suite() -> void:
	logger.free()


func setup_test() -> void:
	captured_messages.clear()
	logger.set_level(logger.Level.DEBUG)


func _capture_message(
	level: int,
	category: String,
	message: String,
	timestamp: String
) -> void:
	captured_messages.append({
		"level": level,
		"category": category,
		"message": message,
		"timestamp": timestamp
	})



func test_default_level() -> void:

	var fresh_logger: Node = LoggerScript.new()

	assertions.equal(
		fresh_logger.minimum_level,
		fresh_logger.Level.DEBUG,
		"Default log level"
	)

	fresh_logger.free()


func test_set_level() -> void:

	logger.set_level(logger.Level.WARN)

	var valid: bool = logger.minimum_level == logger.Level.WARN
	
	assertions.check(
		valid,
        "Set minimum log level"
	)


func test_suppress_below_minimum() -> void:

	logger.set_level(logger.Level.WARN)
	logger.info("Should be hidden", "TEST")
	
	var valid: bool = captured_messages.is_empty()

	assertions.check(
		valid,
        "Suppress messages below minimum"
	)


func test_emit_at_minimum() -> void:

	logger.set_level(logger.Level.WARN)
	logger.warn("Warning", "TEST")
	
	var valid: bool = captured_messages.size() == 1

	assertions.check(
		valid,
        "Emit messages at minimum"
	)


func test_emit_above_minimum() -> void:

	logger.set_level(logger.Level.WARN)
	logger.error("Error", "TEST")
	
	var valid: bool = captured_messages.size() == 1

	assertions.check(
		valid,
        "Emit messages above minimum"
	)


func test_normalize_category() -> void:

	logger.info("Message", "player")
	
	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["category"] == "PLAYER"
	)

	assertions.check(
		valid, 
		"Normalize category"
		)


func test_preserve_message() -> void:

	logger.info("Hello GameSandbox", "TEST")
	
	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["message"] == "Hello GameSandbox"
	)

	assertions.check(
		valid, 
		"Preserve message content"
		)


func test_off_suppresses_all() -> void:

	logger.set_level(logger.Level.OFF)
	logger.error("Should be hidden", "TEST")
	
	var valid: bool = captured_messages.is_empty()

	assertions.check(
		valid,
        "Suppress all messages when OFF"
	)


func test_trace_severity() -> void:

	logger.set_level(logger.Level.TRACE)
	logger.trace("Trace message", "TEST")

	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["level"] == logger.Level.TRACE
	)

	assertions.check(valid, "TRACE severity")


func test_debug_severity() -> void:

	logger.debug("Debug message", "TEST")

	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["level"] == logger.Level.DEBUG
	)

	assertions.check(valid, "DEBUG severity")


func test_info_severity() -> void:

	logger.info("Info message", "TEST")

	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["level"] == logger.Level.INFO
	)

	assertions.check(valid, "INFO severity")


func test_warn_severity() -> void:

	logger.warn("Warning message", "TEST")

	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["level"] == logger.Level.WARN
	)

	assertions.check(valid, "WARN severity")


func test_error_severity() -> void:

	logger.error("Error message", "TEST")

	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["level"] == logger.Level.ERROR
	)

	assertions.check(valid, "ERROR severity")


func test_default_category() -> void:

	logger.info("No category specified")

	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["category"] == "GENERAL"
	)

	assertions.check(valid, "Default category")


func test_timestamp_format() -> void:

	logger.info("Timestamp test", "TEST")

	var valid: bool = false

	if captured_messages.size() == 1:
		var timestamp: String = captured_messages[0]["timestamp"]
		var parts: PackedStringArray = timestamp.split(":")

		if parts.size() == 3:
			var hour: String = parts[0]
			var minute: String = parts[1]
			var second: String = parts[2]

			valid = (
				hour.length() == 2
				and minute.length() == 2
				and second.length() == 2
				and hour.is_valid_int()
				and minute.is_valid_int()
				and second.is_valid_int()
				and int(hour) >= 0
				and int(hour) <= 23
				and int(minute) >= 0
				and int(minute) <= 59
				and int(second) >= 0
				and int(second) <= 59
			)

	assertions.check(valid, "Timestamp format HH:MM:SS")

func test_multiple_messages() -> void:

	logger.info("First", "TEST")
	logger.warn("Second", "TEST")
	logger.error("Third", "TEST")

	var valid: bool = (
		captured_messages.size() == 3
	)

	if valid:
		valid = (
			captured_messages[0]["message"] == "First"
			and captured_messages[1]["message"] == "Second"
			and captured_messages[2]["message"] == "Third"
		)

	assertions.check(valid, "Multiple messages preserve order")


func test_empty_message() -> void:

	logger.info("", "TEST")

	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["message"] == ""
	)

	assertions.check(valid, "Empty message is preserved")


func test_empty_category() -> void:

	logger.info("Empty category test", "")

	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["category"] == ""
	)

	assertions.check(valid, "Empty category is preserved")


func test_unicode_message() -> void:

	var original: String = "Hello 世界 — Привет 🌍"

	logger.info(original, "LOCALIZATION")

	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["message"] == original
	)

	assertions.check(valid, "Unicode message preserved")


func test_special_characters() -> void:

	var original: String = "Line 1\nLine 2\t\"Quoted\" \\ Path"

	logger.info(original, "TEST")

	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["message"] == original
	)

	assertions.check(valid, "Special characters preserved")


func test_all_severity_boundaries() -> void:
	var levels: Array[int] = [
		logger.Level.TRACE,
		logger.Level.DEBUG,
		logger.Level.INFO,
		logger.Level.WARN,
		logger.Level.ERROR,
		logger.Level.OFF
	]

	var valid: bool = true

	for minimum: int in levels:
		captured_messages.clear()
		logger.set_level(minimum)

		logger.trace("Trace", "TEST")
		logger.debug("Debug", "TEST")
		logger.info("Info", "TEST")
		logger.warn("Warn", "TEST")
		logger.error("Error", "TEST")

		var expected_count: int = 0

		for severity: int in levels:
			if severity == logger.Level.OFF:
				continue

			if severity >= minimum:
				expected_count += 1

		if captured_messages.size() != expected_count:
			valid = false
			printerr(
				"Boundary failure: minimum=%d expected=%d actual=%d" % [
					minimum,
					expected_count,
					captured_messages.size()
				]
			)

	assertions.check(valid, "All severity boundaries")


func test_exactly_once_emission() -> void:

	logger.info("Single message", "TEST")

	var valid: bool = (
		captured_messages.size() == 1
	)

	if valid:
		valid = (
			captured_messages[0]["message"] == "Single message"
			and captured_messages[0]["level"] == logger.Level.INFO
		)

	assertions.check(valid, "Exactly-once signal emission")
