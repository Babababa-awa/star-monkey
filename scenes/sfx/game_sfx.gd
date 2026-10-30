extends Node3D
class_name StarMonkeyGameSFX

var current_enemy_explosion: int = 0
var current_collapse: int = 0
var current_destroy: int = 0
var current_shield_hit: int = 0
var current_frame_hit: int = 0
var current_frame_explosion: int = 0

func _ready() -> void:
	current_enemy_explosion = randi_range(1, 5)
	current_collapse = randi_range(1, 4)
	current_destroy = randi_range(1, 7)
	current_shield_hit = 1
	current_frame_hit = 1
	current_frame_explosion = randi_range(1, 3)

func play_enemy_explosion(delay: float = 0.0) -> void:
	if not is_zero_approx(delay):
		await get_tree().create_timer(delay, false).timeout
		
	var player = get_node_or_null("%AudioStreamPlayerEnemyExplosion" + str(current_enemy_explosion))
	player.pitch_scale = randf_range(0.95, 1.05)
	player.play()
	
	current_enemy_explosion += 1
	if current_enemy_explosion == 6:
		current_enemy_explosion = 1
	
func play_collapse(delay: float = 0.0) -> void:
	if not is_zero_approx(delay):
		await get_tree().create_timer(delay, false).timeout
		
	var player = get_node_or_null("%AudioStreamPlayerCollapse" + str(current_collapse))
	player.pitch_scale = randf_range(0.95, 1.05)
	player.play()
	
	current_collapse += 1
	if current_collapse == 5:
		current_collapse = 1
	
func play_destroy(delay: float = 0.0) -> void:
	if not is_zero_approx(delay):
		await get_tree().create_timer(delay, false).timeout
		
	var player = get_node_or_null("%AudioStreamPlayerDestroy" + str(current_destroy))
	player.pitch_scale = randf_range(0.95, 1.05)
	player.play()
	
	current_destroy += 1
	if current_destroy == 8:
		current_destroy = 1
		
func play_shield_hit(delay: float = 0.0) -> void:
	if not is_zero_approx(delay):
		await get_tree().create_timer(delay, false).timeout
		
	var player = get_node_or_null("%AudioStreamPlayerShieldHit" + str(current_shield_hit))
	player.pitch_scale = randf_range(0.9, 1.0)
	player.play()
	
	#current_shield_hit += 1
	#if current_shield_hit == 2:
		#current_shield_hit = 1

func play_frame_hit(delay: float = 0.0) -> void:
	if not is_zero_approx(delay):
		await get_tree().create_timer(delay, false).timeout
		
	var player = get_node_or_null("%AudioStreamPlayerFrameHit" + str(current_frame_hit))
	player.pitch_scale = randf_range(0.9, 1.0)
	player.play()
	
	#current_frame_hit += 1
	#if current_frame_hit == 3:
		#current_frame_hit = 1
		
func play_frame_boost(delay: float = 0.0) -> void:
	if not is_zero_approx(delay):
		await get_tree().create_timer(delay, false).timeout
		
	var player = get_node_or_null("%AudioStreamPlayerFrameBoost1")
	player.pitch_scale = randf_range(0.9, 1.0)
	player.play()

func play_frame_slow(delay: float = 0.0) -> void:
	if not is_zero_approx(delay):
		await get_tree().create_timer(delay, false).timeout
		
	var player = get_node_or_null("%AudioStreamPlayerFrameSlow1")
	player.pitch_scale = randf_range(0.9, 1.0)
	player.play()

func play_frame_explosion(delay: float = 0.0) -> void:
	if not is_zero_approx(delay):
		await get_tree().create_timer(delay, false).timeout
		
	var player = get_node_or_null("%AudioStreamPlayerFrameExplosion" + str(current_frame_explosion))
	player.pitch_scale = randf_range(0.95, 1.05)
	player.play()
	
	current_frame_explosion += 1
	if current_frame_explosion == 4:
		current_frame_explosion = 1
