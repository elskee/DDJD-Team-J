extends Node3D

enum State { HIDDEN, PRESENT }
var max_suspicion: float = 100.0

var current_state: State = State.HIDDEN
var time_present: float = 0.0
var appear_timer: float = 0.0
var next_appear_time: float = 0.0
var blocked: bool = false
var actionChance = 1
var suspicion: float = 0.0
var turned_off_tv_once = false
var suspicionMultiplier = 1
var initialSuspicion = 1

@onready var actionTimer = $actionTimer
@onready var door_enter_sound = $"../DoorEnter"
@onready var door_exit_sound = $"../DoorExit"
@onready var manJumpscare = $"manJumpscare"

signal appeared()
signal left()
signal jumpscared()
signal turned_off_tv()

func _ready():
	visible = false
	set_difficulty()
	actionTimer.start()
	manJumpscare.visible = false

func _process(delta):
	if GameManager.is_dead:
		return                     
	if GameManager.eyes_closed:
		suspicion = maxf(suspicion - 25.0 * delta * (1.0/suspicionMultiplier), 0.0)
	else:
		suspicion = minf(suspicion + 15.0 * delta * suspicionMultiplier, max_suspicion)
	
	if GameManager.flashlight_on:
		suspicion = minf(suspicion + 25.0 * delta * suspicionMultiplier, max_suspicion)
	
	if suspicion >= max_suspicion:
		jumpscare()

	if suspicion <= 0.0:
		leave()

	if not turned_off_tv_once and current_state == State.PRESENT:
		turned_off_tv_once = true
		turned_off_tv.emit()

func set_difficulty(difficulty = 1.0):
	initialSuspicion = 0.3 * (1.0+difficulty/20)
	actionTimer.wait_time = 15.0 - (difficulty * 0.5) #15 -> 5
	actionTimer.start()
	actionChance = 0.5 + difficulty/40.0 #50% -> 100%
	suspicionMultiplier = 1.0+difficulty/20 #1->2

func appear():
	if current_state == State.PRESENT or GameManager.is_dead:
		return
	suspicion = max_suspicion * initialSuspicion
	current_state = State.PRESENT
	visible = true
	door_enter_sound.playing = true
	GameManager.man_active = true
	actionTimer.stop()
	appeared.emit()

func leave():
	if current_state == State.HIDDEN:
		return
	current_state = State.HIDDEN
	suspicion = 0.0
	visible = false
	GameManager.man_active = false
	actionTimer.start()
	left.emit()
	

func is_present() -> bool:
	return current_state == State.PRESENT

func compute_action() -> void:
	var x = randf_range(0,1)
	if x <= actionChance:
		appear()

func jumpscare() -> void:
	if GameManager.is_dead or current_state == State.HIDDEN or blocked:
		return
	manJumpscare.visible = true
	jumpscared.emit()
