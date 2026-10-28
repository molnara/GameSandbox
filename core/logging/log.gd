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

	message_logged.emit(
		level,
		normalized_category,
		message,
		timestamp
	)
