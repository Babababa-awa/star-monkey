extends Node3D
class_name StarMonkeyMeshExploder

@export var explode_delta: float = 1.0
@export var fade_delta: float = 0.5

var is_exploding: bool = false
var current_delta: float = 0.0

var _pieces: Array[MeshInstance3D] = []
var _velocities: Array[Vector3] = []
var _materials: Array[StandardMaterial3D] = []

func reset() -> void:
	_reset_explosion()

func _reset_explosion() -> void:
	if not is_exploding:
		return
		
	is_exploding = false
		
	for piece: MeshInstance3D in _pieces:
		piece.queue_free()
	
	_pieces.clear()
	_velocities.clear()
	_materials.clear()

func explode(sources: Array[MeshInstance3D], strength: float) -> void:
	if is_exploding:
		return
	
	for source: MeshInstance3D in sources:
		if not source.visible:
			continue
			
		var mesh: Mesh = source.mesh
		
		if mesh == null:
			return
			
		var array_mesh: ArrayMesh = _to_array_mesh(mesh)
		if array_mesh.get_surface_count() == 0:
			return
			
		is_exploding = true
		current_delta = 0.0
		
		for surface_idx: int in array_mesh.get_surface_count():
			var data: MeshDataTool = MeshDataTool.new()
			if data.create_from_surface(_to_array_mesh(mesh), surface_idx) != OK:
				continue
			
			var surface_material: StandardMaterial3D = _duplicate_surface_material(source, array_mesh, surface_idx)
			var has_uv: bool = (data.get_format() & Mesh.ARRAY_FORMAT_TEX_UV) != 0

			for face: int in data.get_face_count():
				var tool: SurfaceTool = SurfaceTool.new()
				tool.begin(Mesh.PRIMITIVE_TRIANGLES)
				
				if surface_material != null:
					tool.set_material(surface_material)
				
				for corner: int in 3:
					var index: int = data.get_face_vertex(face, corner)
					
					tool.set_normal(data.get_vertex_normal(index))
					
					if has_uv:
						tool.set_uv(data.get_vertex_uv(index))
						
					tool.add_vertex(data.get_vertex(index))

				var piece: MeshInstance3D = MeshInstance3D.new()
				piece.mesh = tool.commit()
				
				add_child(piece)
				
				piece.global_transform = source.global_transform
				piece.reset_physics_interpolation()
				
				_pieces.append(piece)
				
				var normal: Vector3 = source.global_transform.basis * data.get_face_normal(face)
				var scatter: Vector3 = Vector3(
					randf_range(-1.0, 1.0),
					randf_range(-1.0, 1.0),
					randf_range(-1.0, 1.0)
				)
				normal = (normal + scatter * 0.35).normalized()
				
				_velocities.append(normal * randf_range(strength, strength + 2.0) + Vector3(0.0, 1.5, 0.0))

		source.visible = false

func _to_array_mesh(mesh: Mesh) -> ArrayMesh:
	var array_mesh: ArrayMesh = mesh as ArrayMesh
	
	if array_mesh != null:
		return array_mesh
		
	var tool: SurfaceTool = SurfaceTool.new()
	tool.create_from(mesh, 0)
	return tool.commit()
	
func _duplicate_surface_material(
	source: MeshInstance3D, 
	array_mesh: ArrayMesh, 
	surface_idx: int
) -> StandardMaterial3D:
	var material: Material = source.get_active_material(surface_idx)
	
	if material == null:
		material = array_mesh.surface_get_material(surface_idx)
		
	if material is StandardMaterial3D:
		var duplicated: StandardMaterial3D = (material as StandardMaterial3D).duplicate()
		duplicated.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		duplicated.albedo_color.a = 1.0
		
		_materials.append(duplicated)
		
		return duplicated
		
	return null

func _physics_process(delta: float) -> void:
	if not is_exploding:
		return
		
	current_delta += delta
	
	if current_delta > explode_delta:
		_reset_explosion()
		return
	
	if not _materials.is_empty():
		var current_fade_delta = explode_delta - fade_delta
		if current_delta > current_fade_delta:
			current_fade_delta = current_delta - current_fade_delta
		else:
			current_fade_delta = 0.0
			
		var fade_weight = minf(1.0, current_fade_delta / fade_delta)
		
		if fade_weight > 0.0:
			var alpha: float = lerpf(1.0, 0.0, fade_weight)
			for material: StandardMaterial3D in _materials:
				material.albedo_color.a = alpha
	
	var gravity: float = StarMonkey.gravity / 2
	
	for i: int in _pieces.size():
		_velocities[i].y -= gravity * delta
		_pieces[i].global_position += _velocities[i] * delta
		
