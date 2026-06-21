extends Node3D

enum Phase { TICKING, STUTTER, FINAL }

var phase: Phase = Phase.TICKING
var total_time: float = 300.0
var elapsed: float = 0.0
var stutter_start: float = 240.0
var silence_before_end: float = 3.0

var tick_timer: float = 0.0

var pause_duration: float = 0.15
var is_paused: bool = false
var pause_timer: float = 0.0

var tictac_instance: FmodEvent

signal phase_changed(new_phase: Phase)
signal time_up()

@onready var mesh_instance: MeshInstance3D = $Mesh

const TICTAC_GUID := "{bcb34a19-a9ab-45da-91eb-712463088319}"


func _ready():
	mesh_instance.visible = false


func _ensure_tictac():
	if tictac_instance:
		return
	var desc = FmodServer.get_event_from_guid(TICTAC_GUID)
	if desc == null:
		desc = FmodServer.get_event("event:/tictac")
	if desc:
		tictac_instance = FmodServer.create_event_instance_with_guid(desc.get_guid())
		tictac_instance.start()


func _process(delta):
	if GameManager.is_dead:
		return

	_ensure_tictac()

	if not tictac_instance:
		return

	elapsed += delta

	match phase:
		Phase.TICKING:
			if elapsed >= stutter_start:
				phase = Phase.STUTTER
				tick_timer = 0.0
				phase_changed.emit(phase)

		Phase.STUTTER:
			var stutter_progress = (elapsed - stutter_start) / (total_time - stutter_start)
			var current_interval = lerp(0.5, 0.2, stutter_progress)
			var skip_chance = lerp(0.1, 0.4, stutter_progress)

			if is_paused:
				pause_timer += delta
				if pause_timer >= pause_duration:
					is_paused = false
					tictac_instance.start()
			else:
				tick_timer += delta
				while tick_timer >= current_interval:
					tick_timer -= current_interval
					if randf() <= skip_chance:
						is_paused = true
						pause_timer = 0.0
						tictac_instance.stop(FmodServer.FMOD_STUDIO_STOP_IMMEDIATE)

			if elapsed >= total_time - silence_before_end:
				is_paused = false
				tictac_instance.stop(FmodServer.FMOD_STUDIO_STOP_IMMEDIATE)

			if elapsed >= total_time:
				tictac_instance.stop(FmodServer.FMOD_STUDIO_STOP_IMMEDIATE)
				tictac_instance.release()
				tictac_instance = null
				phase = Phase.FINAL
				time_up.emit()

		Phase.FINAL:
			pass


func get_progress() -> float:
	return elapsed / total_time


func get_phase() -> Phase:
	return phase
