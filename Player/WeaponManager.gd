extends Node
class_name WeaponManager

class WeaponInfo:
	var name: String 
	var root_node: Node
	func _init(_name, _root_node):
		name = _name
		root_node = _root_node

export var molotov_node: NodePath
export var bolt_rifle_node: NodePath
export var pistol_node: NodePath

var active_weapon: int
var weapons

func _ready() -> void:
	#var molotov_node = get_node("../PlayerHUD/PlayerHands/MolotovWeapon")
	#var bolt_rifle_node = get_node("../PlayerHUD/PlayerHands/BoltRifleWeapon")
	weapons = [WeaponInfo.new("Bolt Rifle", get_node(bolt_rifle_node)),
			   WeaponInfo.new("Molotov", get_node(molotov_node)),
			   WeaponInfo.new("Pistol", get_node(pistol_node))]
	yield(get_tree(), "idle_frame")
	hide_all()
	active_weapon = -1
	select_weapon(0)

func hide_all() -> void:
	for w in weapons:
		w.root_node.visible = false
		w.root_node.set_process(false)

func select_weapon(_index: int) -> void:
	if _index >= len(weapons) or _index == active_weapon:
		return
	weapons[active_weapon].root_node.set_process(false)
	weapons[active_weapon].root_node.visible = false
	active_weapon = _index
	weapons[active_weapon].root_node.set_process(true)
	weapons[active_weapon].root_node.visible = true
	weapons[active_weapon].root_node.enable()

func get_weapon_by_name(_name: String) -> WeaponInfo:
	for w in weapons:
		if w.name.to_lower() == _name.to_lower():
			return w
	return null

func _input(event):
	if event.is_action_pressed("weapon_1"):
		select_weapon(0)
	elif event.is_action_pressed("weapon_2"):
		select_weapon(1)
	elif event.is_action_pressed("weapon_3"):
		select_weapon(2)
		
