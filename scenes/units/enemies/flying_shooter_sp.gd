extends StarMonkeyEnemy

@onready var sweet_potato: MeshInstance3D = $UnitMeshCollection/SweetPotato

var _sweet_potato_origin_y: float = 0.0
var _sweet_potato_time: float = 0.0

func _ready() -> void:
	super._ready()
	
	_sweet_potato_origin_y = sweet_potato.position.y
	_update_weapon_visibility()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	_sweet_potato_time += delta
	sweet_potato.position.y = _sweet_potato_origin_y + sin(_sweet_potato_time * sweet_potato_speed) * sweet_potato_max_move

func _aim_weapon(delta: float) -> void:
	if StarMonkey.player == null:
		return
	
	_aim_pulse_cannon(
		%PulseCannonLeft,
		StarMonkey.player.global_position + Vector3(1.0, 0.0, -3.0), 
		true, 
		delta
	)
	_aim_pulse_cannon(
		%PulseCannonRight,
		StarMonkey.player.global_position + Vector3(-1.0, 0.0, -3.0), 
		true, 
		delta
	)
	_aim_pulse_cannon(
		%PulseCannonBottom,
		StarMonkey.player.global_position + Vector3(0.0, 0.0, -3.0), 
		false, 
		delta
	)
	
func _aim_pulse_cannon(
	cannon: Node3D,
	target_position: Vector3, 
	is_side_cannon: bool, 
	delta: float
) -> void:
	var desired: Vector3 = _calculate_desired_rotation(cannon, target_position)
	var limit: float = deg_to_rad(pulse_cannon_roate_limit)

	if is_side_cannon:
		desired.y = clampf(desired.y, -limit, limit)
	else:
		desired.x = clampf(desired.x, -limit, limit)

	desired.z = cannon.rotation.z

	_rotate_towards(cannon, desired, delta)

func _calculate_desired_rotation(cannon: Node3D, target_position: Vector3) -> Vector3:
	var saved: Vector3 = cannon.rotation

	cannon.rotation = Vector3(0.0, 0.0, saved.z)
	cannon.look_at(target_position, Vector3.UP)
	var desired: Vector3 = cannon.rotation

	cannon.rotation = saved
	return desired


func _rotate_towards(cannon: Node3D, desired: Vector3, delta: float) -> void:
	var step: float = deg_to_rad(pulse_cannon_rotate_speed) * delta
	var current: Vector3 = cannon.rotation

	current.x = move_toward(current.x, desired.x, step)
	current.y = move_toward(current.y, desired.y, step)
	current.z = desired.z

	cannon.rotation = current

func _shoot_weapon() -> void:
	if current_weapon == StarMonkey.Weapons.NONE:
		return
	
	%Weapon.projectile_follow_speed = pulse_shot_follow_speed
	%Weapon.shoot_weapon(current_weapon)

func _set_current_weapon(value: StarMonkey.Weapons) -> void:
	super._set_current_weapon(value)
	
	if not is_node_ready():
		return
		
	_update_weapon_visibility()

func _update_weapon_visibility() -> void:
	if current_weapon == StarMonkey.Weapons.TRIPLE_PULSE_CANNON:
		%PulseCannonBottom.visible = true
		%PulseCannonLeft.visible = true
		%PulseCannonRight.visible = true
	elif current_weapon == StarMonkey.Weapons.DUAL_PULSE_CANNON:
		%PulseCannonBottom.visible = false
		%PulseCannonLeft.visible = true
		%PulseCannonRight.visible = true
	elif current_weapon == StarMonkey.Weapons.PULSE_CANNON:
		%PulseCannonBottom.visible = true
		%PulseCannonLeft.visible = false
		%PulseCannonRight.visible = false
