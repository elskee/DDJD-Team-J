extends CanvasLayer

func _ready():
	$Center/VBox/StartButton.grab_focus()
	var tween = create_tween().set_loops()
	tween.tween_property($Center/VBox/Title, "modulate:a", 0.6, 2.5).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Center/VBox/Title, "modulate:a", 1.0, 2.5).set_ease(Tween.EASE_IN_OUT)

func _on_start_pressed():
	GameManager.reset()
	get_tree().change_scene_to_file("res://level.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
