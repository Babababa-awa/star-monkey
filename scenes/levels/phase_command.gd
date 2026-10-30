extends StarMonkeyLevel

@export var follow_speed: float = 20.0

func start_camera() -> void:
	StarMonkey.camera.set_target(%PhaseCommand)
	StarMonkey.camera.set_path_follow(%PathFollow3DCamera)
	StarMonkey.camera.set_mode(StarMonkeyCamera.Modes.PATH_FOLLOW)
	
func _physics_process(delta: float) -> void:
	var old_progress: float = %PathFollow3DCraft.progress
	
	%PathFollow3DCraft.progress += follow_speed * delta
	
	if %PathFollow3DCraft.progress < old_progress:
		%PathFollow3DCraft.reset_physics_interpolation()
