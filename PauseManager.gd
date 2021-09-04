extends Node

onready var pausedText = get_parent().get_node("PlayerHUD/PausedText")

func _ready():
	pausedText.visible = false
	
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			#print("unpausing")
			get_tree().paused = false
			pausedText.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			#print("pausing")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			pausedText.visible = true
			get_tree().paused = true
			
	
