extends Spatial

onready var player = get_node("Player")

func _ready():
	for child in $Navigation.get_children():
		if child is Enemy:
			child.set_nav_target(player)
