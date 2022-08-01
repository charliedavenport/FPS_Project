extends KinematicBody
class_name Enemy

export var MAX_HEALTH: float = 100.0
export var fire_dmg: float = 5.0
export var fire_tic: float = 0.25
export var fire_duration: float = 4.0
export var speed: float = 2.5
export var gravity: float = 0.25
export var damage: float = 5.0
export var avoid_zombie_amount: float = 0.5
export var max_nearby_zombies: int = 0
export var nav_update_delay: float = 1.0

var health : float
var is_on_fire : bool
var nav_target : Spatial
var dmg_target
var vel : Vector3
var flipped : bool
var audio_ind : int
var nearby_enemies = []
var vel_offset_angle : float
var target_pos : Vector3

onready var rng = RandomNumberGenerator.new()
onready var fireTimer = get_node("FireTimer")
onready var anim = get_node("AnimationPlayer")
onready var fireAnim = get_node("FireAnimationPlayer")
onready var dmgAnim = get_node("DmgAnimationPlayer")
onready var navAgent = get_node("NavigationAgent")
onready var hurtBox = get_node("HurtBox")
onready var dmgTimer = get_node("DmgTimer")
onready var groundRayCast = get_node("GroundRayCast")
onready var mesh = get_node("MeshInstance")
onready var audio_stream = get_node("AudioStreamPlayer3D")
onready var audio_timer = get_node("AudioTimer")
onready var nav_update_timer = get_node("NavUpdateTimer")
onready var nearby_enemies_area = get_node("NearbyEnemiesArea")
onready var player_cam = get_viewport().get_camera()

const audio_files = [
	"res://Assets/Sound/zombies/zombie-1.wav",
	"res://Assets/Sound/zombies/zombie-2.wav",
	"res://Assets/Sound/zombies/zombie-3.wav",
	"res://Assets/Sound/zombies/zombie-4.wav",
	"res://Assets/Sound/zombies/zombie-5.wav",
	"res://Assets/Sound/zombies/zombie-6.wav",
	"res://Assets/Sound/zombies/zombie-7.wav",
	"res://Assets/Sound/zombies/zombie-8.wav",
	"res://Assets/Sound/zombies/zombie-9.wav",
	"res://Assets/Sound/zombies/zombie-10.wav",
	"res://Assets/Sound/zombies/zombie-11.wav",
	"res://Assets/Sound/zombies/zombie-12.wav",
	"res://Assets/Sound/zombies/zombie-13.wav",
	"res://Assets/Sound/zombies/zombie-14.wav",
	"res://Assets/Sound/zombies/zombie-15.wav",
	"res://Assets/Sound/zombies/zombie-16.wav",
	"res://Assets/Sound/zombies/zombie-17.wav",
	"res://Assets/Sound/zombies/zombie-18.wav",
	"res://Assets/Sound/zombies/zombie-19.wav",
	"res://Assets/Sound/zombies/zombie-20.wav",
	"res://Assets/Sound/zombies/zombie-21.wav",
	"res://Assets/Sound/zombies/zombie-22.wav",
	"res://Assets/Sound/zombies/zombie-23.wav",
	"res://Assets/Sound/zombies/zombie-24.wav"
]

signal dmg_player(dmg)

func _ready():
	rng.randomize()
	vel = Vector3.ZERO
	health = 100.0
	anim.play("Idle")
	fireAnim.play("not_on_fire")
	fireTimer.wait_time = fire_tic
	is_on_fire = false
	target_pos = global_transform.origin
	nav_update_delay = rng.randf_range(nav_update_delay - 0.5, nav_update_delay + 0.5)
	hurtBox.connect("body_entered", self, "on_hurtbox_entered")
	hurtBox.connect("body_exited", self, "on_hurtbox_exited")
	nearby_enemies_area.connect("body_entered", self, "on_nearby_enemy_entered")
	nearby_enemies_area.connect("body_exited", self, "on_nearby_enemy_exited")
	navAgent.connect("velocity_computed", self, "on_nav_velocity_computed")
	do_zombie_audio()

func _process(delta):
	var enemy_to_player = (player_cam.global_transform.origin - global_transform.origin).normalized()
	var forward_dir = transform.basis.z.normalized()
	var enemy_to_player_2D = Vector2(enemy_to_player.x, enemy_to_player.z)
	var forward_dir_2D = Vector2(forward_dir.x, forward_dir.z)
	var angle = forward_dir_2D.angle_to(enemy_to_player_2D)
	var v_frame := 0
	if (angle < -3.0 * PI / 4.0) or (angle > 3.0 * PI / 4.0):
		v_frame = 2 # behind
	elif angle > PI / 4.0:
		v_frame = 3 # right
	elif angle > -1.0 * PI / 4.0:
		v_frame = 0 # front
	elif angle > -3.0 * PI / 4.0:
		v_frame = 1 # left
	mesh.get_surface_material(0).set_shader_param("v_frame", v_frame)

func _physics_process(delta):
	apply_gravity()
	if not nav_target:
		return
	var current_pos = global_transform.origin
	#var target_pos = navAgent.get_next_location()
	var move_vel_offset = (target_pos - current_pos).normalized() * speed
	vel.x = move_vel_offset.x
	vel.z = move_vel_offset.z
	avoid_zombies()
	vel = move_and_slide(vel)
	#navAgent.set_velocity(vel)

func on_nav_velocity_computed(safe_velocity) -> void:
	vel = move_and_slide(safe_velocity)

func apply_gravity() -> void:
	groundRayCast.force_raycast_update()
	if groundRayCast.is_colliding():
		var col = groundRayCast.get_collider()
		if col.collision_layer == 2:
			vel.y = 0.0
	vel.y -= gravity

func avoid_zombies() -> void:
	var angle_sum: float
	for zombie in nearby_enemies:
		var offset = zombie.global_transform.origin - global_transform.origin
		var offset_2D = Vector2(offset.x, offset.z).normalized()
		var forward_dir_2D = Vector2(vel.x, vel.z).normalized()
		var angle = forward_dir_2D.angle_to(offset_2D)
		if abs(angle) < TAU / 4.0:
			angle_sum += angle
	vel_offset_angle = lerp(vel_offset_angle, angle_sum, 0.2)
	vel = vel.rotated(Vector3.UP, vel_offset_angle * avoid_zombie_amount)

func kill() -> void:
	queue_free()

func take_damage(dmg_amt: float) -> void:
	if dmg_amt == 0:
		return
	dmgAnim.play("damaged")
	health -= dmg_amt
	if health <= 0.0:
		kill()

func fire_damage() -> void:
#	if is_on_fire:
#		return
	is_on_fire = true
	var tics = int(fire_duration/fire_tic)
	fireAnim.play("on_fire")
	for i in range(tics):
		take_damage(fire_dmg)
		fireTimer.start()
		yield(fireTimer, "timeout")
		#print("ouch!")
	fireAnim.play("not_on_fire")
	is_on_fire = false

func start_attacking() -> void:
	while dmg_target:
#		if dmg_target.has_method("take_dmg"):
#			dmg_target.take_dmg(damage)
		emit_signal("dmg_player", damage)
		dmgTimer.start()
		yield(dmgTimer, "timeout")

func start_updating_target_pos() -> void:
	nav_update_timer.wait_time = nav_update_delay
	while nav_target:
		navAgent.set_target_location(nav_target.global_transform.origin)
		target_pos = navAgent.get_next_location()
		nav_update_timer.start()
		yield(nav_update_timer, "timeout")

func set_nav_target(target : Node) -> void:
	nav_target = target
	start_updating_target_pos()

func clear_nav_target() -> void:
	nav_target = null

func on_hurtbox_entered(body) -> void:
	if body.name == "Player":
		dmg_target = body
		start_attacking()

func on_hurtbox_exited(body) -> void:
	if dmg_target == body:
		dmg_target = null

func on_nearby_enemy_entered(body) -> void:
	if not nearby_enemies.has(body) and len(nearby_enemies) < max_nearby_zombies:
		nearby_enemies.append(body)

func on_nearby_enemy_exited(body) -> void:
	if nearby_enemies.has(body):
		nearby_enemies.erase(body)

func set_flipped(val: bool) -> void:
	mesh.get_surface_material(0).set_shader_param("flipped", val)

func do_zombie_audio() -> void:
	audio_ind = rng.randi_range(0, 23)
	var zombie_sound = load(audio_files[audio_ind % len(audio_files)])
	audio_stream.stream = zombie_sound
	while true:
		audio_timer.wait_time = rng.randf_range(1.0, 3.5)
		audio_timer.start()
		yield(audio_timer, "timeout")
		audio_stream.play()
		yield(audio_stream, "finished")
