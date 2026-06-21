extends CanvasLayer

func _ready():
	$Center/VBox/RetryButton.grab_focus()
	var tween = create_tween().set_loops()
	tween.tween_property($Center/VBox/Title, "modulate", Color(0.65, 0.08, 0.08, 0.6), 2.0).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Center/VBox/Title, "modulate", Color(0.65, 0.08, 0.08, 1.0), 2.0).set_ease(Tween.EASE_IN_OUT)

func _on_retry_pressed():
	GameManager.reset()
	get_tree().change_scene_to_file("res://level.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://menus/main_menu.tscn")
