extends Control
class_name BoltRifleWeapon

onready var anim = get_node("BoltRifleAnim")

const dmg = 75

signal BoltRifleShoot(dmg)

func enable() -> void:
	if not anim:
		anim = get_node("BoltRifleAnim")
	anim.play("equip")

func _process(delta):
	if anim.current_animation == "Idle" and Input.is_action_just_pressed("fire"):
		anim.stop()
		anim.play("shoot")
		emit_signal("BoltRifleShoot", dmg)

func on_shoot_finished() -> void:
	anim.play("bolt")

func on_bolt_finished() -> void:
	anim.play("Idle")

func on_equip_finished() -> void:
	anim.play("Idle")
