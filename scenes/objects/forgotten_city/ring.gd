extends Node3D

@export var alias: StringName = &""
@export var group_alias: StringName = &""

func _on_area_3d_score_body_entered(body: Node3D) -> void:
	if body is StarMonkeyPlayer:
		StarMonkey.score += 1000
		%ScoreArea3D.set_deferred("monitoring", false)
		%AudioStreamPlayer.pitch_scale = randf_range(0.9, 1.1)
		%AudioStreamPlayer.play()

		if StarMonkey.level != null and "ring_groups" in StarMonkey.level:
			for ring_group: StarMonkeyRingGroup in StarMonkey.level.ring_groups:
				if ring_group.alias == group_alias:
					ring_group.complete_ring(alias)
					if ring_group.completed_rings.size() == ring_group.total_rings:
						StarMonkey.score += 2500
						await get_tree().create_timer(0.65, false).timeout
						%AudioStreamPlayerSuccess.pitch_scale = randf_range(0.9, 1.1)
						%AudioStreamPlayerSuccess.play()
					break
