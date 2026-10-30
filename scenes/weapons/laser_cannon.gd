extends Node3D

@export var projectile: PackedScene = null
@export var cooldown: float = 0.25

var is_weapon_cooldown: bool = false

var _dual_left: bool = false
var _dual_skip: int = 0

func shoot_weapon(weapon: StarMonkey.Weapons) -> void:
	if is_weapon_cooldown:
		return
		
	if weapon == StarMonkey.Weapons.LASER_CANNON:
		is_weapon_cooldown = true
		
		var projectile_ = projectile.instantiate() as Node3D
		StarMonkey.add_level_child(projectile_)
		projectile_.global_position = %Marker3DFront.global_position
		projectile_.reset_physics_interpolation()
		projectile_.launch(self, -global_transform.basis.z)
		
		play_sfx()
	elif weapon == StarMonkey.Weapons.DUAL_LASER_CANNON:
		is_weapon_cooldown = true
		
		var projectile1_ = projectile.instantiate() as Node3D
		StarMonkey.add_level_child(projectile1_)
		projectile1_.global_position = %Marker3DFront.global_position
		projectile1_.reset_physics_interpolation()
		projectile1_.launch(self, -global_transform.basis.z)
		
		play_sfx()
		
		if _dual_skip == 0:
			var projectile2_ = projectile.instantiate() as Node3D
			StarMonkey.add_level_child(projectile2_)
			if _dual_left:
				projectile2_.global_position = %Marker3DLeft.global_position
			else:
				projectile2_.global_position = %Marker3DRight.global_position
			projectile2_.reset_physics_interpolation()
			projectile2_.launch(self, -global_transform.basis.z)
			
			play_sfx(0.05)
			
			_dual_left = !_dual_left
			_dual_skip += 1
		else:
			_dual_skip += 1
			if _dual_skip == 3:
				_dual_skip = 0
	elif weapon == StarMonkey.Weapons.TRIPLE_LASER_CANNON:
		is_weapon_cooldown = true
		
		var projectile1_ = projectile.instantiate() as Node3D
		StarMonkey.add_level_child(projectile1_)
		projectile1_.global_position = %Marker3DLeft.global_position
		projectile1_.reset_physics_interpolation()
		
		var projectile2_ = projectile.instantiate() as Node3D
		StarMonkey.add_level_child(projectile2_)
		projectile2_.global_position = %Marker3DRight.global_position
		projectile2_.reset_physics_interpolation()
		
		var projectile3_ = projectile.instantiate() as Node3D
		StarMonkey.add_level_child(projectile3_)
		projectile3_.global_position = %Marker3DFront.global_position
		projectile2_.reset_physics_interpolation()
		
		projectile1_.launch(self, -global_transform.basis.z)
		projectile2_.launch(self, -global_transform.basis.z)
		projectile3_.launch(self, -global_transform.basis.z)
		
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
