extends StarMonkeyCharacter

@onready var left_upper_arm: Node3D = %LeftUpperArm
@onready var left_lower_arm: Node3D = %LeftLowerArm
@onready var right_upper_arm: Node3D = %RightUpperArm
@onready var right_lower_arm: Node3D = %RightLowerArm

var pose_data: Dictionary = {
	&"normal": {
		&"speed": 1.0,
		&"steps": [
			{
				&"left_arm": {
					&"upper_rotation": Vector3(0, 0.0, 0.0),
					&"lower_rotation": Vector3(0, 0.0, 0.0),
				},
				&"right_arm": {
					&"upper_rotation": Vector3(0.0, 0.0, 0.0),
					&"lower_rotation": Vector3(0.0, 0.0, 0.0),
				}
			}
		]
	},
	&"salute": {
		&"speed": 1.0,
		&"steps": [
			{
				&"left_arm": {
					&"upper_rotation": Vector3(0, 23.7, 146.8),
					&"lower_rotation": Vector3(0, -66.3, 28.4),
				},
				&"right_arm": {
					&"upper_rotation": Vector3(0.0, 0.0, 0.0),
					&"lower_rotation": Vector3(0.0, 0.0, 0.0),
				}
			}
		]
	},
	&"point": {
		&"speed": 1.0,
		&"steps": [
			{
				&"left_arm": {
					&"upper_rotation": Vector3(0.0, 0.0, 0.0),
					&"lower_rotation": Vector3(0.0, 0.0, 0.0),
				},
				&"right_arm": {
					&"upper_rotation": Vector3(0.0, 0.0, 33.0),
					&"lower_rotation": Vector3(0.0, 0.0, 99.0),
				}
			},
			{
				&"left_arm": {
					&"upper_rotation": Vector3(0.0, 0.0, 0.0),
					&"lower_rotation": Vector3(0.0, 0.0, 0.0),
				},
				&"right_arm": {
					&"upper_rotation": Vector3(0.0, 0.0, 95.0),
					&"lower_rotation": Vector3(0.0, 0.0, 0.0),
				}
			}
		]
	}
}


func get_pose_data(pose: Poses) -> Dictionary:
	var key: StringName = _pose_to_key(pose)
	return pose_data.get(key, {})

func tween_step(tween: Tween, step: Dictionary, duration: float) -> void:
	var left_arm: Dictionary = step[&"left_arm"]
	var right_arm: Dictionary = step[&"right_arm"]
	
	tween.tween_property(left_upper_arm, "rotation_degrees", left_arm[&"upper_rotation"], duration)
	tween.parallel().tween_property(left_lower_arm, "rotation_degrees", left_arm[&"lower_rotation"], duration)
	tween.parallel().tween_property(right_upper_arm, "rotation_degrees", right_arm[&"upper_rotation"], duration)
	tween.parallel().tween_property(right_lower_arm, "rotation_degrees", right_arm[&"lower_rotation"], duration)


func _pose_to_key(pose: Poses) -> StringName:
	match pose:
		Poses.NORMAL:
			return &"normal"
		Poses.SALUTE:
			return &"salute"
		Poses.POINT:
			return &"point"
		_:
			return &"normal"
