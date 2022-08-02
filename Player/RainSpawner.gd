tool
extends Spatial

const rain_drop_scene = preload("res://Player/RainDrop.tscn")
const rain_bucket_size = 500

export var radius := 65.0
export var drop_speed := 50.0
export var drops_per_second := 100.0

var rain_bucket : Array
var rng = RandomNumberGenerator.new()

# Thanks, miziziziz
var time_since_drop := 0.0
var cur_drop_ind := 0

func _ready():
	rain_bucket = []
	rng.randomize()
	for i in range(rain_bucket_size):
		var drop = rain_drop_scene.instance()
		drop.hide()
		self.add_child(drop)
		rain_bucket.append(drop)

func _process(delta):
	var drop_rate := 1.0 / drops_per_second
	time_since_drop += delta
	while time_since_drop >= drop_rate:
		make_drop()
		time_since_drop -= drop_rate

func make_drop() -> void:
	var rand_angle = rng.randf_range(-PI, PI)
	var rand_radius = rng.randf_range(0, radius)
	var rand_point = Vector3(0.0, 0.0, 1.0).rotated(Vector3.UP, rand_angle).normalized() * rand_radius
	var drop_start = self.global_transform.origin + rand_point
	rain_bucket[cur_drop_ind].reset(drop_start, drop_speed)
	cur_drop_ind += 1
	cur_drop_ind %= rain_bucket.size()
	
