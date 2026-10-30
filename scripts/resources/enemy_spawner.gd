extends Resource
class_name StarMonkeyEnemySpawner

@export var enemies: Array[StarMonkeyEnemySpawn] = []

func spawn(parent: Node3D) -> void:
	for enemy: StarMonkeyEnemySpawn in enemies:
		if enemy.alias != &"" and "chunk_state" in parent:
			if parent.chunk_state.killed_enemies.has(enemy.alias):
				continue
				
		enemy.spawn(parent)

func despawn(parent: Node3D) -> void:
	for enemy: StarMonkeyEnemySpawn in enemies:
		enemy.despawn(parent)
