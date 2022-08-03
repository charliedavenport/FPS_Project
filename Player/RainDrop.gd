extends Spatial

onready var anim = get_node("AnimationPlayer")

var vel : Vector3
var target: Vector3

func _ready():
	set_as_toplevel(true)

func reset(_pos : Vector3, _speed: float, _target: Vector3) -> void:
	show()
	anim.play("fall")
	global_transform.origin = _pos
	vel = Vector3(0.0, -_speed, 0.0)
	target = _target

func _physics_process(delta):
	if not vel:
		return
	global_transform.origin += vel * delta
	if target and global_transform.origin.y <= target.y:
		global_transform.origin = target
		vel = Vector3.ZERO
		anim.play("splash")
		yield(anim, "animation_finished")
		hide()
