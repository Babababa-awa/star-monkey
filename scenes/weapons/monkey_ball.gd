extends Node3D

@export var projectile: PackedScene = null
@export var cooldown: float = 0.25

var is_weapon_cooldown: bool = false

func shoot_weapon(weapon: StarMonkey.Weapons) -> void:
	if is_weapon_cooldown:
		return
	
	is_weapon_cooldown = true
	
	var projectile_ = projectile.instantiate() as Node3D
	StarMonkey.add_level_child(projectile_)
	projectile_.global_position = %Marker3DFront.global_position
	projectile_.reset_physics_interpolation()
	projectile_.launch(self, -global_transform.basis.z)
	
	play_sfx()
	
	if is_weapon_cooldown:
		await get_tree().create_timer(cooldown, false).timeout
		is_weapon_cooldown = false

func play_sfx(delay: float = 0.0) -> void:
	if not is_zero_approx(delay):
		await get_tree().create_timer(delay, false).timeout
	
	%AudioStreamPlayer.pitch_scale = randf_range(0.9, 1.0)
	%AudioStreamPlayer.play()
