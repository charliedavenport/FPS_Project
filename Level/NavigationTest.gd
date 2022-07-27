extends Spatial

onready var player = get_node("Player")
onready var enemy_root = get_node("Navigation/Enemies")

func _ready():
	player.spawn_location = get_node("PlayerSpawn")
	for child in enemy_root.get_children():
		if child is Enemy:
			child.set_flipped(randf() < 0.5)
			child.set_nav_target(player)
			child.connect("dmg_player", player, "take_dmg")
