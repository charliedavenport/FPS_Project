extends Control
class_name PlayerHands

onready var player = get_node("../..")
onready var weaponSwayAnim = get_node("WeaponSwayAnimator")

var is_returning_weapon_center: bool
var hand_resting_loc: Vector2

func _ready():
	hand_resting_loc = Vector2(get_viewport_rect().size.x / 2.0, get_viewport_rect().size.y)

func _process(delta):
	process_weapon_sway()

func process_weapon_sway() -> void:
	# horizontal speed
	var vel = player.vel
	var speed = Vector2(vel.x, vel.z).length()
	if speed > 0.1:
		if weaponSwayAnim.current_animation != "weapon_sway":
			weaponSwayAnim.play("weapon_sway")
		weaponSwayAnim.set_speed_scale(clamp(speed / 10, 0.25, 1.0)) # 10 = hardcoded move_speed from player.gd
		#print(speed/move_speed)
	elif weaponSwayAnim.current_animation == "weapon_sway" and not is_returning_weapon_center:
		is_returning_weapon_center = true
		#weaponSwayAnim.set_speed_scale(0.5)
		$WeaponSwayAnimator.stop()
		var co = return_weapon_to_center()
		while co is GDScriptFunctionState and co.is_valid():
			co = yield(co, "completed")
		weaponSwayAnim.stop()
		weaponSwayAnim.play("still")
		is_returning_weapon_center = false

func return_weapon_to_center() -> void:
	var target = hand_resting_loc
	while rect_position.distance_to(target) > 1.0:
		rect_position = rect_position.linear_interpolate(target, 0.25)
		yield(get_tree(), "idle_frame")
	return

func wait_for_weapon_to_center() -> void:
	var target = hand_resting_loc
	while rect_position.distance_to(target) > 1.0:
		yield(get_tree(), "idle_frame")
