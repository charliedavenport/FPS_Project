extends KinematicBody

export var MAX_HEALTH: float = 100.0
var health: float

func _ready():
	health = 100.0
	$AnimationPlayer.play("Idle")

func kill() -> void:
	queue_free()

func damage(dmg_amt: float) -> void:
	if dmg_amt == 0:
		return
	$AnimationPlayer.play("Damaged")
	health -= dmg_amt
	if health <= 0.0:
		kill()

func on_damaged_end() -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Idle")
