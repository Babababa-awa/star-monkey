extends Resource
class_name StarMonkeyRingGroup

@export var alias: StringName = &""
@export var total_rings: int = 1

var completed: bool = false
var completed_rings: Array[StringName] = []

signal ring_group_completed(group_name: StringName)

func complete_ring(ring_alias) -> void:
	if completed_rings.has(ring_alias):
		return
		
	completed_rings.append(ring_alias)
	
	if completed_rings.size() == total_rings:
		completed = true
		ring_group_completed.emit(alias)
		
