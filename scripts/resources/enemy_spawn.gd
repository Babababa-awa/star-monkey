extends Resource
class_name StarMonkeyEnemySpawn

# "/scenes/units/enemies/flying_shooter_sp.tscn
const FLYING_SHOOTER_SP = preload("uid://b6cyugl80etmh")

@export var alias: StringName
@export var enemy: StarMonkey.Enemies
@export var weapon: StarMonkey.Weapons
@export var weapon_cooldown: float = -1.0
@export var weapon_shot_follow_speed: float = -1.0

@export_group("Movement")
@export var move_speed: float = -1.0

@export_group("Position")
@export_node_path("Marker3D") var marker: NodePath
@export_node_path("PathFollow3D") var path_follow: NodePath
@export_range(0.0, 1.0, 0.05) var path_progress_ratio: float = 0.0
@export var path_follow_reverse_loop: bool = false

var _node: Node3D = null

func spawn(parent: Node3D) -> void:
	var node: StarMonkeyEnemy

	match enemy:
		StarMonkey.Enemies.FLYING_SHOOTER_SP:
			node = FLYING_SHOOTER_SP.instantiate()
			if "_on_enemy_kill_after" in parent:
				node.kill_after.connect(parent._on_enemy_kill_after.bind(alias), CONNECT_ONE_SHOT)
			
			if move_speed > 0.0:
				node.move_speed = move_speed
			
			if weapon != StarMonkey.Weapons.NONE:
				node.current_weapon = weapon
				
			if weapon_cooldown > 0.0:
				node.pulse_cannon_cooldown = weapon_cooldown
				
			if weapon_shot_follow_speed > 0.0:
				node.pulse_shot_follow_speed = weapon_shot_follow_speed
			
			var path_follow_node: PathFollow3D = parent.get_node_or_null(path_follow)
			if path_follow_node != null:
				path_follow_node.progress_ratio = path_progress_ratio
				node.path_follow = path_follow_node
				if path_follow_reverse_loop:
					node.path_follow_reverse_loop = path_follow_reverse_loop
					path_follow_node.loop = false
				
				node.position = path_follow_node.get_parent().position + path_follow_node.position
			else:
				node.position = parent.get_node(marker).position
			
			node.rotation_degrees.y = 180
			
			_node = node
			parent.add_child(node)
			node.reset_physics_interpolation()
	
func despawn(parent: Node3D) -> void:
	if is_instance_valid(_node):
		_node.queue_free()
		
	_node = null
