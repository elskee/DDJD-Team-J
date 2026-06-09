extends Node3D

@onready var eyelid = $Eyelid
@onready var flashlight_node = $Flashlight
@onready var sleepy_label = $SleepyMeter
@onready var tv = $TV
@onready var jumpscare_sound = $JumpscareSound
@onready var saul_sound = $SaulSound
@onready var close_nekoarc = $CloseNekoArc
@onready var man_monster = $Man
@onready var ghost_monster = $Ghost

func _ready():
	GameManager.reset()
	set_difficulty()
	connect_tv_signals()
	connect_monster_signals()
	connect_ghost_signals()
	connect_game_signals()
	tv.turn_on()

func set_difficulty(ghost_diff = 1, man_diff = 1, tv_diff = 1):
	#$Ghost.
	
	pass
	

func connect_tv_signals():
	tv.became_corrupted.connect(_on_tv_corrupted)
	tv.turned_on.connect(_on_tv_turned_on)
	tv.turned_off.connect(_on_tv_turned_off)
	tv.jumpscared.connect(_on_tv_jumpscare)

func connect_monster_signals():
	man_monster.appeared.connect(_on_man_appeared)
	man_monster.left.connect(_on_man_left)
	man_monster.turned_off_tv.connect(_on_man_turned_off_tv)
	man_monster.jumpscared.connect(_on_monster_jumpscare)
	
func connect_ghost_signals():
	ghost_monster.appeared.connect(_on_ghost_appeared)
	ghost_monster.left.connect(_on_ghost_left)
	ghost_monster.jumpscared.connect(_on_monster_jumpscare)

func connect_game_signals():
	GameManager.sleepiness_updated.connect(_on_sleepiness_updated)
	GameManager.game_over.connect(_on_game_over)

func _process(delta):
	if GameManager.is_dead:
		return

	handle_input()
	update_sleepiness(delta)
	update_ui()

func handle_input():
	GameManager.eyes_closed = Input.is_action_pressed("closeEye")

	if Input.is_action_just_pressed("useFlashlight"):
		GameManager.toggle_flashlight()

	if Input.is_action_just_pressed("toggleTV"):
		if tv.is_on():
			tv.turn_off()
		else:
			tv.turn_on()

func update_sleepiness(delta):
	if GameManager.eyes_closed:
		var rate = 2.0
		if tv.is_safe():
			rate += 1.0
		GameManager.sleepiness += rate * delta
	else:
		GameManager.sleepiness -= 1.0 * delta

func update_ui():
	eyelid.visible = GameManager.eyes_closed
	flashlight_node.visible = GameManager.flashlight_on
	sleepy_label.text = "Sleepiness: %s/%s" % [
		str(snapped(GameManager.sleepiness, 0.1)),
		str(GameManager.max_sleepiness)
	]

func _on_tv_turned_on():
	pass

func _on_tv_turned_off():
	pass

func _on_tv_corrupted():
	print("TV corrupted - turn it off and on again!")

func _on_tv_jumpscare():
	trigger_jumpscare()
	print("TV jumpscared you!")

func _on_man_appeared():
	ghost_monster.blocked = true
	if ghost_monster.is_present():
		ghost_monster.leave()
	print("MAN appeared - door creaks")

func _on_man_left():
	ghost_monster.blocked = false
	print("MAN left")

func _on_man_turned_off_tv():
	tv.turn_off()      
	print("MAN turned off the TV")

func _on_monster_jumpscare():
	trigger_jumpscare()
	print("Monster jumpscared you!")

func _on_ghost_appeared():
	print("GHOST appeared - everything goes quiet")

func _on_ghost_left():
	print("GHOST left")

func _on_sleepiness_updated(value, max_value):
	if value >= max_value and not GameManager.is_dead:
		_on_level_complete()

func _on_level_complete():
	GameManager.is_dead = true
	print("Level %s complete - you fell asleep!" % GameManager.current_level)
	sleepy_label.text = "YOU FELL ASLEEP!"

func trigger_jumpscare():
	#close_nekoarc.visible = true
	eyelid.visible = false
	if GameManager.is_dead != true:
		jumpscare_sound.play()
	GameManager.is_dead = true
	GameManager.die()
	$jumpscareTimer.start()

func _on_jumpscare_timer_timeout():
	close_nekoarc.visible = false

func _on_action_timer_timeout():
	if GameManager.is_dead:
		return
	print("Action timer ticked")

func _on_game_over():
	sleepy_label.text = "GAME OVER"
	print("Game Over!")
