extends KinematicBody

export var MAX_HEALTH: float = 100.0
export var fire_dmg: float = 5.0
export var fire_tic: float = 0.25
export var fire_duration: float = 4.0

var health: float
var is_on_fire: bool

onready var fireTimer = get_node("FireTimer")
onready var anim = get_node("AnimationPlayer")
onready var fireAnim = get_node("FireAnimationPlayer")

func _ready():
	health = 100.0
	anim.play("Idle")
	fireAnim.play("not_on_fire")
	fireTimer.wait_time = fire_tic
	is_on_fire = false

func kill() -> void:
	queue_free()

func damage(dmg_amt: float) -> void:
	if dmg_amt == 0:
		return
	anim.play("Damaged")
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

func on_damaged_end() -> void:
	anim.stop()
	anim.play("Idle")
