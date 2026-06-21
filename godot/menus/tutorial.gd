extends CanvasLayer

func _on_retry_pressed():
	GameManager.reset()
	get_tree().change_scene_to_file("res://level.tscn")
