extends KinematicBody
class_name Enemy

export var MAX_HEALTH: float = 100.0
export var fire_dmg: float = 5.0
export var fire_tic: float = 0.25
export var fire_duration: float = 4.0
export var speed: float = 2.0
export var gravity: float = 0.5

var health: float
var is_on_fire: bool
var nav_target : Spatial
var vel : Vector3

onready var fireTimer = get_node("FireTimer")
onready var anim = get_node("AnimationPlayer")
onready var fireAnim = get_node("FireAnimationPlayer")
onready var dmgAnim = get_node("DmgAnimationPlayer")
onready var navAgent = get_node("NavigationAgent")

func _ready():
	vel = Vector3.ZERO
	health = 100.0
	anim.play("Idle")
	fireAnim.play("not_on_fire")
	fireTimer.wait_time = fire_tic
	is_on_fire = false
	navAgent.connect("velocity_computed", self, "on_velocity_computed")

func _physics_process(delta):
	apply_gravity()
	if not nav_target:
		return
	navAgent.set_target_location(nav_target.global_transform.origin)
	var current_pos = global_transform.origin
	var target_pos = navAgent.get_next_location()
	var move_vel_offset = (target_pos - current_pos).normalized() * speed
	vel.x = move_vel_offset.x
	vel.z = move_vel_offset.z
	navAgent.set_velocity(vel)

func on_velocity_computed(safe_vel : Vector3) -> void:
	print("on velocity computed")
	move_and_slide(safe_vel)

func apply_gravity() -> void:
	if is_on_floor():
		vel.y = 0
	vel.y -= gravity
	move_and_slide(vel)

func kill() -> void:
	queue_free()

func damage(dmg_amt: float) -> void:
	if dmg_amt == 0:
		return
	dmgAnim.play("damaged")
	health -= dmg_amt
	if health <= 0.0:
		kill()

func fire_damage() -> void:
#	if is_on_fire:
#		return
	is_on_fire = true
	var tics = int(fire_duration/fire_tic)
#	print("ON FIRE")
	fireAnim.play("on_fire")
	for i in range(tics):
		damage(fire_dmg)
		fireTimer.start()
		yield(fireTimer, "timeout")
		#print("ouch!")
	fireAnim.play("not_on_fire")
	is_on_fire = false

func set_nav_target(target : Node) -> void:
	print("set " + self.name + " nav target: " + target.name)
	nav_target = target
#	navAgent.set_target_location(nav_target.global_transform.origin)
