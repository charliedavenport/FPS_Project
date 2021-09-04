extends Node

onready var player = get_parent()
onready var handAnim = get_parent().get_node("HandAnimator")
onready var weaponSwayAnim = get_parent().get_node("WeaponSwayAnimator")
onready var handsNode = get_parent().get_node("PlayerHUD/Hands")
onready var playerHUD = get_parent().get_node("PlayerHUD")

var is_returning_weapon_center: bool
var molotov_charge: float

func _ready():
	handAnim.play("molotov_equip")
	is_returning_weapon_center = false
	molotov_charge = 0.0
	
func _process(delta):
	process_weapon_sway()
	process_hand_anim()

func process_hand_anim() -> void:
	if handAnim.current_animation == "molotov_idle" and Input.is_action_just_pressed("fire"):
		handAnim.stop()
		handAnim.play("light_molotov") # -> on_light_molotov_end()

# ********************************************************************
# FIRE MOLOTOV
# ********************************************************************
func molotov_fire() -> void:
	handAnim.stop()
	handAnim.play("throw_molotov_hold")
	playerHUD.molotovChargeBar.visible = true
	var co = charge_molotov_throw()
	while co is GDScriptFunctionState and co.is_valid():
		co = yield(co, "completed")
	playerHUD.molotovChargeBar.visible = false
	player.spawn_molotov(molotov_charge)
	handAnim.stop()
	handAnim.play("throw_molotov")
	molotov_charge = 0.0

func charge_molotov_throw() -> void:
	while true:
		if Input.is_action_just_released("fire"):
			return
		else:
			molotov_charge += 1.0 # should multiply by delta time?
			molotov_charge = clamp(molotov_charge, 0.0, 100.0) 
			playerHUD.molotovChargeBar.value = molotov_charge
			yield(get_tree(), "idle_frame")

# ********************************************************************
# WEAPON SWAY
# ********************************************************************
func process_weapon_sway() -> void:
	# horizontal speed
	var vel = get_parent().vel
	var speed = Vector2(vel.x, vel.z).length()
	if speed > 0.1:
		if weaponSwayAnim.current_animation != "weapon_sway":
			weaponSwayAnim.play("weapon_sway")
		weaponSwayAnim.set_speed_scale(clamp(speed / 10, 0.25, 1.0)) # 10 = hardcoded move_speed from player.gd
		#print(speed/move_speed)
	elif weaponSwayAnim.current_animation == "weapon_sway" and not is_returning_weapon_center:
		is_returning_weapon_center = true
		#weaponSwayAnim.set_speed_scale(0.5)
#		$WeaponSwayAnimator.stop()
		var co = wait_for_weapon_to_center()
		while co is GDScriptFunctionState and co.is_valid():
			co = yield(co, "completed")
		weaponSwayAnim.stop()
		weaponSwayAnim.play("still")
		is_returning_weapon_center = false

func return_weapon_to_center() -> void:
	var target = Vector2(512,600)
	while handsNode.rect_position.distance_to(target) > 1.0:
		handsNode.rect_position = handsNode.rect_position.linear_interpolate(target, 0.25)
		#print(handsNode.rect_position)
		yield(get_tree(), "idle_frame")
		
func wait_for_weapon_to_center() -> void:
	var target = Vector2(512,600)
	while handsNode.rect_position.distance_to(target) > 1.0:
		yield(get_tree(), "idle_frame")

# ********************************************************************
# ANIMATION PLAYER 
# ********************************************************************
func on_light_molotov_end() -> void:
	handAnim.stop()
	if Input.is_action_pressed("fire"):
		molotov_fire()
	else:
		handAnim.play("throw_molotov")
		player.spawn_molotov(0.0)

func on_throw_molotov_end() -> void:
	handAnim.stop()
	handAnim.play("molotov_idle")
	if Input.is_action_pressed("fire"):
		handAnim.play("light_molotov")
	
func on_molotov_equip_end() -> void:
	handAnim.stop()
	handAnim.play("molotov_idle")
	


