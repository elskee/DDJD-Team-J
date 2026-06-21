extends CanvasLayer

var fatherDifficulty = 0
var demonDifficulty = 0
var tvDifficulty = 0

func _ready():
	load_difficulty()
	$Center/VBox/HBoxContainer/VBoxContainer/HBoxContainer/FatherCounter.text = str(fatherDifficulty)
	$Center/VBox/HBoxContainer/VBoxContainer2/HBoxContainer/DemonCounter.text = str(demonDifficulty)
	$Center/VBox/HBoxContainer/VBoxContainer3/HBoxContainer/TvCounter.text = str(tvDifficulty)
	

func _on_father_down_pressed() -> void:
	pass # Replace with function body.
	if fatherDifficulty > 0:
		fatherDifficulty -= 1
	$Center/VBox/HBoxContainer/VBoxContainer/HBoxContainer/FatherCounter.text = str(fatherDifficulty)

func _on_father_up_pressed() -> void:
	pass # Replace with function body.
	if fatherDifficulty < 20:
		fatherDifficulty += 1
	$Center/VBox/HBoxContainer/VBoxContainer/HBoxContainer/FatherCounter.text = str(fatherDifficulty)

func _on_demon_down_pressed() -> void:
	if demonDifficulty > 0:
		demonDifficulty -= 1
	$Center/VBox/HBoxContainer/VBoxContainer2/HBoxContainer/DemonCounter.text = str(demonDifficulty)

func _on_demon_up_pressed() -> void:
	if demonDifficulty < 20:
		demonDifficulty += 1
	$Center/VBox/HBoxContainer/VBoxContainer2/HBoxContainer/DemonCounter.text = str(demonDifficulty)

func _on_tv_down_pressed() -> void:
	if tvDifficulty > 0:
		tvDifficulty -= 1
	$Center/VBox/HBoxContainer/VBoxContainer3/HBoxContainer/TvCounter.text = str(tvDifficulty)

func _on_tv_up_pressed() -> void:
	if tvDifficulty < 20:
		tvDifficulty += 1
	$Center/VBox/HBoxContainer/VBoxContainer3/HBoxContainer/TvCounter.text = str(tvDifficulty)

func _on_start_button_pressed() -> void:
	save_difficulty()
	GameManager.reset()
	get_tree().change_scene_to_file("res://level.tscn")


func save_difficulty():
	var file = FileAccess.open("user://difficulty.save",FileAccess.WRITE)
	
	file.store_var(fatherDifficulty)
	file.store_var(demonDifficulty)
	file.store_var(tvDifficulty)
	
func load_difficulty():
	if FileAccess.file_exists("user://difficulty.save"):
		var file = FileAccess.open("user://difficulty.save",FileAccess.READ)
		fatherDifficulty = file.get_var()
		demonDifficulty = file.get_var()
		tvDifficulty = file.get_var()
	else:
		fatherDifficulty = 0
		demonDifficulty = 0
		tvDifficulty = 0
		save_difficulty()
		
