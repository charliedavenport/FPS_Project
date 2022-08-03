extends Area

signal taken_headshot(pos)

func headshot(pos: Vector3) -> void:
	emit_signal("taken_headshot", pos)
