extends Spatial

onready var player = get_node("Player")

func _ready():
	player.spawn_location = get_node("PlayerSpawn")
	for child in $Navigation/Enemies.get_children():
		if child is Enemy:
			child.set_nav_target(player)
			child.connect("dmg_player", player, "take_dmg")
