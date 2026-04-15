extends Node3D

@export var maxSleepy : float = 30.0
var currentSleepy : float = 0.0
var eyesClosed : bool = false
var flashlight : bool = false
var farNeko : bool = false
var nekoCooldown : bool = false
var nekoDifficulty : int = 17
var isDead : bool = false


func _process(delta: float) -> void:
	if Input.is_action_pressed("closeEye") and !isDead:
		eyesClosed = true
	else:
		eyesClosed = false
	
	if Input.is_action_pressed("useFlashlight") and !isDead:
		flashlight = true
	else:
		flashlight = false
	
	
	if eyesClosed:
		$Eyelid.visible = true
		currentSleepy += 2*delta
	else:
		$Eyelid.visible = false
		currentSleepy -= delta
		
	if flashlight:
		$Flashlight.visible = true
		$FarNekoArc.visible = false
		$jumpscareTimer.stop()
		farNeko = false
		nekoCooldown = true
		currentSleepy -= 3*delta
	else:
		$Flashlight.visible = false
		
	if currentSleepy < 0:
		currentSleepy = 0
	if currentSleepy > maxSleepy:
		currentSleepy = maxSleepy
	
		
	$SleepyMeter.text = "Sleepyness: " + str(snapped(currentSleepy,0.1)) + "/" + str(maxSleepy)
	


func _on_action_timer_timeout() -> void:
	if (!farNeko and !nekoCooldown and eyesClosed):
		if (randi_range(0,19)<nekoDifficulty):
			farNeko = true
			$FarNekoArc.visible = true
			$jumpscareTimer.start(0)
			print("appeared")
			$SaulSound.play(0)
	nekoCooldown = false
	print("timerTest")  
	pass # Replace with function body.


func _on_jumpscare_timer_timeout() -> void:
	print("jumpscare")
	isDead = true
	$CloseNekoArc.visible = true
	$NecoarcSound.play(0)
	$jumpscareTimer.stop()
	pass # Replace with function body.
