extends KinematicBody
class_name Player

const move_speed: float = 5.0
export var look_sens: float = .01
export var accel: float = 5.0
export var deaccel: float = 10.0
export var fall_accel_down: float = 3.0
export var fall_accel_up: float = 1.0
export var max_fall_speed: float = -15.0
export var jump_speed: float = 10.0
export var max_floor_angle: float = 40.0
export var max_vertical_rot: float = 1.4 
export var min_vertical_rot: float = -1.4 

var vel: Vector3
var move_input: Vector3
var snap: Vector3

var is_jump_cooldown: bool
var jump_request: bool
var is_returning_weapon_center: bool

var min_floor_y: float
var floor_y: float
var vertical_rot: float

onready var cam = get_node("Camera")
onready var cam_ray = get_node("Camera/RayCast")
onready var jump_timer = get_node("JumpTimer")
onready var molotov_scene = preload("res://Molotov/MolotovProjectile.tscn")
onready var molotov_spawn = get_node("Camera/MolotovSpawn")
onready var weapon_manager = get_node("WeaponManager")

func _ready():
	vel = Vector3.ZERO
	move_input = Vector3.ZERO
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	is_jump_cooldown = false
	jump_timer.connect("timeout", self, "on_jump_cooldown")
	weapon_manager.get_weapon_by_name("Bolt Rifle").root_node.connect("BoltRifleShoot", self, "shoot_ray")
	is_returning_weapon_center = false
	min_floor_y = sin((PI/2) - deg2rad(max_floor_angle)) # i <3 trig
	vertical_rot = self.transform.basis.get_euler().x
	
func _input(event):
	if event is InputEventMouseMotion:
		var mouse_delta = event.relative
		if mouse_delta.y < 0 and vertical_rot < max_vertical_rot:
			cam.rotate_x(mouse_delta.y * look_sens )
		elif mouse_delta.y > 0 and vertical_rot > min_vertical_rot:
			cam.rotate_x(mouse_delta.y * look_sens )
		self.rotate_y(-1 * mouse_delta.x * look_sens)
		vertical_rot = cam.transform.basis.get_euler().x

func _process(_delta):
	get_move_input()

func _physics_process(delta):
	snap = Vector3.DOWN
	if is_on_floor():
		vel.y = 0.0
		snap = -get_floor_normal()
	else:
		snap = Vector3.DOWN
	apply_slope()
	apply_move_acceleration(delta)
	if jump_request and is_on_floor():
		apply_jump()
	#elif not is_on_floor():
	else:
		jump_request = false
		apply_gravity(delta)
	#vel = move_and_slide(move_input, Vector3.UP, true, 4, 1.22)
	vel = move_and_slide_with_snap(move_input, snap, Vector3.UP, true, 4, 0.6)
	

func apply_slope() -> void:
	# TODO: rotate movement input to be on the plane of a slope
	var slides = get_slide_count()
	if slides == 0:
		return
	for i in range(slides):
		var col = get_slide_collision(i)
		floor_y = col.normal.y
		if floor_y < min_floor_y:
			move_input.x = 0
			move_input.z = 0

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
	var grav_dir = snap.normalized() * max_fall_speed
	# TDOO: handle vertical and horizontal vel separately (float and vector2) 
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

func shoot_ray(dmg: float) -> void:
	cam_ray.force_raycast_update()
	if not cam_ray.is_colliding():
		return
	var col = cam_ray.get_collider()
	if col is Enemy:
		col.damage(dmg)
	elif col is MolotovProjectile:
		col.explode()
