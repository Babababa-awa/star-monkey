extends CharacterBody3D
class_name StarMonkeyPlayer

@export_group("Movement")
@export var forward_speed: float = 8.0
@export var strafe_speed: float = 6.0

@export_subgroup("Boost")
@export var boost_forward_speed: float = 8.0
@export var boost_strafe_speed: float = 6.0

@export_subgroup("Slow")
@export var slow_forward_speed: float = -6.0
@export var slow_strafe_speed: float = -3.0

@export_subgroup("Barrel Roll")
@export var barrel_roll_strafe_speed: float = 6.0

@export_subgroup("Inside Loop")
@export var inside_loop_strafe_speed: float = 6.0
@export var inside_loop_forward_speed: float = -6.0

@export var max_yaw: float = 0.35
@export var max_pitch: float = 0.35
@export var tilt_speed: float = 3.0

@export_group("Defense")
@export var max_health: int = 100
@export var max_shield: int = 100

@export_group("Offense")
@export var current_weapon: StarMonkey.Weapons = StarMonkey.Weapons.LASER_CANNON:
	set = _set_current_weapon

@export_group("Damage")
@export var damage_delay: float = 0.0
@export var kill_delay: float = 2.0

@export_subgroup("Special")
@export var max_special_count: int = 5

@export_subgroup("Exhaust")
@export var exhaust_color: Color = Color(1.0, 0.1, 0.0)
@export var boost_exhaust_color: Color = Color(0.484, 0.737, 1.0, 1.0)
@export var slow_exhaust_color: Color = Color(1.0, 0.7, 0.0)
@export var exhaust_energy: float = 2.0

var exhaust_material: StandardMaterial3D = null

var current_health: int = 100
var current_shield: int = 100
var current_special_count: int = 1

# Damage
var is_invincible: bool = false

# Boost
var is_boost: bool = false
var boost_progress: float = 0.0
var boost_duration: float = 1.75

# Slow
var is_slow: bool = false
var slow_progress: float = 0.0
var slow_duration: float = 1.75

# Barrel roll
var is_barrel_rolling: bool = false
var barrel_roll_progress: float = 0.0
var barrel_roll_direction: float = 1.0
var barrel_roll_duration: float = 1.0

# Inside loop
var is_inside_looping: bool = false
var inside_loop_progress: float = 0.0
var inside_loop_direction: float = 1.0
var inside_loop_duration: float = 2.0
var inside_loop_pivot_distance: float = 0.75

# Double tap
var double_tap_window: float = 0.28 # Time between taps to register
var input_threshold: float = 0.45 # Minimum input threshold to register
var last_left_tap_time: float = 0.0
var last_right_tap_time: float = 0.0
var last_up_tap_time: float = 0.0
var last_down_tap_time: float = 0.0
var was_left_pressed: bool = false
var was_right_pressed: bool = false
var was_up_pressed: bool = false
var was_down_pressed: bool = false

signal kill_before
signal kill_after
signal damage_taken
signal shield_taken

var is_special_cooldown: bool = false
var is_killed: bool = false

func start() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	
	StarMonkey.hud.set_player_health(current_health, max_health)
	StarMonkey.hud.set_player_shield(current_shield, max_shield)
	StarMonkey.hud.set_player_special_count(current_special_count, max_special_count)
	
func stop() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	#%MeshExploder.reset()
	#%UnitMeshCollection.clear_material_overlay()
	#%UnitMeshCollection.show_meshes()
	#is_killed = false
	#is_invincible = false
	#velocity = Vector3.ZERO
	#is_barrel_rolling = false
	#is_inside_looping = false
	#is_boost = false
	#is_slow = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	
	exhaust_material = %Craft.mesh.surface_get_material(1)
	exhaust_material.emission_energy_multiplier = exhaust_energy

	_update_weapon_visibility()
	
func _process(delta: float) -> void:
	if is_killed:
		return
		
	shoot_weapon()
	
	
	if StarMonkey.is_action_just_pressed(&"restart"):
		StarMonkey.load_level(StarMonkey.current_level)
		
	#if StarMonkey.is_action_just_pressed(&"position"):
		#global_position.z -= 64
		#%AudioStreamPlayerDie.play()
	
	if StarMonkey.is_action_just_pressed(&"special"):
		special()

	if exhaust_material != null:
		var color: Color = exhaust_color
		
		if is_boost:
			color = boost_exhaust_color.lerp(exhaust_color, boost_progress)
		elif is_slow:
			color = slow_exhaust_color.lerp(exhaust_color, slow_progress)

		exhaust_material.albedo_color = color
		exhaust_material.emission = color
		

func _physics_process(delta: float) -> void:
	if is_killed:
		return
		
	var input_x: float = StarMonkey.get_axis_x()
	var input_y: float = StarMonkey.get_axis_y()

	if StarMonkey.ARCADE_MODE:
		# Double-tap detection for barrel roll, boost and slow
		var current_left: bool = input_x < -input_threshold
		var current_right: bool = input_x > input_threshold
		var current_up: bool = input_y > input_threshold
		var current_down: bool = input_y < -input_threshold

		var now: float = Time.get_ticks_msec() / 1000.0
		
		if current_left and not was_left_pressed:
			if now - last_left_tap_time < double_tap_window:
				barrel_roll(-1.0)
			last_left_tap_time = now
		
		if current_right and not was_right_pressed:
			if now - last_right_tap_time < double_tap_window:
				barrel_roll(1.0)
			last_right_tap_time = now
		
		if current_up and not was_up_pressed:
			if now - last_up_tap_time < double_tap_window:
				boost()
			last_up_tap_time = now
		
		if current_down and not was_down_pressed:
			if now - last_down_tap_time < double_tap_window:
				slow()
			last_down_tap_time = now
		
		#if StarMonkey.is_action_just_pressed(&"boost"):
			#inside_loop()

		was_left_pressed = current_left
		was_right_pressed = current_right
		was_up_pressed = current_up
		was_down_pressed = current_down
	else:
		if StarMonkey.is_action_just_pressed(&"boost"):
			boost()
		
		if StarMonkey.is_action_just_pressed(&"slow"):
			slow()

		if StarMonkey.is_action_just_pressed(&"barrel_roll"):
			if input_x < 0.0:
				barrel_roll(-1.0)
			elif input_x > 0.0:
				barrel_roll(1.0)
				
		if StarMonkey.is_action_just_pressed(&"maneuver"):
			inside_loop()
		
	if is_barrel_rolling:
		barrel_roll_progress += delta / barrel_roll_duration
		if barrel_roll_progress >= 1.0:
			barrel_roll_progress = 1.0
			is_barrel_rolling = false
	
	if is_inside_looping:
		inside_loop_progress += delta / inside_loop_duration
		if inside_loop_progress >= 1.0:
			inside_loop_progress = 1.0
			is_inside_looping = false
	
	if is_boost:
		boost_progress += delta / boost_duration
		if boost_progress >= 1.0:
			boost_progress = 1.0
			is_boost = false
	
	if is_slow:
		slow_progress += delta / slow_duration
		if slow_progress >= 1.0:
			slow_progress = 1.0
			is_slow = false

	var current_strafe_speed_x: float = strafe_speed
	var current_strafe_speed_y: float = strafe_speed
	var current_forward_speed: float = forward_speed
	
	if is_barrel_rolling:
		current_strafe_speed_x += barrel_roll_strafe_speed
		current_strafe_speed_y += barrel_roll_strafe_speed
	
	if is_inside_looping:
		current_forward_speed += inside_loop_forward_speed
		if inside_loop_progress < 0.85:
			current_strafe_speed_y += inside_loop_strafe_speed
		
		input_y = clampf(1.0 - 2.5 * inside_loop_progress, -0.5, 1.0)
	
	if is_boost:
		current_strafe_speed_x += boost_strafe_speed
		current_strafe_speed_y += boost_strafe_speed
		current_forward_speed += boost_forward_speed
	elif is_slow:
		current_strafe_speed_x += slow_strafe_speed
		current_strafe_speed_y += slow_strafe_speed
		current_forward_speed += slow_forward_speed
	
	#current_forward_speed = 0.0
	velocity = Vector3(
		input_x * current_strafe_speed_x,
		input_y * current_strafe_speed_y,
		-current_forward_speed
	)
	move_and_slide()

	var bounds: Vector3 = StarMonkey.bounds.bounds
	position.x = clampf(position.x, -bounds.x, bounds.x)
	position.y = clampf(position.y, -bounds.y, bounds.y)

	var strafe_x: float = 0.0
	var strafe_y: float = 0.0
	if strafe_speed > 0.0:
		strafe_x = clampf(velocity.x / strafe_speed, -1.0, 1.0)
		strafe_y = clampf(velocity.y / strafe_speed, -1.0, 1.0)

	var target_yaw: float = -strafe_x * max_yaw
	var target_pitch: float = strafe_y * max_pitch
	
	# Regular movement basis
	var target_basis: Basis = Basis.IDENTITY
	target_basis = target_basis.rotated(Vector3.UP, target_yaw)
	if not is_inside_looping:
		target_basis = target_basis.rotated(target_basis.x, target_pitch)

	# Adjust for barrel roll and inside loop
	var extra_angle: float = 0.0
	var extra_axis: Vector3 = Vector3.FORWARD
	
	if is_barrel_rolling:
		var t: float = 1.0 - pow(1.0 - barrel_roll_progress, 3.0)
		extra_angle = t * TAU * barrel_roll_direction
		extra_axis = Vector3.FORWARD
	elif is_inside_looping:
		var t: float = 1.0 - pow(1.0 - inside_loop_progress, 3.0)
		extra_angle = t * TAU * inside_loop_direction
		extra_axis = Vector3.RIGHT
	
	if extra_angle != 0.0:
		var local_rotation: Basis = Basis.IDENTITY.rotated(extra_axis, extra_angle)
		target_basis = target_basis * local_rotation

	# Smoothly approach the final orientation
	var blend: float = 1.0 - exp(-tilt_speed * delta)
	
	if is_inside_looping:
		# Rotate around a point loop_pivot_distance units forward
		var pivot_local: Vector3 = Vector3(0.0, 0.0, -inside_loop_pivot_distance)
		var pivot_world: Vector3 = position + transform.basis * pivot_local

		var new_basis: Basis = transform.basis.slerp(target_basis, blend)
		position = pivot_world - new_basis * pivot_local
		transform.basis = new_basis
	else:
		transform.basis = transform.basis.slerp(target_basis, blend)

func shoot_weapon() -> void:
	if not StarMonkey.is_action_pressed(&"shoot"):
		return
	
	if current_weapon == StarMonkey.Weapons.NONE:
		return
		
	%Weapon.shoot_weapon(current_weapon)

func barrel_roll(direction: float) -> void:
	if is_barrel_rolling or is_inside_looping:
		return

	StarMonkey.score += 25

	is_barrel_rolling = true
	barrel_roll_progress = 0.0
	barrel_roll_direction = direction

func inside_loop() -> void:
	if is_inside_looping or is_boost or is_slow or is_barrel_rolling:
		return
	
	StarMonkey.score += 50
	
	is_inside_looping = true
	inside_loop_progress = 0.0
	inside_loop_direction = 1.0

func slow() -> void:
	if is_slow or is_boost or is_inside_looping:
		return
		
	is_slow = true
	slow_progress = 0.0
	StarMonkey.camera.zoom(-2.0, slow_duration, 0.5)
	StarMonkey.sfx.play_frame_slow()
	
func boost() -> void:
	if is_boost or is_slow or is_inside_looping:
		return
	
	StarMonkey.score += 25
	
	is_boost = true
	boost_progress = 0.0
	StarMonkey.camera.zoom(3.0, boost_duration, 0.5)
	StarMonkey.sfx.play_frame_boost()
	
func special() -> void:
	if current_special_count <= 0:
		return
		
	if %Special.is_weapon_cooldown:
		return
	
	%Special.shoot_weapon(StarMonkey.Weapons.MONKEY_BALL)
	
	current_special_count -= 1
	StarMonkey.hud.set_player_special_count(current_special_count, max_special_count)

func take_damage(damage: int, independent: bool = false, source: Node3D = null) -> void:
	if is_invincible and not independent:
		return
		
	is_invincible = true
	
	if current_shield > 0.0:
		current_shield -= damage
		current_shield = maxi(0, current_shield)
		shield_taken.emit()
		
		if current_shield == 0:
			%FrameAI.play_shields_down()
		
		StarMonkey.hud.set_player_shield(current_shield, max_shield)

		StarMonkey.sfx.play_shield_hit()
	else:
		current_health -= damage
		current_health = maxi(0, current_health)
		damage_taken.emit()

		StarMonkey.hud.set_player_health(current_health, max_health)
		
		StarMonkey.sfx.play_frame_hit()
	
	if current_health <= 0.0:
		kill()
		return
	
	if damage > 15:
		StarMonkey.camera.shake(2.0, 1.0)
	else:
		StarMonkey.camera.shake(1.0, 0.5)
	
	if damage_delay > 0.0:
		await get_tree().create_timer(damage_delay, false).timeout
	
	is_invincible = false
		
func kill() -> void:
	kill_before.emit()
	
	is_killed = true
	
	%MeshExploder.explode(%UnitMeshCollection.get_meshes(), 2.0)
	%Explosion.explode()
	
	%AudioStreamPlayerDie.play()
	
	StarMonkey.sfx.play_frame_explosion()
	
	if kill_delay > 0.0:
		await get_tree().create_timer(kill_delay, false).timeout
		
	#queue_free()
	kill_after.emit()
	
	StarMonkey.menu.change_state(StarMonkeyMenu.MenuState.CONTINUE)

func load_state(player_state: StarMonkeyPlayerState) -> void:
	max_health = player_state.max_health
	current_health = player_state.current_health
	
	max_shield = player_state.max_shield
	current_shield = player_state.current_shield

	max_special_count = player_state.max_special_count
	current_special_count = player_state.current_special_count
	
	current_weapon = player_state.current_weapon
	
func save_state() -> StarMonkeyPlayerState:
	var player_state = StarMonkeyPlayerState.new()
	
	player_state.max_health = max_health
	player_state.current_health = current_health
	
	player_state.max_shield = max_shield
	player_state.current_shield = current_shield
	
	player_state.current_special_count = current_special_count
	player_state.max_special_count = max_special_count
	
	player_state.current_weapon = current_weapon
	
	return player_state

func _set_current_weapon(value: StarMonkey.Weapons) -> void:
	current_weapon = value
	
	if is_node_ready():
		_update_weapon_visibility()

func _update_weapon_visibility() -> void:
	if current_weapon == StarMonkey.Weapons.TRIPLE_LASER_CANNON:
		%LaserCannonFront.visible = true
		%LaserCannonLeft.visible = true
		%LaserCannonRight.visible = true
	elif current_weapon == StarMonkey.Weapons.DUAL_LASER_CANNON:
		%LaserCannonFront.visible = true
		%LaserCannonLeft.visible = true
		%LaserCannonRight.visible = true
	else:
		%LaserCannonFront.visible = true
		%LaserCannonLeft.visible = false
		%LaserCannonRight.visible = false

func upgrade_weapon() -> void:
	%FrameAI.play_pickup()
	
	if current_weapon == StarMonkey.Weapons.LASER_CANNON:
		current_weapon = StarMonkey.Weapons.DUAL_LASER_CANNON
		%FrameAI.play_pickup_weapon_upgrade(0.25)
	elif current_weapon == StarMonkey.Weapons.DUAL_LASER_CANNON:
		current_weapon = StarMonkey.Weapons.TRIPLE_LASER_CANNON
		%FrameAI.play_pickup_weapon_upgrade(0.25)
	else:
		StarMonkey.score += 1000

	
func add_shield(value: int) -> void:
	%FrameAI.play_pickup()
		
	if current_shield == max_shield:
		StarMonkey.score += 1000
		return
	
	if current_shield == 0:
		%FrameAI.play_shields_restored(0.25)
	else:
		%FrameAI.play_pickup_shield(0.25)
	
	current_shield = mini(current_shield + value, max_shield)
	StarMonkey.hud.set_player_shield(current_shield, max_shield)
	
func add_special() -> void:
	%FrameAI.play_pickup()
	
	if current_special_count == max_special_count:
		StarMonkey.score += 1000
		return
		
	current_special_count += 1
	StarMonkey.hud.set_player_special_count(current_special_count, max_special_count)
	
	%FrameAI.play_pickup_speical(0.25)
	
func get_frame_ai() -> StarMonkeyFrameAI:
	return %FrameAI
