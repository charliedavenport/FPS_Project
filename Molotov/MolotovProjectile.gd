extends KinematicBody
class_name MolotovProjectile

const GRAVITY : float = 10.0
const MIN_SPEED: float = 8.0
const MAX_SPEED: float = 13.0

export var dmg: float = 50.0

onready var audio_stream = get_node("AudioStreamPlayer3D")

var velocity : Vector3
var alive : bool

func start(transf: Transform, charge: float, player_forward_vel: float):
	# linear mapping of charge -> speed
	# map [0,100] to [MIN_SPEED, MAX_SPEED] 
	# y = m*x + b
	var m = (MAX_SPEED - MIN_SPEED) / 100
	var speed = m * charge + MIN_SPEED
	alive = true
	self.global_transform = transf
	velocity = transf.basis.z.normalized() * (speed + player_forward_vel/3.0)
	$AnimationPlayer.play("spin")
	$KillTimer.connect("timeout", self, "on_timeout")
	$KillTimer.start()

func _physics_process(delta):
	if alive:
		velocity += Vector3.DOWN * GRAVITY * delta
		var collision = move_and_collide(velocity * delta)
		if collision:
			transform.origin = collision.position
			explode()

func explode():
	alive = false
	$CollisionShape.disabled = true
	$AnimationPlayer.stop()
	$AnimationPlayer.play("explosion") # -> on_explosion_end()
	audio_stream.play()
	var bodies = $FireArea.get_overlapping_bodies()
	for bod in bodies:
		if bod is Enemy:
			#bod.damage(dmg)
			bod.fire_damage()

func on_explosion_end():
	queue_free()

func on_timeout():
	explode()
