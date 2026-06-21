extends Node3D

@onready var eyelid = $Eyelid
@onready var flashlight_node = $Flashlight
@onready var sleepy_label = $SleepyMeter
@onready var tv = $TV
@onready var jumpscare_sound = $JumpscareSound
@onready var man_monster = $Man
@onready var ghost_monster = $Ghost
@onready var final_monster = $FinalMonster

@onready var selected_level = 6
@onready var latest_max_level = 1
@onready var max_level = 1

var manDifficulty = 0
var ghostDifficulty = 0
var tvDifficulty = 0

func _ready():
	GameManager.reset()
	load_data()
	choose_difficulty(selected_level)
	print(selected_level)
	print(latest_max_level)
	print(max_level)
	connect_tv_signals()
	connect_monster_signals()
	connect_ghost_signals()
	connect_game_signals()
	connect_final_monster_signals()
	tv.turn_on()

func choose_difficulty(level = 1):
	match level:
		-1:
			load_difficulty()
			set_difficulty(ghostDifficulty,manDifficulty,tvDifficulty)
		1:
			set_difficulty(0,0,3)
		2:
			set_difficulty(3,0,5)
		3:
			set_difficulty(7,5,0)
		4:
			set_difficulty(3,15,3)
		5:
			set_difficulty(15,10,15)
		6:
			set_difficulty(20,20,20)

func set_difficulty(ghost_diff = 1, man_diff = 1, tv_diff = 1):
	ghost_diff = clamp(ghost_diff,0,20)
	man_diff = clamp(man_diff,0,20)
	tv_diff = clamp(tv_diff,0,20)
	$Ghost.set_difficulty(ghost_diff)
	$Man.set_difficulty(man_diff)
	$TV.set_difficulty(tv_diff)	

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
		var rate = 1.0
		if tv.is_safe() and tv.is_on():
			rate += 2.0
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

func connect_final_monster_signals():
	final_monster.time_up.connect(_on_final_time_up)

func _on_final_time_up():
	if GameManager.is_dead:
		return
	trigger_jumpscare()
	print("Final Monster timer expired!")

func _on_sleepiness_updated(value, max_value):
	if value >= max_value and not GameManager.is_dead:
		_on_level_complete()

func _on_level_complete():
	GameManager.is_dead = true
	print("Level %s complete - you fell asleep!" % GameManager.current_level)
	sleepy_label.text = "YOU FELL ASLEEP!"
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://menus/level_complete.tscn")

func trigger_jumpscare():

	eyelid.visible = false
	flashlight_node.visible = true
	if GameManager.is_dead != true:
		jumpscare_sound.play()
	GameManager.is_dead = true
	GameManager.die()
	$jumpscareTimer.start()

func _on_jumpscare_timer_timeout():
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://menus/game_over.tscn")

func _on_action_timer_timeout():
	if GameManager.is_dead:
		return
	print("Action timer ticked")

func _on_game_over():
	sleepy_label.text = "GAME OVER"
	print("Game Over!")


func save_data():
	var file = FileAccess.open("user://savegame.save",FileAccess.WRITE)
	
	file.store_var(selected_level)
	file.store_var(latest_max_level)
	file.store_var(max_level)
	
func load_data():
	if FileAccess.file_exists("user://savegame.save"):
		var file = FileAccess.open("user://savegame.save",FileAccess.READ)
		selected_level = file.get_var()
		latest_max_level = file.get_var()
		max_level = file.get_var()
	else:
		print("no save game found, resetting data")
		selected_level = 1
		latest_max_level = 1
		max_level = 1
		save_data()
		
		
func save_difficulty():
	var file = FileAccess.open("user://difficulty.save",FileAccess.WRITE)
	
	file.store_var(manDifficulty)
	file.store_var(ghostDifficulty)
	file.store_var(tvDifficulty)
	
func load_difficulty():
	if FileAccess.file_exists("user://difficulty.save"):
		var file = FileAccess.open("user://difficulty.save",FileAccess.READ)
		manDifficulty = file.get_var()
		ghostDifficulty = file.get_var()
		tvDifficulty = file.get_var()
	else:
		manDifficulty = 0
		ghostDifficulty = 0
		tvDifficulty = 0
		save_difficulty()
		
