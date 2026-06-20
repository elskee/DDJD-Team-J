extends MeshInstance3D

enum State { OFF, SAFE, CORRUPTED }

var state: State = State.OFF
var corruption_progress: float = 0.0
var corrupted_duration: float = 0.0
var flickering: bool = false
var flicker_cycle: float = 0.0
var flicker_length = 0.5
var off_time: float = 0.0
var actionChance = 1

@export var corrupt_after: float = 8.0
@export var jumpscare_after: float = 5.0
@export var reset_off_time: float = 3.0

@onready var tv_on_sound = $"../TVOn"
@onready var tv_off_sound = $"../TVOff"
@onready var actionTimer = $actionTimer
@onready var jumpscareTimer = $jumpscareTimer
@onready var TV_enemy_model = $TV_enemy_model

var safe_mat = preload("res://assets/materials/safeTV.tres")
var danger_mat = preload("res://assets/materials/dangerTV.tres")

signal turned_on()
signal turned_off()
signal became_corrupted()
signal jumpscared()

func _ready():
	material_override = null
	visible = false 
	TV_enemy_model.visible = false
	actionTimer.start()
	jumpscareTimer.stop()
	set_difficulty()

func _process(delta):
	if GameManager.is_dead:
		return   
	if state == State.CORRUPTED:
		flicker_cycle += delta
		if flicker_cycle >= flicker_length:
			flicker_length = randf() * 0.5
			flicker_cycle = 0.0
			flickering = not flickering
			material_override = danger_mat if flickering else safe_mat

func set_difficulty(difficulty = 1.0):
	actionTimer.wait_time = 15.0 - (difficulty * 0.5) #15 -> 5
	actionTimer.start()
	jumpscareTimer.wait_time = 10 - (difficulty * 0.25) # 10 -> 5
	actionChance = 0.5 + difficulty/40.0 #50% -> 100%

func compute_action() -> void:
	var x = randf_range(0,1)
	if x <= actionChance:
		enter_corrupted()
		
func turn_on():
	if state == State.OFF:
		state = State.SAFE
		corruption_progress = 0.0
		visible = true
		material_override = safe_mat
		tv_on_sound.playing = true
		turned_on.emit()
		actionTimer.start()

func turn_off():
	state = State.OFF
	visible = false
	material_override = null
	corruption_progress = 0.0
	corrupted_duration = 0.0
	flickering = false
	turned_off.emit()
	tv_off_sound.playing = true
	actionTimer.stop()
	jumpscareTimer.stop()

func enter_corrupted():
	state = State.CORRUPTED
	corrupted_duration = 0.0
	flicker_cycle = 0.0
	flickering = true
	material_override = danger_mat
	off_time = 0.0
	became_corrupted.emit()
	actionTimer.stop()
	jumpscareTimer.start()
	flicker_length = randf() * 0.1

func jumpscare() -> void:
	TV_enemy_model.visible = true
	jumpscared.emit()

func is_on() -> bool:
	return state != State.OFF

func is_safe() -> bool:
	return state == State.SAFE
	
	
