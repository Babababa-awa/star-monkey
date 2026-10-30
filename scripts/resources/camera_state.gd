extends Resource
class_name StarMonkeyCameraState

@export var follow_state = FollowStates.ABOVE

@export var above_follow_offset: Vector3 = Vector3(0.0, 3.0, 7.0)
@export var above_follow_target_offset: Vector3 = Vector3(0.0, 1.0, 0.0)

@export var behind_follow_offset: Vector3 = Vector3(0.0, 0.0, 7.0)
@export var behind_follow_target_offset: Vector3 = Vector3(0.0, 0.0, 0.0)

enum FollowStates {
	ABOVE,
	BEHIND,
}

func change_follow_state(follow_state_: FollowStates) -> void:
	if follow_state == follow_state_:
		return
		
	follow_state = follow_state_
	
	if follow_state_ == FollowStates.BEHIND:
		StarMonkey.camera.follow_offset = behind_follow_offset
		StarMonkey.camera.follow_target_offset = behind_follow_target_offset
	else:
		StarMonkey.camera.follow_offset = above_follow_offset
		StarMonkey.camera.follow_target_offset = above_follow_target_offset
		
