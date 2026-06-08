extends Node3D

enum State { HIDDEN, PRESENT }

var current_state: State = State.HIDDEN
var time_present: float = 0.0
var appear_timer: float = 0.0
var next_appear_time: float = 0.0
var blocked: bool = false
var actionChance = 1

@export var appear_delay_min: float = 2.0
@export var appear_delay_max: float = 5.0
@export var jumpscare_after: float = 218.0

@onready var actionTimer = $actionTimer
@onready var jumpscareTimer = $jumpscareTimer

signal appeared()
signal left()
signal jumpscared()

func _ready():
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "Mesh"
	visible = false
	randomize_appear_time()

func _process(delta):
	if GameManager.is_dead:
		return

	if current_state == State.HIDDEN and not blocked:
		appear_timer += delta
		if appear_timer >= next_appear_time:
			try_appear()
		return
	
	if GameManager.flashlight_on:
		leave()

	time_present += delta
	if time_present >= jumpscare_after:
		jumpscared.emit()

func set_difficulty(difficulty = 1.0):
	actionTimer.wait_time = 15.0 - (difficulty * 0.5) #15 -> 5
	actionChance = 0.5 + difficulty/40.0 #50% -> 100%
	jumpscareTimer.wait_time = 5.0 - difficulty * (3.0/20.0) #5 -> 2

func randomize_appear_time():
	appear_timer = 0.0
	next_appear_time = randf_range(appear_delay_min, appear_delay_max)

func try_appear():
	if current_state == State.HIDDEN and not GameManager.is_dead:
		appear()

func appear():
	current_state = State.PRESENT
	time_present = 0.0
	visible = true
	appeared.emit()

func leave():
	current_state = State.HIDDEN
	visible = false
	randomize_appear_time()

func force_leave():
	if current_state == State.PRESENT:
		leave()

func is_present() -> bool:
	return current_state == State.PRESENT
