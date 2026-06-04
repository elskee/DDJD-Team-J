extends Node3D

enum State { HIDDEN, PRESENT }

var current_state: State = State.HIDDEN
var suspicion: float = 0.0
var time_present: float = 0.0
var tv_turned_off_already: bool = false
var appear_timer: float = 0.0
var next_appear_time: float = 0.0

@export var max_suspicion: float = 100.0
@export var appear_delay_min: float = 15.0
@export var appear_delay_max: float = 40.0
@export var tv_off_delay: float = 5.0

signal appeared()
signal left()
signal turned_off_tv()
signal jumpscared()

func _ready():
	visible = false
	randomize_appear_time()

func _process(delta):
	if GameManager.is_dead:
		return

	if current_state == State.HIDDEN:
		appear_timer += delta
		if appear_timer >= next_appear_time:
			try_appear()
		return

	time_present += delta

	if GameManager.eyes_closed:
		suspicion = maxf(suspicion - 15.0 * delta, 0.0)
	else:
		suspicion = minf(suspicion + 10.0 * delta, max_suspicion)

	if GameManager.flashlight_on:
		suspicion = minf(suspicion + 25.0 * delta, max_suspicion)

	if suspicion >= max_suspicion:
		jumpscared.emit()
		return

	if suspicion <= 0.0:
		leave()
		return

	if not tv_turned_off_already and time_present >= tv_off_delay:
		tv_turned_off_already = true
		turned_off_tv.emit()

func randomize_appear_time():
	appear_timer = 0.0
	next_appear_time = randf_range(appear_delay_min, appear_delay_max)

func try_appear():
	if current_state == State.HIDDEN and not GameManager.is_dead:
		appear()

func appear():
	current_state = State.PRESENT
	suspicion = max_suspicion * 0.3
	time_present = 0.0
	tv_turned_off_already = false
	visible = true
	GameManager.man_active = true
	appeared.emit()

func leave():
	current_state = State.HIDDEN
	visible = false
	suspicion = 0.0
	GameManager.man_active = false
	left.emit()
	randomize_appear_time()

func is_present() -> bool:
	return current_state == State.PRESENT
