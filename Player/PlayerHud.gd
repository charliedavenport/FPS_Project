extends CanvasLayer
class_name PlayerHUD

onready var molotovChargeBar = get_node("MolotovChargeBar")
onready var playerHealthLabel = get_node("PlayerHealthLabel")
onready var statsText = get_node("StatsText")

var stat_text = "Vel = %s \n"\
	+ "Speed = %s \n"\
	+ "FPS = %s \n"\
	+ "is_on_floor = %s \n"\
	#+ "floor_y = %s \n"
	#+ "moouse_pos = %s \n"
var speed: float
var vel: Vector3
var fps: float
var is_on_floor: bool
var floor_angle
var vert_look_angle: float

onready var player = get_parent()
onready var player_cam = get_parent().get_node("Camera")

func _ready():
	molotovChargeBar.visible = false
	
func _process(delta):
	vel = player.vel
	speed = vel.length()
	#speed_horizontal = Vector2(vel.x, vel.z).length()
	fps = Performance.get_monitor(Performance.TIME_FPS)
	is_on_floor = player.is_on_floor()
	#floor_angle = (PI/2) - asin(get_parent().floor_y)
	floor_angle = player.floor_y
	#vert_look_angle = rad2deg(player_cam.transform.basis.get_euler().x)
	statsText.text = stat_text % [vel, speed, fps, is_on_floor]
	playerHealthLabel.text = str(player.health)
