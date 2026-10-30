extends StarMonkeyLevelChunk
class_name StarMonkeyGroundLevelChunk

@export var ground_type: GroundType = GroundType.NONE

enum GroundType {
	NONE,
	LINE,
	LINE_START,
	LINE_END,
	GRID,
	GRID_LEFT,
	GRID_RIGHT,
	GRID_FORWARD,
	GRID_BACK,
	GRID_LEFT_FORWARD,
	GRID_LEFT_BACK,
	GRID_RIGHT_FORWARD,
	GRID_RIGHT_BACK,
}

func _ready() -> void:
	if get_node_or_null("%Ground") == null:
		return
		
	if ground_type == GroundType.NONE:
		%Ground.visible = false
		%Ground.queue_free()
		return
		
	var material: ShaderMaterial = %Ground.get_active_material(0) as ShaderMaterial
	
	match ground_type:
		GroundType.LINE:
			%Ground.mesh.size = Vector2(chunk_size.x * 2, chunk_size.z)
			material.set_shader_parameter("fade_left", true)
			material.set_shader_parameter("fade_right", true)
		GroundType.LINE_START:
			%Ground.mesh.size = Vector2(chunk_size.x * 2, chunk_size.z)
			material.set_shader_parameter("fade_left", true)
			material.set_shader_parameter("fade_right", true)
			material.set_shader_parameter("fade_back", true)
		GroundType.LINE_END:
			%Ground.mesh.size = Vector2(chunk_size.x * 2, chunk_size.z)
			material.set_shader_parameter("fade_left", true)
			material.set_shader_parameter("fade_right", true)
			material.set_shader_parameter("fade_forward", true)
		GroundType.GRID:
			%Ground.mesh.size = Vector2(chunk_size.x, chunk_size.z)
		GroundType.GRID_LEFT:
			%Ground.mesh.size = Vector2(chunk_size.x, chunk_size.z)
			material.set_shader_parameter("fade_left", true)
		GroundType.GRID_RIGHT:
			%Ground.mesh.size = Vector2(chunk_size.x, chunk_size.z)
			material.set_shader_parameter("fade_right", true)
		GroundType.GRID_FORWARD:
			%Ground.mesh.size = Vector2(chunk_size.x, chunk_size.z)
			material.set_shader_parameter("fade_forward", true)
		GroundType.GRID_BACK:
			%Ground.mesh.size = Vector2(chunk_size.x, chunk_size.z)
			material.set_shader_parameter("fade_back", true)
		GroundType.GRID_LEFT_FORWARD:
			%Ground.mesh.size = Vector2(chunk_size.x, chunk_size.z)
			material.set_shader_parameter("fade_left", true)
			material.set_shader_parameter("fade_forward", true)
		GroundType.GRID_LEFT_BACK:
			%Ground.mesh.size = Vector2(chunk_size.x, chunk_size.z)
			material.set_shader_parameter("fade_left", true)
			material.set_shader_parameter("fade_back", true)
		GroundType.GRID_RIGHT_FORWARD:
			%Ground.mesh.size = Vector2(chunk_size.x, chunk_size.z)
			material.set_shader_parameter("fade_right", true)
			material.set_shader_parameter("fade_forward", true)
		GroundType.GRID_RIGHT_BACK:
			%Ground.mesh.size = Vector2(chunk_size.x, chunk_size.z)
			material.set_shader_parameter("fade_right", true)
			material.set_shader_parameter("fade_back", true)
			
