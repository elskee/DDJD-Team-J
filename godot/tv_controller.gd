extends MeshInstance3D

enum State { OFF, SAFE, CORRUPTED }

var state: State = State.OFF
var corruption_progress: float = 0.0
var corrupted_duration: float = 0.0
var flickering: bool = false
var flicker_cycle: float = 0.0
var off_time: float = 0.0
var can_turn_on: bool = true

@export var corrupt_after: float = 8.0
@export var jumpscare_after: float = 5.0
@export var reset_off_time: float = 3.0

@onready var tv_on_sound = $"../TVOn"
@onready var tv_off_sound = $"../TVOff"

var safe_mat = preload("res://assets/materials/safeTV.tres")
var danger_mat = preload("res://assets/materials/dangerTV.tres")

signal turned_on()
signal turned_off()
signal became_corrupted()
signal jumpscared()

func _ready():
	material_override = null
	visible = false

func _process(delta):
	match state:
		State.SAFE:
			corruption_progress += delta
			if corruption_progress >= corrupt_after:
				enter_corrupted()
		State.CORRUPTED:
			corrupted_duration += delta
			flicker_cycle += delta
			if flicker_cycle >= 0.15:
				flicker_cycle = 0.0
				flickering = not flickering
				material_override = danger_mat if flickering else safe_mat
			if corrupted_duration >= jumpscare_after:
				jumpscared.emit()
		State.OFF:
			if not can_turn_on:
				off_time += delta
				if off_time >= reset_off_time:
					can_turn_on = true

func turn_on():
	if state == State.OFF and can_turn_on:
		state = State.SAFE
		corruption_progress = 0.0
		visible = true
		material_override = safe_mat
		tv_on_sound.playing = true
		turned_on.emit()

func turn_off():
	state = State.OFF
	visible = false
	material_override = null
	corruption_progress = 0.0
	corrupted_duration = 0.0
	flickering = false
	turned_off.emit()
	tv_off_sound.playing = true
	if not can_turn_on:
		off_time = 0.0

func enter_corrupted():
	state = State.CORRUPTED
	corrupted_duration = 0.0
	flicker_cycle = 0.0
	flickering = true
	material_override = danger_mat
	can_turn_on = false
	off_time = 0.0
	became_corrupted.emit()

func is_on() -> bool:
	return state != State.OFF

func is_safe() -> bool:
	return state == State.SAFE
