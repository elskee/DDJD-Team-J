extends CanvasLayer

var selected_level = 1
var latest_max_level = 1
var max_level = 1

func _ready():
	$Center/VBox/ContinueButton.grab_focus()
	load_data()
	if selected_level == -1:
		$EndingThankYou.visible = false
		$Center/VBox/ContinueButton.visible = false
	elif selected_level == 6:
		max_level = 6
		$EndingThankYou.visible = true
		$Center/VBox/ContinueButton.visible = false
	else:
		$EndingThankYou.visible = false
		$Center/VBox/ContinueButton.visible = true
		if latest_max_level == selected_level - 1:
			latest_max_level += 1
		if latest_max_level > max_level:
			max_level = latest_max_level
	save_data()
	$Center/VBox/ContinueButton.text = "CONTINUE - NIGHT " + str(selected_level + 1)

func _on_continue_pressed():
	load_data()
	selected_level += 1
	save_data()
	
	GameManager.reset()
	get_tree().change_scene_to_file("res://level.tscn")

func _on_main_menu_pressed():
	GameManager.reset()
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://menus/main_menu.tscn")

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
		
