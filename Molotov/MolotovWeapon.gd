extends Control
class_name MolotovWeapon

onready var player = get_node("../../..")
onready var anim = get_node("MolotovAnim")
onready var playerHUD = get_node("../..")
onready var audio_stream = get_node("AudioStreamPlayer")

var molotov_charge: float
var explosion_secret: bool

func enable() -> void:
	if not anim: # idk why this is null, it shouldn't be >:(
		anim  = get_node("MolotovAnim")
	anim.play("molotov_equip")
	molotov_charge = 0.0
	explosion_secret = false
	
func _process(delta):
	if anim.current_animation == "molotov_idle" and Input.is_action_just_pressed("fire"):
		anim.stop()
		anim.play("light_molotov") # -> on_light_molotov_end()

func molotov_fire() -> void:
	anim.stop()
	anim.play("throw_molotov_hold")
	playerHUD.molotovChargeBar.visible = true
	var co = charge_molotov_throw()
	while co is GDScriptFunctionState and co.is_valid():
		co = yield(co, "completed")
	playerHUD.molotovChargeBar.visible = false
	player.spawn_molotov(molotov_charge)
	anim.stop()
	anim.play("throw_molotov")
	molotov_charge = 0.0

func charge_molotov_throw() -> void:
	while true:
		if Input.is_action_just_released("fire"):
			audio_stream.play()
			return
		else:
			molotov_charge += 2.0 # should multiply by delta time?
			molotov_charge = clamp(molotov_charge, 0.0, 100.0) 
			playerHUD.molotovChargeBar.value = molotov_charge
			yield(get_tree(), "idle_frame")

func on_light_molotov_end() -> void:
	anim.stop()
	if Input.is_action_pressed("fire"):
		molotov_fire()
	else:
		anim.play("throw_molotov")
		player.spawn_molotov(0.0)

func on_throw_molotov_end() -> void:
	anim.stop()
	anim.play("molotov_idle")
	if Input.is_action_pressed("fire"):
		anim.play("light_molotov")
	
func on_molotov_equip_end() -> void:
	anim.stop()
	anim.play("molotov_idle")
