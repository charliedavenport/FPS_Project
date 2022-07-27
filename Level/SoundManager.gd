extends Node

const rain_sound = preload("res://Assets/Sound/rain-thunder.ogg")

onready var audio_stream = get_node("AudioStreamPlayer")

func _ready():
	audio_stream.stream = rain_sound
	audio_stream.play()
