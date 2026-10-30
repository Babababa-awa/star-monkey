extends StarMonkeyMeshCollection
class_name StarMonkeyUnitMeshCollection

@export var damage_color: Color = Color(1.0, 0.0, 0.0, 1.0)
@export var damage_delta: float = 0.12

@export var shield_color: Color = Color(0.0, 0.5, 1.0, 1.0)
@export var shield_delta: float = 0.12

var _overlay: StandardMaterial3D

var _time_left: float = 0.0
var _active_delta: float = 0.0
var _active_color: Color = Color(0.0, 0.0, 0.0, 0.0)

func _ready() -> void:
	super._ready()
	
	_overlay = StandardMaterial3D.new()
	_overlay.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_overlay.albedo_color = damage_color

func damage() -> void:
	_time_left = damage_delta
	_active_color = damage_color
	_active_delta = damage_delta
	
	_overlay.albedo_color = damage_color
	for mesh_instance: MeshInstance3D in _meshes:
		mesh_instance.material_overlay = _overlay

func shield() -> void:
	_time_left = shield_delta
	_active_color = shield_color
	_active_delta = shield_delta
	
	_overlay.albedo_color = damage_color
	for mesh_instance: MeshInstance3D in _meshes:
		mesh_instance.material_overlay = _overlay

func _process(delta: float) -> void:
	if _time_left <= 0.0:
		return

	_time_left -= delta
	
	var weight: float = clampf(_time_left / _active_delta, 0.0, 1.0)
	var color: Color = _active_color
	color.a = weight
	_overlay.albedo_color = color

	if _time_left <= 0.0:
		for mesh_instance: MeshInstance3D in _meshes:
			mesh_instance.material_overlay = null
