@tool
extends Node3D
class_name StarMonkeyBuilding

@export var vertical_side: PackedScene = null
@export var horizontal_side: PackedScene = null
@export var side_size: Vector2 = Vector2(4.0, 4.0)
@export var size: Vector3i = Vector3i(1, 4, 1):
	set(value):
		size = value
		_update_debug_mesh()

var floors: Array[Array] = []
var roof: Array[Node3D] = []
var destroyed_counts: Array[int] = []
var destroyed_set: Dictionary = {}

var _debug_mesh: MeshInstance3D = null

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		_ensure_debug_mesh()

func _exit_tree() -> void:
	if _debug_mesh:
		_debug_mesh.queue_free()
		_debug_mesh = null
		
func _ensure_debug_mesh() -> void:
	if _debug_mesh:
		return

	_debug_mesh = MeshInstance3D.new()
	_debug_mesh.name = "DebugMesh"
	_debug_mesh.position.y = size.y * side_size.x / 2.0

	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size * Vector3i(side_size.x, side_size.y, side_size.x)
	_debug_mesh.mesh = mesh

	var material: StandardMaterial3D = _get_debug_mesh_material()
	if material != null:
		_debug_mesh.material_override = material

	add_child(_debug_mesh)
	_debug_mesh.owner = null
	
func _get_debug_mesh_material() -> StandardMaterial3D:
	if vertical_side == null:
		return null
	
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = _string_to_color(vertical_side.resource_path)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material
	
func _string_to_color(text: String) -> Color:
	var hash_value: int = abs(text.hash())
	var hue: float = float(hash_value % 360) / 360.0
	var saturation: float = 0.55 + float((hash_value >> 8) % 45) / 100.0
	var lightness: float = 0.55 + float((hash_value >> 16) % 35) / 100.0
	return Color.from_ok_hsl(hue, saturation, lightness)

func _update_debug_mesh() -> void:
	if not is_instance_valid(_debug_mesh):
		return

	_debug_mesh.mesh.size = size * Vector3i(side_size.x, side_size.y, side_size.x)
	_debug_mesh.position.y = size.y * side_size.x / 2.0

func _ready() -> void:
	if not Engine.is_editor_hint():
		_build_building()

func reset() -> void:
	for node: Node3D in get_children():
		node.reset()
		
	destroyed_set.clear()
	
	for i: int in destroyed_counts.size():
		destroyed_counts[i] = 0

func _build_building() -> void:
	for i: int in size.y:
		_build_sides(i)
		if i == size.y - 1:
			_build_top()

func _build_sides(y) -> void:
	var sides: Array[Node3D] = []
	
	var z_offset: float = (-size.z * side_size.x / 2.0) + (side_size.x / 2.0)
	
	for z: int in size.z:
		var left: Node3D = vertical_side.instantiate()
		add_child(left)
		left.position.y = (side_size.y * y) + (side_size.y / 2.0)
		left.position.x = side_size.x * size.x / 2.0
		left.position.z = z_offset
		left.destroyed.connect(_on_destroyed)
		sides.append(left)
		
		var right: Node3D = vertical_side.instantiate()
		add_child(right)
		right.position.y = (side_size.y * y) + (side_size.y / 2.0)
		right.position.x = -side_size.x * size.x / 2.0
		right.position.z = z_offset
		right.rotation_degrees.y += 180
		right.destroyed.connect(_on_destroyed)
		sides.append(right)
		
		z_offset += side_size.x
	
	var x_offset: float = (-size.x * side_size.x / 2.0) + (side_size.x / 2.0)
	
	for x: int in size.x:
		var forward: Node3D = vertical_side.instantiate()
		add_child(forward)
		forward.position.x = x_offset
		forward.position.y = (side_size.y * y) + (side_size.y / 2.0)
		forward.position.z = -side_size.x * size.z / 2.0
		forward.rotation_degrees.y += 90
		forward.destroyed.connect(_on_destroyed)
		sides.append(forward)
		
		var back: Node3D = vertical_side.instantiate()
		add_child(back)
		back.position.x = x_offset
		back.position.y = (side_size.y * y) + (side_size.y / 2.0)
		back.position.z = side_size.x * size.z / 2.0
		back.rotation_degrees.y += 270
		back.destroyed.connect(_on_destroyed)
		sides.append(back)
		
		x_offset += side_size.x
		
	floors.append(sides)
	destroyed_counts.append(0)
	
func _build_top() -> void:
	var z_offset: float = (-size.z * side_size.x / 2.0) + (side_size.x / 2.0)
	
	
	for z: int in size.z:
		var x_offset: float = (-size.x * side_size.x / 2.0) + (side_size.x / 2.0)
		
		for x: int in size.x:
			var top: Node3D = horizontal_side.instantiate()
			add_child(top)
			top.position.x = x_offset
			top.position.y = size.y * side_size.y
			top.position.z = z_offset
			roof.append(top)
			
			x_offset += side_size.x
			
		z_offset += side_size.x

func destroy(level: int = 0) -> void:
	StarMonkey.sfx.play_collapse()
	_collapse_from(level)

func _on_destroyed(node: Node3D) -> void:
	if destroyed_set.has(node):
		return
		
	destroyed_set[node] = true
	
	for level: int in floors.size():
		if floors[level].has(node):
			destroyed_counts[level] += 1
			
			if destroyed_counts[level] >= roundi(floors[level].size() / 2.0):
				StarMonkey.sfx.play_collapse()
				_collapse_from(level)
				if level == 0:
					StarMonkey.score += 500
				
			return

func _collapse_from(start_level: int) -> void:
	for level: int in range(start_level, floors.size()):
		for side: Node3D in floors[level]:
			if is_instance_valid(side) and not destroyed_set.has(side):
				side.destroy(true)
	
	for top: Node3D in roof:
		if is_instance_valid(top) and not destroyed_set.has(top):
			top.destroy(true)
