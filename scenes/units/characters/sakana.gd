extends StarMonkeyCharacter

@onready var left_arm: Node3D = %LeftArm
@onready var right_arm: Node3D = %RightArm

var pose_data: Dictionary = {
	&"normal": {
		&"speed": 1.0,
		&"steps": [
			{
				&"left_arm": {
					&"rotation": Vector3(0.0, 0.0, 0.0),
				},
				&"right_arm": {
					&"rotation": Vector3(0.0, 0.0, 0.0),
				}
			}
		]
	},
	&"salute": {
		&"speed": 1.0,
		&"steps": [
			{
				&"left_arm": {
					&"rotation": Vector3(0.0, 0.0, 0.0),
				},
				&"right_arm": {
					&"rotation": Vector3(0.0, 0.0, 0.0),
				}
			}
		]
	},
	&"point": {
		&"speed": 1.0,
		&"steps": [
			{
				&"left_arm": {
					&"rotation": Vector3(0.0, 0.0, 0.0),
				},
				&"right_arm": {
					&"rotation": Vector3(-118.0, 0.0, 0.0),
				}
			}
		]
	},
	&"press_button": {
		&"speed": 0.75,
		&"steps": [
			{
				&"left_arm": {
					&"rotation": Vector3(0.0, 0.0, 0.0),
				},
				&"right_arm": {
					&"rotation": Vector3(-80.0, 0.0, 0.0),
				}
			},
			{
				&"left_arm": {
					&"rotation": Vector3(0.0, 0.0, 0.0),
				},
				&"right_arm": {
					&"rotation": Vector3(0.0, 0.0, 0.0),
				}
			}
		]
	}
}

func get_pose_data(pose: Poses) -> Dictionary:
	var key: StringName = _pose_to_key(pose)
	return pose_data.get(key, {})

func tween_step(tween: Tween, step: Dictionary, duration: float) -> void:
	var left_arm_step: Dictionary = step[&"left_arm"]
	var right_arm_step: Dictionary = step[&"right_arm"]
	
	tween.tween_property(left_arm, "rotation_degrees", left_arm_step[&"rotation"], duration)
	tween.parallel().tween_property(right_arm, "rotation_degrees", right_arm_step[&"rotation"], duration)

func _pose_to_key(pose: Poses) -> StringName:
	match pose:
		Poses.NORMAL:
			return &"normal"
		Poses.SALUTE:
			return &"salute"
		Poses.POINT:
			return &"point"
		Poses.PRESS_BUTTON:
			return &"press_button"
		_:
			return &"normal"
