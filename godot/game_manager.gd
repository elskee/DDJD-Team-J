extends Node

signal sleepiness_updated(value, max_value)
signal eyes_changed(closed)
signal flashlight_toggled(on)
signal game_over()

var sleepiness: float = 0.0:
	set(value):
		sleepiness = clampf(value, 0.0, max_sleepiness)
		sleepiness_updated.emit(sleepiness, max_sleepiness)

var max_sleepiness: float = 100.0
var eyes_closed: bool = false:
	set(value):
		if value != eyes_closed:
			eyes_closed = value
			eyes_changed.emit(value)

var flashlight_on: bool = false
var current_level: int = 1
var is_dead: bool = false
var man_active: bool = false

func _ready():
	process_mode = PROCESS_MODE_ALWAYS

func reset():
	sleepiness = 0.0
	is_dead = false
	flashlight_on = false
	eyes_closed = false

func toggle_flashlight():
	if is_dead:
		return
	flashlight_on = not flashlight_on
	flashlight_toggled.emit(flashlight_on)

func die():
	is_dead = true
	game_over.emit()
