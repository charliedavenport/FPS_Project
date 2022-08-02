tool
extends KinematicBody

onready var anim = get_node("AnimationPlayer")
onready var collision_shape = get_node("CollisionShape")

var vel : Vector3

func _ready():
	set_as_toplevel(true)

func reset(_pos : Vector3, _speed: float) -> void:
	show()
	anim.play("fall")
	global_transform.origin = _pos
	vel = Vector3(0.0, -_speed, 0.0)
	collision_shape.disabled = false

func _physics_process(delta):
	if not vel:
		return
	var col = move_and_collide(vel * delta)
	if col:
		collision_shape.disabled = true
		vel = Vector3.ZERO
		anim.play("splash")
		yield(anim, "animation_finished")
		hide()
