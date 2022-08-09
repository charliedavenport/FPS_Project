extends Control
class_name MolotovWeapon

const charge_time := 1.0

onready var anim = get_node("MolotovAnim")
onready var audio_stream = get_node("AudioStreamPlayer")

var molotov_charge: float
var is_charging_throw: bool # TODO: state machine

signal spawn_molotov(charge)
signal begin_molotov_charge
signal update_molotov_charge(charge)
signal end_molotov_charge

func enable() -> void:
	if not anim: # idk why this is null, it shouldn't be >:(
		anim  = get_node("MolotovAnim")
	anim.play("molotov_equip")
	molotov_charge = 0.0
	is_charging_throw = false

func disable() -> void:
	if is_charging_throw and molotov_charge > 0.0:
		emit_signal("spawn_molotov", 100.0 * molotov_charge / charge_time)
	visible = false
	emit_signal("end_molotov_charge")

func _process(delta):
	if anim.current_animation == "molotov_idle" and Input.is_action_just_pressed("fire"):
		anim.stop()
		anim.play("light_molotov") # -> on_light_molotov_end()
	elif is_charging_throw:
		molotov_charge += delta
		if molotov_charge >= charge_time:
			molotov_charge = charge_time
		var charge_percent = 100.0 * molotov_charge / charge_time
		if Input.is_action_just_released("fire"):
			throw(charge_percent)
		else:
			emit_signal("update_molotov_charge", charge_percent)

func begin_charging_throw() -> void:
	emit_signal("begin_molotov_charge")
	is_charging_throw = true
	molotov_charge = 0.0
	anim.stop()
	anim.play("throw_molotov_hold")

func throw(charge_percent: float) -> void:
	is_charging_throw = false
	audio_stream.play()
	emit_signal("spawn_molotov", charge_percent)
	emit_signal("end_molotov_charge")
	anim.stop()
	anim.play("throw_molotov")

func on_light_molotov_end() -> void:
	if Input.is_action_pressed("fire"):
		begin_charging_throw()
	else:
		throw(0.0)

func on_throw_molotov_end() -> void:
	anim.stop()
	anim.play("molotov_idle")
	if Input.is_action_pressed("fire"):
		anim.play("light_molotov")
	
func on_molotov_equip_end() -> void:
	anim.stop()
	anim.play("molotov_idle")
