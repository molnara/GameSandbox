
extends SceneTree

const LoggerScript = preload("res://core/logging/log.gd")

var logger: Node
var captured_messages: Array[Dictionary] = []

var passed: int = 0
var failed: int = 0


func _initialize() -> void:
	print("\nRunning Logger Unit Tests...\n")

	logger = LoggerScript.new()

	logger.message_logged.connect(_capture_message)

	_run_tests()

	print("\nResults: %d passed, %d failed" % [
		passed,
		failed
	])

	logger.free()

	if failed > 0:
		quit(1)
	else:
		quit(0)


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


func _reset() -> void:
	captured_messages.clear()
	logger.set_level(logger.Level.DEBUG)


func _check(
	condition: bool,
	description: String
) -> void:
	if condition:
		passed += 1
		print("PASS  ", description)
	else:
		failed += 1
		printerr("FAIL  ", description)


func _run_tests() -> void:
	test_default_level()
	test_set_level()
	test_suppress_below_minimum()
	test_emit_at_minimum()
	test_emit_above_minimum()
	test_normalize_category()
	test_preserve_message()
	test_off_suppresses_all()
	test_trace_severity()
	test_debug_severity()
	test_info_severity()
	test_warn_severity()
	test_error_severity()
	test_default_category()
	test_timestamp_format()
	test_multiple_messages()


func test_default_level() -> void:
	_reset()

	var valid: bool = logger.minimum_level == logger.Level.DEBUG
	
	_check(
		valid,
        "Default log level"
	)


func test_set_level() -> void:
	_reset()

	logger.set_level(logger.Level.WARN)

	var valid: bool = logger.minimum_level == logger.Level.WARN
	
	_check(
		valid,
        "Set minimum log level"
	)


func test_suppress_below_minimum() -> void:
	_reset()

	logger.set_level(logger.Level.WARN)
	logger.info("Should be hidden", "TEST")
	
	var valid: bool = captured_messages.is_empty()

	_check(
		valid,
        "Suppress messages below minimum"
	)


func test_emit_at_minimum() -> void:
	_reset()

	logger.set_level(logger.Level.WARN)
	logger.warn("Warning", "TEST")
	
	var valid: bool = captured_messages.size() == 1

	_check(
		valid,
        "Emit messages at minimum"
	)


func test_emit_above_minimum() -> void:
	_reset()

	logger.set_level(logger.Level.WARN)
	logger.error("Error", "TEST")
	
	var valid: bool = captured_messages.size() == 1

	_check(
		valid,
        "Emit messages above minimum"
	)


func test_normalize_category() -> void:
	_reset()

	logger.info("Message", "player")
	
	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["category"] == "PLAYER"
	)

	_check(
		valid, 
		"Normalize category"
		)


func test_preserve_message() -> void:
	_reset()

	logger.info("Hello GameSandbox", "TEST")
	
	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["message"] == "Hello GameSandbox"
	)

	_check(
		valid, 
		"Preserve message content"
		)


func test_off_suppresses_all() -> void:
	_reset()

	logger.set_level(logger.Level.OFF)
	logger.error("Should be hidden", "TEST")
	
	var valid: bool = captured_messages.is_empty()

	_check(
		valid,
        "Suppress all messages when OFF"
	)


func test_trace_severity() -> void:
	_reset()

	logger.set_level(logger.Level.TRACE)
	logger.trace("Trace message", "TEST")

	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["level"] == logger.Level.TRACE
	)

	_check(valid, "TRACE severity")


func test_debug_severity() -> void:
	_reset()

	logger.debug("Debug message", "TEST")

	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["level"] == logger.Level.DEBUG
	)

	_check(valid, "DEBUG severity")


func test_info_severity() -> void:
	_reset()

	logger.info("Info message", "TEST")

	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["level"] == logger.Level.INFO
	)

	_check(valid, "INFO severity")


func test_warn_severity() -> void:
	_reset()

	logger.warn("Warning message", "TEST")

	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["level"] == logger.Level.WARN
	)

	_check(valid, "WARN severity")


func test_error_severity() -> void:
	_reset()

	logger.error("Error message", "TEST")

	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["level"] == logger.Level.ERROR
	)

	_check(valid, "ERROR severity")


func test_default_category() -> void:
	_reset()

	logger.info("No category specified")

	var valid: bool = (
		captured_messages.size() == 1
		and captured_messages[0]["category"] == "GENERAL"
	)

	_check(valid, "Default category")


func test_timestamp_format() -> void:
	_reset()

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

	_check(valid, "Timestamp format HH:MM:SS")

func test_multiple_messages() -> void:
	_reset()

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

	_check(valid, "Multiple messages preserve order")
