extends StarMonkeyLevel
class_name StarMonkeyChunkLevel

@export var chunk_type: ChunkType = ChunkType.LINE
@export var chunk_size: Vector3i = Vector3i(32, 24, 32)
@export var chunk_map_size: Vector3i = Vector3i(1, 1, 48)
@export var chunk_load_radius: int = 5
@export var chunk_process_radius: int = 3
@export var max_concurrent_loads: int = 3

@export_subgroup("Enemies")
@export var total_enemy_count: int = -1

enum ChunkType {
	LINE,
	LINE_REPEATING,
	GRID,
	GRID_REPEATING,
	WORLD,
	WORLD_REPEATING,
}

var _chunk_states: Dictionary[Vector3i, StarMonkeyChunkState] = {}
var _loaded_chunks: Dictionary[Vector3i, Node] = {}
var _loading_chunks: Dictionary[Vector3i, String] = {}

func _ready() -> void:
	super._ready()
	
	_load_chunks(
		_get_player_chunk_coord(),
		false
	)

func _process(delta: float) -> void:
	var player_chunk_coord: Vector3i = _get_player_chunk_coord()
	
	_load_chunks(player_chunk_coord, false)
	_poll_loading_chunks()
	_unload_distant_chunks(player_chunk_coord)
	_update_chunk_processing(player_chunk_coord)
	
func _get_player_chunk_coord() -> Vector3i:
	if not is_instance_valid(StarMonkey.player):
		return Vector3i(0, 0, 0)
	
	var player_position: Vector3 = StarMonkey.player.global_position
	# Since chunkes are centered
	player_position += (chunk_size / 2.0)
	
	match chunk_type:
		ChunkType.LINE, \
		ChunkType.LINE_REPEATING:
			return Vector3i(
				0,
				0,
				floori(player_position.z / chunk_size.z),
			)
		ChunkType.GRID, \
		ChunkType.GRID_REPEATING:
			return Vector3i(
				floori(player_position.x / chunk_size.x),
				0,
				floori(player_position.z / chunk_size.z),
			)
		ChunkType.WORLD, \
		ChunkType.WORLD_REPEATING:
			return Vector3i(
				floori(player_position.x / chunk_size.x),
				floori(player_position.y / chunk_size.y),
				floori(player_position.z / chunk_size.z),
			)
		
	return Vector3i(0, 0, 0)
			
func _load_chunks(center: Vector3i, request: bool = false) -> void:
	if _loading_chunks.size() >= max_concurrent_loads:
		return
		
	var x_range: Array
	var y_range: Array
	var z_range: Array
	
	match chunk_type:
		ChunkType.LINE, \
		ChunkType.LINE_REPEATING:
			x_range = [0]
			y_range = [0]
			z_range = range(center.z + 1, center.z - chunk_load_radius - 1, -1)
		ChunkType.GRID, \
		ChunkType.GRID_REPEATING:
			x_range = range(center.x - chunk_load_radius, center.x + chunk_load_radius + 1)
			y_range = [0]
			z_range = range(center.z + chunk_load_radius, center.z - chunk_load_radius - 1, -1)
		ChunkType.WORLD, \
		ChunkType.WORLD_REPEATING:
			x_range = range(center.x - chunk_load_radius, center.x + chunk_load_radius + 1)
			y_range = range(center.y - chunk_load_radius, center.y + chunk_load_radius + 1)
			z_range = range(center.z + chunk_load_radius, center.z - chunk_load_radius - 1, -1)

	#print(center, ": (", x_range, ", ", y_range, ", ", z_range, ")")
	for x in x_range:
		for y in y_range:
			for z in z_range:
				_load_chunk(Vector3i(x, y, z))
				
				if request and _loading_chunks.size() >= max_concurrent_loads:
					return
				
func _load_chunk(coord: Vector3i, request: bool = false) -> void:
	var path_coord: Vector3i = coord
	
	match chunk_type:
		ChunkType.LINE:
			if coord.z > 0 or coord.z <= -chunk_map_size.z:
				return
				
			path_coord.z = -path_coord.z 
		ChunkType.LINE_REPEATING:
			path_coord.z = posmod(-coord.z, chunk_map_size.z)
		ChunkType.GRID:
			if coord.x < 0 or coord.x >= chunk_map_size.x:
				return
				
			if coord.z > 0 or coord.z <= chunk_map_size.z:
				return
				
			path_coord.z = -path_coord.z 
		ChunkType.GRID_REPEATING:
			path_coord.x = posmod(coord.x, chunk_map_size.x)
			path_coord.z = posmod(-coord.z, chunk_map_size.z)
		ChunkType.WORLD:
			if coord.x < 0 or coord.x >= chunk_map_size.x:
				return
				
			if coord.y < 0 or coord.y >= chunk_map_size.y:
				return
			
			if coord.z > 0 or coord.z <= chunk_map_size.z:
				return
			
			path_coord.z = -path_coord.z 
		ChunkType.WORLD_REPEATING:
			path_coord.x = posmod(coord.x, chunk_map_size.x)
			path_coord.y = posmod(coord.y, chunk_map_size.y)
			path_coord.z = posmod(-coord.z, chunk_map_size.z)

	if _loaded_chunks.has(coord) or _loading_chunks.has(coord):
		return

	var path: String = StarMonkey.get_real_path(
		"/scenes/levels/" + StarMonkey.current_level + "/chunks/"
	)
	
	match chunk_type:
		ChunkType.LINE, \
		ChunkType.LINE_REPEATING:
			path += "level_chunk_%d.tscn" % path_coord.z
		ChunkType.GRID, \
		ChunkType.GRID_REPEATING:
			path += "level_chunk_%d_%d.tscn" % [path_coord.x, path_coord.z]
		ChunkType.WORLD, \
		ChunkType.WORLD_REPEATING:
			path += "level_chunk_%d_%d_%d.tscn" % [path_coord.x, path_coord.y, path_coord.z]
	
	if not ResourceLoader.exists(path):
		return

	if request:
		var error: Error = ResourceLoader.load_threaded_request(path, "PackedScene")
		if error == OK:
			_loading_chunks[coord] = path
	else:
		var scene: PackedScene = load(path)
		var node: StarMonkeyLevelChunk = scene.instantiate()
		if chunk_process_radius < chunk_load_radius:
			node.process_mode = Node.PROCESS_MODE_DISABLED
		node.position = coord * chunk_size
		if node is StarMonkeyGroundLevelChunk:
			node.position.y -= (chunk_size.y / 2.0)
		if not _chunk_states.has(path_coord):
			_chunk_states[path_coord] = StarMonkeyChunkState.new()
		node.set_chunk_state(_chunk_states[path_coord])
		%Chunks.add_child.call_deferred(node)
		_loaded_chunks[coord] = node

func _poll_loading_chunks() -> void:
	var finished: Array[Vector3i] = []
	
	for coord: Vector3i in _loading_chunks:
		var path: String = _loading_chunks[coord]
		var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(path)

		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var scene: PackedScene = ResourceLoader.load_threaded_get(path)
			var node: Node = scene.instantiate()
			if chunk_process_radius < chunk_load_radius:
				node.process_mode = Node.PROCESS_MODE_DISABLED
			node.position = coord * chunk_size
			if node is StarMonkeyGroundLevelChunk:
				node.position.y -= (chunk_size.y / 2.0)
			var chunk_coord: Vector3i = Vector3i(
				posmod(coord.x, chunk_map_size.x),
				posmod(coord.y, chunk_map_size.y),
				posmod(-coord.z, chunk_map_size.z)
			)
			if not _chunk_states.has(chunk_coord):
				_chunk_states[chunk_coord] = StarMonkeyChunkState.new()
			node.set_chunk_state(_chunk_states[chunk_coord])
			%Chunks.add_child.call_deferred(node)
			_loaded_chunks[coord] = node
			finished.append(coord)
		elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_warning("Failed to load chunk: %s" % path)
			finished.append(coord)

	for coord in finished:
		_loading_chunks.erase(coord)

func _unload_distant_chunks(center: Vector3i) -> void:
	var to_remove: Array[Vector3i] = []
	
	# Add one so if on the edge its not loading and unloading constantly.
	var chunk_unload_radius: int = chunk_load_radius + 1
	
	for coord: Vector3i in _loaded_chunks:
		var unload: bool = false
		
		match chunk_type:
			ChunkType.LINE, \
			ChunkType.LINE_REPEATING:
				var z_min: int = center.z - chunk_unload_radius
				var z_max: int = center.z + 1
				if coord.z < z_min or coord.z > z_max:
					unload = true
			ChunkType.GRID, \
			ChunkType.GRID_REPEATING:
				var x_min: int = center.x - chunk_unload_radius
				var x_max: int = center.x + chunk_unload_radius
				var z_min: int = center.z - chunk_unload_radius
				var z_max: int = center.z + chunk_unload_radius
				if coord.x < x_min or coord.x > x_max or coord.z < z_min or coord.z > z_max:
					unload = true
			ChunkType.WORLD, \
			ChunkType.WORLD_REPEATING:
				var x_min: int = center.x - chunk_unload_radius
				var x_max: int = center.x + chunk_unload_radius
				var y_min: int = center.y - chunk_unload_radius
				var y_max: int = center.y + chunk_unload_radius
				var z_min: int = center.z - chunk_unload_radius
				var z_max: int = center.z + chunk_unload_radius
				if (coord.x < x_min or coord.x > x_max or
					coord.y < y_min or coord.y > y_max or
					coord.z < z_min or coord.z > z_max
				):
					unload = true
		
		if unload:
			to_remove.append(coord)

	for coord in to_remove:
		var node: Node = _loaded_chunks[coord]
		if is_instance_valid(node):
			node.queue_free()
		_loaded_chunks.erase(coord)

func _update_chunk_processing(center: Vector3i, request: bool = false) -> void:
	if chunk_process_radius >= chunk_load_radius:
		return
		
	var x_range: Array
	var y_range: Array
	var z_range: Array
	
	match chunk_type:
		ChunkType.LINE, \
		ChunkType.LINE_REPEATING:
			x_range = [0]
			y_range = [0]
			z_range = range(center.z + 1, center.z - chunk_process_radius - 1, -1)
		ChunkType.GRID, \
		ChunkType.GRID_REPEATING:
			x_range = range(center.x - chunk_process_radius, center.x + chunk_process_radius + 1)
			y_range = [0]
			z_range = range(center.z + chunk_process_radius, center.z - chunk_process_radius - 1, -1)
		ChunkType.WORLD, \
		ChunkType.WORLD_REPEATING:
			x_range = range(center.x - chunk_process_radius, center.x + chunk_process_radius + 1)
			y_range = range(center.y - chunk_process_radius, center.y + chunk_process_radius + 1)
			z_range = range(center.z + chunk_process_radius, center.z - chunk_process_radius - 1, -1)
	
	var coords: Array[Vector3i] = []
	
	for x in x_range:
		for y in y_range:
			for z in z_range:
				coords.append(Vector3i(x, y, z))
	
	for coord in _loaded_chunks.keys():
		if coords.has(coord):
			_loaded_chunks[coord].process_mode = Node.PROCESS_MODE_INHERIT
		else:
			_loaded_chunks[coord].process_mode = Node.PROCESS_MODE_DISABLED
		
				
				

func has_killed_all_enemies() -> bool:
	# In theory a player could avoid loading a chunk with enemies and they 
	# wouldn't be accounted for, so for levels that aren't a line, use 
	# total_enemy_count instead.
	
	if total_enemy_count > 0:
		var killed_enemy_count: int = 0
		
		for chunk_state: StarMonkeyChunkState in _chunk_states.values():
			killed_enemy_count += chunk_state.killed_enemies.size()
			
		return killed_enemy_count == total_enemy_count
		
	for chunk_state: StarMonkeyChunkState in _chunk_states.values():
		if chunk_state.total_enemy_count != chunk_state.killed_enemies.size():
			return false
		
	return true
