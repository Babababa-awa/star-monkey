extends Node3D
class_name StarMonkeyLevel

@export var environment: Environment = null
@export var level_state: Dictionary[StringName, Variant] = {}

@export_subgroup("Player")
@export var has_player: bool = false
@export var character_override: StarMonkey.Characters = StarMonkey.Characters.NONE

@export_subgroup("Camera")
@export var camera_state: StarMonkeyCameraState

signal level_state_changed(keys: Array[StringName])

func _init() -> void:
	if camera_state == null:
		camera_state = StarMonkeyCameraState.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	
func start() -> void:
	%AudioStreamPlayerMusic.play()
	
	process_mode = Node.PROCESS_MODE_INHERIT
	
	StarMonkey.set_environment(environment)
	
	if StarMonkey.player != null:
		StarMonkey.bounds.start()
		StarMonkey.player.start()
		StarMonkey.hud.show_hud()
	else:
		StarMonkey.hud.hide_hud()
		StarMonkey.bounds.stop()
		
	StarMonkey.speech.reset()
	
	camera_state.change_follow_state(StarMonkeyCameraState.FollowStates.ABOVE)
	
	start_camera()

func stop() -> void:
	%AudioStreamPlayerMusic.stop()
	
	process_mode = Node.PROCESS_MODE_DISABLED
	if StarMonkey.player != null:
		StarMonkey.player.stop()

	camera_state.change_follow_state(StarMonkeyCameraState.FollowStates.ABOVE)

	stop_camera()

func start_camera() -> void:
	if StarMonkey.player != null:
		StarMonkey.camera.set_target(StarMonkey.player)
		StarMonkey.camera.set_mode(StarMonkeyCamera.Modes.FOLLOW)
	else:
		StarMonkey.camera.set_target(null)
		StarMonkey.camera.set_mode(StarMonkeyCamera.Modes.ROTATE_AROUND)

func stop_camera() -> void:
	StarMonkey.camera.set_target(null)
	StarMonkey.camera.set_path_follow(null)

func fade_out_audio(player: AudioStreamPlayer, duration: float = 1.0) -> void:
	if not player.playing:
		return

	if player.has_meta("fade_tween"):
		var old: Tween = player.get_meta("fade_tween")
		if old and old.is_valid():
			old.kill()

	var tween: Tween = create_tween()
	player.set_meta("fade_tween", tween)

	tween.tween_property(player, "volume_linear", 0.0, duration)
	await tween.finished

	player.stop()
	player.volume_linear = 1.0
	player.remove_meta("fade_tween")
