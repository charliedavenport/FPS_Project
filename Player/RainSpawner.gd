extends Spatial

const rain_drop_scene = preload("res://Player/RainDrop.tscn")

export var rain_bucket_size = 700
export var radius := 65.0
export var drop_speed := 50.0
export var beg_drops_per_second := 1.0
export var drops_accel := 5.0
export var max_drops_per_second := 500.0

var rain_bucket : Array
var rng = RandomNumberGenerator.new()

# Thanks, miziziziz
var time_since_drop := 0.0
var cur_drop_ind := 0
var cur_drops_per_sec : float

func _ready():
	rain_bucket = []
	rng.randomize()
	for i in range(rain_bucket_size):
		var drop = rain_drop_scene.instance()
		drop.hide()
		get_tree().root.call_deferred("add_child", drop)
		rain_bucket.append(drop)
	cur_drops_per_sec = beg_drops_per_second

func _process(delta):
	var drop_rate := 1.0 / cur_drops_per_sec
	time_since_drop += delta
	while time_since_drop >= drop_rate:
		make_drop()
		time_since_drop -= drop_rate
	cur_drops_per_sec += drops_accel * delta

func make_drop() -> void:
	var rand_angle = rng.randf_range(-PI, PI)
	var rand_radius = rng.randf_range(0.0, radius)
	var rand_point = Vector3(0.0, 0.0, 1.0).rotated(Vector3.UP, rand_angle).normalized() * rand_radius
	var drop_start = self.global_transform.origin + rand_point
	var drop_target = Vector3()
	var space_state = get_world().direct_space_state
	var ray_hit = space_state.intersect_ray(drop_start, Vector3(0.0, -200.0, 0.0), [], 2)
	if ray_hit.size() > 0:
		drop_target = ray_hit.position + Vector3(0.0, 0.08, 0.0)
	rain_bucket[cur_drop_ind].reset(drop_start, drop_speed, drop_target)
	cur_drop_ind += 1
	cur_drop_ind %= rain_bucket.size()
	
