extends StarMonkeyProjectile

@export var follow_speed: float = 25.0 # degrees per second

func _physics_process(delta) -> void:
	super._physics_process(delta)
	
	if StarMonkey.player != null and not is_zero_approx(follow_speed):
		var player_pos: Vector3 = StarMonkey.player.global_position
		player_pos.z -= 3
		var target_dir: Vector3 = (player_pos - global_position).normalized()

		var current: Vector3 = direction.normalized()
		var angle: float = current.angle_to(target_dir)
		var max_step: float = deg_to_rad(follow_speed) * delta

		if angle > 0.001:
			var axis: Vector3 = current.cross(target_dir).normalized()
			var step: float = minf(angle, max_step)
			direction = current.rotated(axis, step)

	%PulseShot.rotation_degrees.z -= 50 * delta
	
