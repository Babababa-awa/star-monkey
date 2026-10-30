@abstract
extends Node3D
class_name StarMonkeyCharacter

signal pose_completed(pose: Poses)

enum Poses {
	NORMAL,
	SALUTE,
	POINT,
	PRESS_BUTTON
}

var current_pose: Poses = Poses.NORMAL
var _tween: Tween


func _ready() -> void:
	_apply_pose(current_pose, 0.0)

func set_pose(
	pose: Poses,
	duration_override: float = -1.0,
	end_delay: float = 0.0,
) -> void:
	if pose == current_pose:
		return
		
	current_pose = pose
	
	_apply_pose(pose, duration_override, end_delay)

func _apply_pose(
	pose: Poses, 
	duration_override: float = -1.0, 
	end_delay: float = 0.0
) -> void:
	var pose_data: Dictionary = get_pose_data(pose)
	
	if pose_data.is_empty():
		return
	
	var duration: float = duration_override if duration_override >= 0.0 else float(pose_data.get(&"speed", 1.0))
	var steps: Array = pose_data.get(&"steps", [])
	var num_steps: int = steps.size()
	
	if _tween:
		_tween.kill()
	
	var step_duration: float = duration / float(num_steps)
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_SINE)
	
	for step_index in range(num_steps):
		var step: Dictionary = steps[step_index]
		tween_step(_tween, step, step_duration)
	
	if end_delay > 0.0:
		_tween.tween_interval(end_delay)
	
	_tween.finished.connect(_on_pose_tween_finished.bind(pose), CONNECT_ONE_SHOT)
	
@abstract func tween_step(tween: Tween, step: Dictionary, duration: float) -> void

@abstract func get_pose_data(pose: Poses) -> Dictionary

func _on_pose_tween_finished(pose: Poses) -> void:
	pose_completed.emit(pose)
