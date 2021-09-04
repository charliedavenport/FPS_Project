extends KinematicBody

export var move_speed: float = 10.0
export var look_sens: float = .01
export var accel: float = 5.0
export var deaccel: float = 10.0
export var fall_accel_down: float = 3.0
export var fall_accel_up: float = 1.0
export var max_fall_speed: float = -15.0
export var jump_speed: float = 10.0

var vel: Vector3
var move_input: Vector3
var snap: Vector3

var is_jump_cooldown: bool
var jump_request: bool
var is_returning_weapon_center: bool

onready var cam = get_node("Camera")
onready var jump_timer = get_node("JumpTimer")
onready var molotov_scene = preload("res://MolotovProjectile.tscn")
onready var molotov_spawn = get_node("Camera/MolotovSpawn")

func _ready():
	vel = Vector3.ZERO
	move_input = Vector3.ZERO
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	is_jump_cooldown = false
	jump_timer.connect("timeout", self, "on_jump_cooldown")
	is_returning_weapon_center = false
	
func _input(event):
	if event is InputEventMouseMotion:
		var mouse_delta = event.relative
		cam.rotate_x(mouse_delta.y * look_sens )
		self.rotate_y(-1 * mouse_delta.x * look_sens)

func _process(_delta):
	get_move_input()

func _physics_process(delta):
	snap = Vector3.DOWN
	if is_on_floor():
		vel.y = 0.0
		snap = -get_floor_normal()
	else:
		snap = Vector3.ZERO
	#apply_slope()
	apply_move_acceleration(delta)
	if jump_request:
		apply_jump()
	elif not is_on_floor():
		apply_gravity(delta)
	#vel = move_and_slide(move_input, Vector3.UP, true, 4, 1.22)
	vel = move_and_slide_with_snap(move_input, snap, Vector3.UP, true, 4)
#	var slides = get_slide_count()
#	if slides > 0:
#		handle_slopes(slides)

func apply_slope() -> void:
	# rotate movement input to be on the plane of a slope
	var slides = get_slide_count()
	if slides == 0:
		return
	for i in range(slides):
		var col = get_slide_collision(i)
		if col.normal.y < 1.0:
			pass

func apply_move_acceleration(delta: float) -> void:
	var wish_dir = move_input * move_speed
	if wish_dir.dot(move_input) > 0:
		move_input = vel.linear_interpolate(wish_dir, accel*delta)
	else:
		move_input = vel.linear_interpolate(wish_dir, deaccel*delta)

func apply_jump() -> void:
	move_input.y += jump_speed
	jump_request = false
	snap = Vector3.ZERO
	is_jump_cooldown = true
	jump_timer.start()

func apply_gravity(delta) -> void:
	if vel.y > 0:
		move_input.y = lerp(vel.y, max_fall_speed, fall_accel_up*delta)
	else:
		move_input.y = lerp(vel.y, max_fall_speed, fall_accel_down*delta)

func on_jump_cooldown() -> void:
	jump_timer.stop()
	is_jump_cooldown = false

func get_move_input() -> void:
	var input_vec = Vector3.ZERO
	if Input.is_action_pressed("forward"):
		input_vec += self.transform.basis.z
	if Input.is_action_pressed("back"):
		input_vec -= self.transform.basis.z
	if Input.is_action_pressed("left"):
		input_vec += self.transform.basis.x
	if Input.is_action_pressed("right"):
		input_vec -= self.transform.basis.x
	move_input = input_vec.normalized()
	if Input.is_action_just_pressed("jump") and not is_jump_cooldown:
		jump_request = true

func spawn_molotov(speed: float) -> void:
	var player_forward_vel = vel.dot(self.transform.basis.z.normalized())
	var molotov_inst = molotov_scene.instance()
	get_tree().root.add_child(molotov_inst)
	molotov_inst.start(molotov_spawn.global_transform, speed, player_forward_vel)
