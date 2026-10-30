extends Node3D

@export var projectile: PackedScene = null
@export var projectile_follow_speed: float = 0.0
@export var cooldown: float = 0.25

var is_weapon_cooldown: bool = false

func shoot_weapon(weapon: StarMonkey.Weapons) -> void:
	if is_weapon_cooldown:
		return
	
	if weapon == StarMonkey.Weapons.PULSE_CANNON:
		is_weapon_cooldown = true
		
		var projectile_ = projectile.instantiate() as Node3D
		projectile_.follow_speed = projectile_follow_speed
		StarMonkey.add_level_child(projectile_)
		projectile_.global_position = %Marker3DBottom.global_position
		projectile_.reset_physics_interpolation()
		
		projectile_.launch(self, -%PulseCannonBottom.global_transform.basis.z)
		
		play_sfx()
	elif weapon == StarMonkey.Weapons.DUAL_PULSE_CANNON:
		is_weapon_cooldown = true
		
		var projectile1_ = projectile.instantiate() as Node3D
		projectile1_.follow_speed = projectile_follow_speed
		StarMonkey.add_level_child(projectile1_)
		projectile1_.global_position = %Marker3DLeft.global_position
		projectile1_.reset_physics_interpolation()
		
		var projectile2_ = projectile.instantiate() as Node3D
		projectile2_.follow_speed = projectile_follow_speed
		StarMonkey.add_level_child(projectile2_)
		projectile2_.global_position = %Marker3DRight.global_position
		projectile2_.reset_physics_interpolation()
		
		projectile1_.launch(self, -%PulseCannonLeft.global_transform.basis.z)
		projectile2_.launch(self, -%PulseCannonRight.global_transform.basis.z)
		
		play_sfx()
		play_sfx(0.05)
	elif weapon == StarMonkey.Weapons.TRIPLE_PULSE_CANNON:
		is_weapon_cooldown = true
		
		var projectile1_ = projectile.instantiate() as Node3D
		projectile1_.follow_speed = projectile_follow_speed
		StarMonkey.add_level_child(projectile1_)
		projectile1_.global_position = %Marker3DLeft.global_position
		projectile1_.reset_physics_interpolation()
		
		var projectile2_ = projectile.instantiate() as Node3D
		projectile2_.follow_speed = projectile_follow_speed
		StarMonkey.add_level_child(projectile2_)
		projectile2_.global_position = %Marker3DRight.global_position
		projectile2_.reset_physics_interpolation()
		
		var projectile3_ = projectile.instantiate() as Node3D
		projectile3_.follow_speed = projectile_follow_speed
		StarMonkey.add_level_child(projectile3_)
		projectile3_.global_position = %Marker3DBottom.global_position
		projectile3_.reset_physics_interpolation()
		
		projectile1_.launch(self, -%PulseCannonLeft.global_transform.basis.z)
		projectile2_.launch(self, -%PulseCannonRight.global_transform.basis.z)
		projectile3_.launch(self, -%PulseCannonBottom.global_transform.basis.z)
		
		play_sfx()
		play_sfx(0.05)
		play_sfx(0.1)
		
	if is_weapon_cooldown:
		await get_tree().create_timer(cooldown, false).timeout
		is_weapon_cooldown = false
		
func play_sfx(delay: float = 0.0) -> void:
	if not is_zero_approx(delay):
		await get_tree().create_timer(delay, false).timeout
	
	%AudioStreamPlayer.pitch_scale = randf_range(0.9, 1.0)
	%AudioStreamPlayer.play()
