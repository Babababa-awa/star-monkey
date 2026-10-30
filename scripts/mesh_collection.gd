extends Node3D
class_name StarMonkeyMeshCollection

var _meshes: Array[MeshInstance3D] = []

func _ready() -> void:
	_collect_meshes(self)

func show_meshes() -> void:
	for mesh: MeshInstance3D in _meshes:
		mesh.visible = true
		
func hide_meshes() -> void:
	for mesh: MeshInstance3D in _meshes:
		mesh.visible = false

func _collect_meshes(node: Node) -> void:
	var mesh_instance: MeshInstance3D = node as MeshInstance3D
	
	if mesh_instance != null:
		_meshes.append(mesh_instance)
		
	for child: Node in node.get_children():
		_collect_meshes(child)

func get_meshes() -> Array[MeshInstance3D]:
	return _meshes

func set_material_overlay(material: Material) -> void:
	for mesh: MeshInstance3D in _meshes:
		mesh.material_overlay = material
		
func clear_material_overlay() -> void:
	for mesh: MeshInstance3D in _meshes:
		mesh.material_overlay = null
