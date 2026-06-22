extends CanvasLayer

var selected_level = 1
var latest_max_level = 0
var max_level = 0



func _ready():
	load_data()
	if max_level != 6:
		$Center/VBox/CustomNight.visible = false
	$Center/VBox/ContinueButton.text = "CONTINUE - NIGHT " + str(latest_max_level + 1)
	
func _on_start_pressed():
	load_data()
	selected_level = 1
	latest_max_level = 0
	save_data()
	GameManager.reset()
	get_tree().change_scene_to_file("res://menus/tutorial.tscn")
	

func _on_continue_pressed() -> void:
	load_data()
	selected_level = latest_max_level + 1
	save_data()
	GameManager.reset()
	get_tree().change_scene_to_file("res://level.tscn")

func _on_custom_night_pressed() -> void:
	load_data()
	selected_level = -1
	save_data()
	GameManager.reset()
	get_tree().change_scene_to_file("res://menus/custom_night.tscn")
	

func _on_quit_pressed():
	get_tree().quit()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
		
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
		
