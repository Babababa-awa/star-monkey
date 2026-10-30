extends Node3D
class_name StarMonkeyWireframe

@export var normal_threshold: float = 0.99
@export var thickness: float = 0.02
@export var line_offset: float = 0.001
@export var wireframe_color: Color = Color(0.9, 0.87, 0.0, 0.5)
@export var energy: float = 2.0
@export var hide_source_mesh: bool = false

var line_material: StandardMaterial3D = null

func _ready() -> void:
	line_material = _make_line_material()
	
	for node: Node3D in get_children():
		if not node is MeshInstance3D:
			continue
		
		add_wireframe(node)

func add_wireframes(sources: Array[MeshInstance3D], parent: Node3D = null) -> void:
	for source: MeshInstance3D in sources:
		add_wireframe(source)

func add_wireframe(source: MeshInstance3D, parent: Node3D = null) -> void:
	var array_mesh: ArrayMesh = _to_array_mesh(source.mesh)
	
	if array_mesh == null:
		return

	var line_mesh: ArrayMesh = _build_thick_wireframe(array_mesh)
	if line_mesh.get_surface_count() == 0:
		return

	var lines: MeshInstance3D = MeshInstance3D.new()
	lines.mesh = line_mesh
	lines.material_override = line_material
	lines.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	lines.transform = source.transform
	lines.visible = source.visible
	lines.name = "Wireframe_" + source.name
	
	if parent != null:
		parent.add_child(lines)
	else:
		add_child(lines)
		
	if hide_source_mesh:
		source.visible = false

func _to_array_mesh(mesh: Mesh) -> ArrayMesh:
	var array_mesh: ArrayMesh = mesh as ArrayMesh
	
	if array_mesh != null:
		return array_mesh
		
	var tool: SurfaceTool = SurfaceTool.new()
	tool.create_from(mesh, 0)
	return tool.commit()

func _build_thick_wireframe(src: ArrayMesh) -> ArrayMesh:
	var verts: PackedVector3Array = PackedVector3Array()
	var indices: PackedInt32Array = PackedInt32Array()
	var normals: PackedVector3Array = PackedVector3Array()

	var half: float = thickness * 0.5
	
	for surface: int in src.get_surface_count():
		var mdt: MeshDataTool = MeshDataTool.new()
		mdt.create_from_surface(src, surface)
		
		for edge_i: int in mdt.get_edge_count():
			var faces: PackedInt32Array = mdt.get_edge_faces(edge_i)
			var keep: bool = false

			if faces.size() < 2:
				keep = true
			else:
				var n0: Vector3 = mdt.get_face_normal(faces[0])
				var n1: Vector3 = mdt.get_face_normal(faces[1])
				if n0.dot(n1) < normal_threshold:
					keep = true

			if not keep:
				continue

			var v0: Vector3 = mdt.get_vertex(mdt.get_edge_vertex(edge_i, 0))
			var v1: Vector3 = mdt.get_vertex(mdt.get_edge_vertex(edge_i, 1))

			var offset_dir: Vector3 = Vector3.ZERO
			if faces.size() >= 1:
				offset_dir = mdt.get_face_normal(faces[0])
			elif faces.size() >= 2:
				offset_dir = (offset_dir + mdt.get_face_normal(faces[1])).normalized()

			v0 += offset_dir * line_offset
			v1 += offset_dir * line_offset

			var dir: Vector3 = (v1 - v0).normalized()
			var up: Vector3 = Vector3.UP
			if abs(dir.dot(up)) > 0.9:
				up = Vector3.FORWARD
			var side: Vector3 = dir.cross(up).normalized() * half
			var other: Vector3 = dir.cross(side).normalized() * half

			# 4 corners at each end
			var base: int = verts.size()
			var corners: Array[Vector3] = [
				v0 + side + other,
				v0 + side - other,
				v0 - side + other,
				v0 - side - other,
				v1 + side + other,
				v1 + side - other,
				v1 - side + other,
				v1 - side - other,
			]

			for c: Vector3 in corners:
				verts.append(c)
				normals.append(offset_dir)

			# 6 faces (quads)
			var quads: Array = [
				[0,1,5,4], [2,3,7,6], [0,2,6,4],
				[1,3,7,5], [0,1,3,2], [4,5,7,6]
			]
			for q: Array in quads:
				indices.append(base + q[0])
				indices.append(base + q[1])
				indices.append(base + q[2])
				indices.append(base + q[0])
				indices.append(base + q[2])
				indices.append(base + q[3])

	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices

	var result: ArrayMesh = ArrayMesh.new()
	
	if verts.size() > 0:
		result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		
	return result

func _make_line_material() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	mat.albedo_color = wireframe_color
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	if not is_zero_approx(energy):
		mat.emission_enabled = true
		mat.emission_energy_multiplier = energy
		mat.emission = wireframe_color
	return mat
