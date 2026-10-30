extends Camera3D
class_name StarMonkeyCamera

@export var mode: Modes = Modes.FOLLOW
@export var target: Node3D = null

@export_subgroup("Follow")
@export var follow_offset: Vector3 = Vector3(0.0, 3.0, 8.0)
@export var follow_target_offset: Vector3 = Vector3(0.0, 1.0, 0.0)
@export var follow_speed: float = 2.0
@export var follow_bounds: Vector2 = Vector2(8.0, 8.0)

@export_subgroup("Rotate Around")
@export var rotate_around_offset: Vector3 = Vector3(0.0, 5.0, 0.0)
@export var rotate_around_target_offset: Vector3 = Vector3.ZERO
@export var rotate_around_target_distance: float = 100.0
@export var rotate_around_look_distance: float = 0.0
@export var rotate_around_speed: float = 0.25

@export_subgroup("Path Follow")
@export var path_follow_speed: float = 2
@export var path_follow_target_offset: Vector3 = Vector3(0.0, 18.0, 0.0)

var _rotate_around_angle: float = 0.0
var _path_follow: PathFollow3D = null
var _reverse_path: bool = false

var _zoom_z_offset: float = 0.0
var _zoom_tween: Tween = null

var _shake_offset: Vector3 = Vector3.ZERO
var _shake_duration: float = 0.0
var _shake_elapsed: float = 0.0
var _shake_strength: float = 0.0

enum Modes {
	FOLLOW,
	ROTATE_AROUND,
	PATH_FOLLOW
}

func set_mode(mode_: Modes) -> void:
	mode = mode_
	
	if mode_ == Modes.FOLLOW:
		var desired: Vector3 = target.global_position + follow_offset
		desired.x = clampf(desired.x, -follow_bounds.x, follow_bounds.x)
		desired.y = clampf(desired.y, -follow_bounds.y, follow_bounds.y)
		
		global_position = desired
		look_at(target.global_position + follow_target_offset, Vector3.UP)
		
		reset_physics_interpolation()
	elif mode_ == Modes.ROTATE_AROUND:
		_rotate_around_angle = 0.0
		
		var center: Vector3
		if target != null:
			center = target.global_position + rotate_around_target_offset
		else:
			center = rotate_around_target_offset
			
		var orbit_offset: Vector3 = Vector3(sin(_rotate_around_angle), 0.0, cos(_rotate_around_angle)) * rotate_around_target_distance
		global_position = center + orbit_offset + rotate_around_offset
		
		var look_pos: Vector3 = center
		if not is_zero_approx(rotate_around_look_distance):
			var look_offset: Vector3 = Vector3(sin(_rotate_around_angle), 0.0, cos(_rotate_around_angle)) * rotate_around_look_distance
			look_pos = center + look_offset
		look_at(look_pos, Vector3.UP)
		
		reset_physics_interpolation()
	elif mode_ == Modes.PATH_FOLLOW:
		_reverse_path = false
		
		global_transform = _path_follow.global_transform
		
		var target_pos: Vector3 = Vector3.ZERO
		if target != null:
			target_pos = target.global_position
		
		look_at(target_pos + path_follow_target_offset, Vector3.UP)
		
		reset_physics_interpolation()
	
func set_target(target_: Node3D) -> void:
	target = target_
	
func set_path_follow(path_follow_: PathFollow3D) -> void:
	_path_follow = path_follow_
	
func zoom(distance: float, time: float, hold_time: float = 0.0) -> void:
	if mode != Modes.FOLLOW:
		return
		
	if is_instance_valid(_zoom_tween):
		_zoom_tween.kill()
	
	_zoom_z_offset = 0.0

	var out_time := time * 0.3
	var back_time := time * 0.7
	
	_zoom_tween = create_tween()

	_zoom_tween.tween_property(self, "_zoom_z_offset", distance, out_time)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	
	# Optional hold
	if not is_zero_approx(hold_time):
		_zoom_tween.tween_interval(hold_time)
	
	# Slow return
	_zoom_tween.tween_property(self, "_zoom_z_offset", 0.0, back_time)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN_OUT)

func shake(strength: float, time: float) -> void:
	if mode != Modes.FOLLOW:
		return
		
	_shake_duration = time
	_shake_elapsed = 0.0
	_shake_strength = strength
	
func _physics_process(delta: float) -> void:
	if mode == Modes.FOLLOW:
		if target == null:
			return
			
		if _shake_elapsed < _shake_duration:
			_shake_elapsed += delta
			var progress: float = clampf(_shake_elapsed / _shake_duration, 0.0, 1.0)
			var intensity: float = (1.0 - progress) * _shake_strength
			_shake_offset = Vector3(
				randf_range(-1.0, 1.0),
				randf_range(-1.0, 1.0),
				randf_range(-1.0, 1.0)
			) * intensity
		else:
			_shake_offset = Vector3.ZERO
		
		var offset: Vector3 = follow_offset
		offset.z += _zoom_z_offset
		
		var desired: Vector3 = target.global_position + offset
		desired.x = clampf(desired.x, -follow_bounds.x, follow_bounds.x)
		desired.y = clampf(desired.y, -follow_bounds.y, follow_bounds.y)
		desired += _shake_offset
		
		var blend: float = 1.0 - exp(-follow_speed * delta)
		global_position = global_position.lerp(desired, blend)
		global_position.z = desired.z
		
		var target_pos: Vector3 = target.global_position + follow_target_offset
		var desired_basis: Basis = Basis.looking_at(target_pos - global_position, Vector3.UP)

		basis = basis.slerp(desired_basis, blend)
	elif mode == Modes.ROTATE_AROUND:
		_rotate_around_angle += rotate_around_speed * delta
		
		var center: Vector3
		if target != null:
			center = target.global_position + rotate_around_target_offset
		else:
			center = rotate_around_target_offset
			
		var orbit_offset: Vector3 = Vector3(sin(_rotate_around_angle), 0.0, cos(_rotate_around_angle)) * rotate_around_target_distance
		global_position = center + orbit_offset + rotate_around_offset
		
		var look_pos: Vector3 = center
		if not is_zero_approx(rotate_around_look_distance):
			var look_offset: Vector3 = Vector3(sin(_rotate_around_angle), 0.0, cos(_rotate_around_angle)) * rotate_around_look_distance
			look_pos = center + look_offset
		look_at(look_pos, Vector3.UP)
	elif mode == Modes.PATH_FOLLOW:
		if _path_follow != null:
			if _reverse_path:
				_path_follow.progress -= path_follow_speed * delta
			else:
				_path_follow.progress += path_follow_speed * delta
			global_transform = _path_follow.global_transform
			
			var target_pos: Vector3 = Vector3.ZERO
			if target != null:
				target_pos = target.global_position
			
			look_at(target_pos + path_follow_target_offset, Vector3.UP)
			
			if _reverse_path:
				if _path_follow.progress <= 0.0:
					_reverse_path = false
			else:
				var max_progress: float = _path_follow.get_parent().curve.get_baked_length()
				if _path_follow.progress >= max_progress:
					_reverse_path = true

	
