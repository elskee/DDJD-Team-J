extends CanvasLayer

func _ready():
	$Center/VBox/ContinueButton.grab_focus()

func _on_continue_pressed():
	GameManager.current_level += 1
	GameManager.reset()
	get_tree().change_scene_to_file("res://level.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://menus/main_menu.tscn")
