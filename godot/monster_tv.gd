extends Node


var safeTVmat = load('res://safeTV.tres')
var dangerTVmat = load('res://dangerTV.tres')

func _ready() -> void:
	set("material_override",safeTVmat)


func setSafe() -> void:
	set("material_override",safeTVmat)

func setDanger() -> void:
	set("material_override",dangerTVmat)
