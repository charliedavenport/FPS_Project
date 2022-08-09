extends Control
class_name PlayerHands

const horiz_offset: float = 50.0
const vert_offset: float = 30.0
const weapon_sway_len: float = 0.8
const min_speed_threshold: float = 0.1
const return_to_center_time: float = 0.2

enum SwayState {IDLE, SWAYING, RETURN_TO_CENTER}
var state : int

onready var player = get_node("../..")
onready var sway_tween = get_node("WeaponSwayTween")
onready var return_tween = get_node("ReturnToCenterTween")

onready var hands_idle: Vector2 = Vector2(get_viewport_rect().size.x / 2.0, get_viewport_rect().size.y) \
		+ Vector2(0.0, -vert_offset)
onready var target_pos = [hands_idle, 
		hands_idle + Vector2(-horiz_offset, vert_offset),
		hands_idle, 
		hands_idle + Vector2(horiz_offset, vert_offset)]
onready var target_pos_ind := 0
onready var sway_interval = weapon_sway_len / 4.0

func _ready():
	rect_position = hands_idle
	set_state(SwayState.IDLE)
	var n_pos = len(target_pos)
	for i in range(n_pos):
		sway_tween.interpolate_property(self, "rect_position",
				target_pos[i],
				target_pos[(i+1) % n_pos],
				sway_interval, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,
				float(i) * sway_interval)
	sway_tween.repeat = true

func _process(delta):
	var vel = player.vel
	var speed = Vector2(vel.x, vel.z).length()
	if speed > min_speed_threshold:
		if state != SwayState.SWAYING:
			#start_weapon_sway()
			set_state(SwayState.SWAYING)
		sway_tween.playback_speed = clamp(speed / player.move_speed, 0.25, 1.0)
	elif state == SwayState.SWAYING:
		#return_weapon_to_center()
		set_state(SwayState.RETURN_TO_CENTER)

func set_state(_state : int) -> void:
	if state == _state:
		return
	state = _state
	sway_tween.stop_all()
	return_tween.stop_all()
	match state:
		SwayState.IDLE:
			pass
		SwayState.SWAYING:
			sway_tween.start()
		SwayState.RETURN_TO_CENTER:
			return_tween.interpolate_property(self, "rect_position",
					rect_position, hands_idle,
					return_to_center_time, Tween.TRANS_LINEAR)
			return_tween.start()

func set_modulate(color : Color) -> void:
	pass
