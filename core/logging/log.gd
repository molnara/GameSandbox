extends Node

## Global logging service.
## Usage: Log.info("Game started", "CORE")

signal message_logged(
	level: int,
	category: String,
	message: String,
	timestamp: String
)

enum Level {
	TRACE,
	DEBUG,
	INFO,
	WARN,
	ERROR,
	OFF
}

const LEVEL_NAMES := [
	"TRACE",
	"DEBUG",
	"INFO",
	"WARN",
	"ERROR",
    "OFF"
]

var minimum_level: Level = Level.DEBUG
var _log_file: FileAccess


func enable_file_logging(path: String) -> Error:
	disable_file_logging()
	var mode := FileAccess.READ_WRITE if FileAccess.file_exists(path) else FileAccess.WRITE_READ
	_log_file = FileAccess.open(path, mode)
	if _log_file == null:
		return FileAccess.get_open_error()
	_log_file.seek_end()
	return OK


func disable_file_logging() -> void:
	if _log_file != null:
		_log_file.close()
		_log_file = null


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		disable_file_logging()


func trace(message: String, category: String = "GENERAL") -> void:
	_write(Level.TRACE, message, category)


func debug(message: String, category: String = "GENERAL") -> void:
	_write(Level.DEBUG, message, category)


func info(message: String, category: String = "GENERAL") -> void:
	_write(Level.INFO, message, category)


func warn(message: String, category: String = "GENERAL") -> void:
	_write(Level.WARN, message, category)


func error(message: String, category: String = "GENERAL") -> void:
	_write(Level.ERROR, message, category)


func set_level(level: Level) -> void:
	minimum_level = level


func _write(
	level: Level,
	message: String,
	category: String
) -> void:
	if level < minimum_level or level == Level.OFF:
		return

	var timestamp := Time.get_time_string_from_system()
	var level_name: String = LEVEL_NAMES[level]
	var normalized_category := category.to_upper()

	var formatted := "[%s] [%-5s] [%s] %s" % [
		timestamp,
		level_name,
		normalized_category,
		message
	]

	print(formatted)
	if _log_file != null:
		_log_file.store_line(formatted)
		_log_file.flush()
		var file_error := _log_file.get_error()
		if file_error != OK:
			printerr("Log file write failed: ", file_error)
			disable_file_logging()

	message_logged.emit(
		level,
		normalized_category,
		message,
		timestamp
	)
