extends CanvasLayer

onready var molotovChargeBar = get_node("MolotovChargeBar")

var stat_text = "Vel = %s \n"\
	+ "Speed = %s \n"\
	+ "FPS = %s \n"\
	+ "is_on_floor = %s \n"
var speed: float
var vel: Vector3
var fps: float
var is_on_floor: bool

func _ready():
	molotovChargeBar.visible = false
	
func _process(delta):
	vel = get_parent().vel
	speed = vel.length()
	#speed_horizontal = Vector2(vel.x, vel.z).length()
	fps = Performance.get_monitor(Performance.TIME_FPS)
	is_on_floor = get_parent().is_on_floor()
	$StatsText.text = stat_text % [vel, speed, fps, is_on_floor]
