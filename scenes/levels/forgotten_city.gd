extends StarMonkeyChunkLevel

@export var ring_groups: Array[StarMonkeyRingGroup] = []

func _ready() -> void:
	super._ready()
	
	for ring_group: StarMonkeyRingGroup in ring_groups:
		ring_group.ring_group_completed.connect(_on_ring_group_completed)

func _process(delta: float) -> void:
	super._process(delta)
	
	if not is_instance_valid(StarMonkey.player):
		return

func _physics_process(delta: float) -> void:
	if is_instance_valid(StarMonkey.player):
		%Fog.position.z = StarMonkey.player.position.z - 28.0

func _on_ring_group_completed(group_alias: StringName) -> void:
	if group_alias == &"first":
		level_state.ring_group_completed = true
		level_state_changed.emit([&"ring_group_completed"])

func _on_victory_area_3d_body_entered(body: Node3D) -> void:
	StarMonkey.score += StarMonkey.player.current_health * 25
	StarMonkey.score += StarMonkey.player.current_shield * 25
	StarMonkey.score += StarMonkey.player.current_special_count * 250
	
	if has_killed_all_enemies():
		StarMonkey.score += 10000
		
	StarMonkey.disable_input = true
	StarMonkey.enable_input_delay(0.75)
	StarMonkey.menu.change_state(StarMonkey.menu.MenuState.VICTORY)
	%AudioStreamPlayerVictory.play()

func _on_music_fade_out_area_3d_body_entered(body: Node3D) -> void:
	fade_out_audio(%AudioStreamPlayerMusic, 2.0)
	play_frame_ai_victory(0.5)

func play_frame_ai_victory(delay: float = 0.0) -> void:
	if not is_zero_approx(delay):
		await get_tree().create_timer(delay, false).timeout
	
	if has_killed_all_enemies():
		StarMonkey.player.get_frame_ai().play_victory_full()
	else:
		StarMonkey.player.get_frame_ai().play_victory()
