extends Node3D

enum State { HIDDEN, PRESENT }

var current_state: State = State.HIDDEN
var time_present: float = 0.0
var appear_timer: float = 0.0
var next_appear_time: float = 0.0
var blocked: bool = false
var actionChance = 1

@onready var actionTimer = $actionTimer
@onready var jumpscareTimer = $jumpscareTimer

signal appeared()
signal left()
signal jumpscared()

func _ready():
	visible = false
	set_difficulty()

func _process(delta):
	if GameManager.is_dead:
		return
	
	if GameManager.flashlight_on:
		leave()

func set_difficulty(difficulty = 1.0):
	actionTimer.wait_time = 5.0 - (difficulty * 0.5) #15 -> 5
	actionChance = 0.5 + difficulty/40.0 #50% -> 100%
	jumpscareTimer.wait_time = 5.0 - difficulty * (3.0/20.0) #5 -> 2

func appear():
	if current_state == State.PRESENT or GameManager.is_dead:
		return
	current_state = State.PRESENT
	jumpscareTimer.start()
	visible = true
	actionTimer.stop()
	appeared.emit()

func leave():
	if current_state == State.PRESENT:
		return
	current_state = State.HIDDEN
	visible = false
	left.emit()
	actionTimer.start()
	jumpscareTimer.stop()

func is_present() -> bool:
	return current_state == State.PRESENT

func compute_action() -> void:
	var x = randf_range(0,1)
	if x <= actionChance:
		appear()
		

func jumpscare() -> void:
	if GameManager.is_dead or current_state == State.HIDDEN or blocked:
		return
	jumpscared.emit()
