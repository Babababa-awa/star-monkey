extends Node3D

@export var distance: float = 4.5
@export var duration: float = 2.0
@export var start_delay: float = 0.0

func _ready() -> void:
	if start_delay > 0.0:
		await get_tree().create_timer(start_delay, false).timeout
	
	_start_moving()

func _start_moving() -> void:
	var tween: Tween = create_tween().set_loops()
	if is_physics_interpolated_and_enabled():
		tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	var origin_y: float = %DamageArea3D.position.y

	tween.tween_property(%DamageArea3D, "position:y", origin_y + distance, duration)
	tween.tween_interval(0.2)
	tween.tween_property(%DamageArea3D, "position:y", origin_y, duration)
	tween.tween_interval(0.2)
