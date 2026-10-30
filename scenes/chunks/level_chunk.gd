extends Node3D
class_name StarMonkeyLevelChunk

@export var chunk_size: Vector3i = Vector3i(32, 32, 32)
@export var enemy_spawner: StarMonkeyEnemySpawner
@export var spawn_proximity: float = 96.0

var chunk_state: StarMonkeyChunkState = null

var _has_spawned: bool = false

func _process(delta: float) -> void:
	_handle_spawn()
	
func set_chunk_state(chunk_state_: StarMonkeyChunkState) ->void:
	chunk_state = chunk_state_
	if enemy_spawner != null:
		chunk_state.total_enemy_count = enemy_spawner.enemies.size()

func _handle_spawn() -> void:
	if not is_instance_valid(StarMonkey.player) or enemy_spawner == null:
		return
		
	if StarMonkey.level is StarMonkeyChunkLevel:
		if (StarMonkey.level.chunk_type == StarMonkeyChunkLevel.ChunkType.LINE or
			StarMonkey.level.chunk_type == StarMonkeyChunkLevel.ChunkType.LINE_REPEATING
		):
			#print(StarMonkey.player.global_position.z, " -> ", global_position.z + spawn_proximity)
			if StarMonkey.player.global_position.z < global_position.z - (chunk_size.z / 2.0) - 16:
				if _has_spawned:
					_has_spawned = false
					enemy_spawner.despawn.call_deferred(self)
			elif StarMonkey.player.global_position.z < global_position.z + spawn_proximity:
				if not _has_spawned:
					_has_spawned = true
					enemy_spawner.spawn.call_deferred(self)
				
			return
	
	var diff: Vector3 = StarMonkey.player.global_position - global_position
	var distance: float = diff.length()
	
	if distance < spawn_proximity:
		if not _has_spawned:
			_has_spawned = true
			enemy_spawner.spawn.call_deferred(self)
	elif distance > spawn_proximity + 16.0: # Add 16 to prevent flying on edge from triggering constantly
		if _has_spawned:
			_has_spawned = false
			enemy_spawner.despawn.call_deferred(self)

func _on_enemy_kill_after(alias_: StringName) -> void:
	chunk_state.killed_enemies.append(alias_)
