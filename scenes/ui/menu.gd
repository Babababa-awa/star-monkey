extends Node3D
class_name StarMonkeyMenu

@export_group("Text")
@export var text_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var select_text_color: Color = Color(90, 0.87, 0.0, 1.0)
@export var select_text_speed: float = 0.6

@export_group("Insert Coin")
@export var logo_rotation_speed: float = 1.0

@export_group("Continue")
@export var continue_countdown_duration: int = 10

var state: MenuState = MenuState.NONE

var selected_text_material: StandardMaterial3D = null
var selected_text_mesh: MeshInstance3D = null

var continue_yes: bool = false
var current_continue_countdown: float = 0.0

var skip_scene_yes: bool = false

var selected_text_time: float = 0.0

enum MenuState {
	NONE,
	INSERT_COIN,
	LOCALE_SELECT,
	CHARACTER_SELECT,
	CONTINUE,
	SKIP_SCENE,
	LOADING,
	PAUSE,
	VICTORY,
}

signal skip_scene(skip: bool)

func _ready() -> void:
	change_state(MenuState.LOADING)
	selected_text_material = load(StarMonkey.get_real_path("/materials/text/selectable_text_material.tres")).duplicate()

	var cab = ArcadeCabinet.get_cabinet(self)
	if cab:
		cab.coin_inserted.connect(_on_insert_coin)

func start() -> void:
	StarMonkey.get_instance().level_loaded.connect(_on_level_loaded)
	
	StarMonkey.load_level(StarMonkey.menu_level)

func change_state(state_: MenuState) -> void:
	if state_ == state && visible:
		return
	
	await get_tree().process_frame 
	
	state = state_
	
	reset_state(state_)
	
	%InsertCoin.visible = false
	%LocaleSelect.visible = false
	%CharacterSelect.visible = false
	%Continue.visible = false
	%SkipScene.visible = false
	%Loading.visible = false
	%Pause.visible = false
	%Victory.visible = false
	
	if state == MenuState.NONE:
		visible = false
	else:
		visible = true
	
	match state:
		MenuState.INSERT_COIN:
			%InsertCoin.visible = true
		MenuState.LOCALE_SELECT:
			%LocaleSelect.visible = true
		MenuState.CHARACTER_SELECT:
			%CharacterSelect.visible = true
		MenuState.CONTINUE:
			%Continue.visible = true
		MenuState.SKIP_SCENE:
			%SkipScene.visible = true
		MenuState.LOADING:
			%Loading.visible = true
		MenuState.PAUSE:
			%Pause.visible = true
		MenuState.VICTORY:
			%Victory.visible = true

func reset_state(state_: MenuState) -> void:
	match state_:
		MenuState.INSERT_COIN:
			show_game_title()
			show_logo()
			hide_yes_no()
			%Logo.rotation.y = 0.0
			select_text(%InsertCoinText)
			%Jelly.set_pose(StarMonkeyCharacter.Poses.NORMAL, 0.0)
			%Jelly.set_pose(StarMonkeyCharacter.Poses.SALUTE, -1.0, 2.0)
		MenuState.LOCALE_SELECT:
			show_game_title()
			hide_logo()
			hide_yes_no()
			if StarMonkey.locale == StarMonkey.Locales.EN:
				select_text(%EnglishText)
			else:
				select_text(%JapaneseText)
		MenuState.CHARACTER_SELECT:
			hide_game_title()
			hide_logo()
			hide_yes_no()
		MenuState.CONTINUE:
			hide_game_title()
			hide_logo()
			show_yes_no()
			
			StarMonkey.hud.hide_hud()
			
			%Countdown.set_value(continue_countdown_duration)
			current_continue_countdown = float(continue_countdown_duration) + 0.4
			
			%AudioStreamPlayerCountdown.pitch_scale = randf_range(0.95, 1.05)
			%AudioStreamPlayerCountdown.play()
				
			if StarMonkey.locale == StarMonkey.Locales.EN:
				%ContinueJPText.visible = false
				%ContinueText.visible = true
				
				select_text(%YesText)
			else:
				%ContinueText.visible = false
				%ContinueJPText.visible = true
				
				select_text(%YesJPText)
			
			continue_yes = true
		MenuState.SKIP_SCENE:
			StarMonkey.pause()
			
			hide_game_title()
			hide_logo()
			show_yes_no()
			
			if StarMonkey.locale == StarMonkey.Locales.EN:
				%SkipSceneJPText.visible = false
				%SkipSceneText.visible = true
				
				select_text(%NoText)
			else:
				%SkipSceneText.visible = false
				%SkipSceneJPText.visible = true
				
				select_text(%NoJPText)
				
			skip_scene_yes = false
		MenuState.LOADING:
			hide_game_title()
			hide_logo()
			hide_yes_no()
			
			if StarMonkey.locale == StarMonkey.Locales.EN:
				%LoadingJPText.visible = false
				%LoadingText.visible = true
			else:
				%LoadingText.visible = false
				%LoadingJPText.visible = true
		MenuState.PAUSE:
			hide_game_title()
			show_logo()
			hide_yes_no()
			
			if StarMonkey.locale == StarMonkey.Locales.EN:
				%PauseJPText.visible = false
				%PauseText.visible = true
			else:
				%PauseText.visible = false
				%PauseJPText.visible = true
		MenuState.VICTORY:
			hide_game_title()
			hide_logo()
			hide_yes_no()
			
			StarMonkey.hud.hide_hud()
			
			if StarMonkey.locale == StarMonkey.Locales.EN:
				%VictoryJPText.visible = false
				%VictoryText.visible = true
				
				%ScoreJPText.visible = false
				%ScoreText.visible = true
			else:
				%VictoryText.visible = false
				%VictoryJPText.visible = true
				
				%ScoreText.visible = false
				%ScoreJPText.visible = true
				
			%Score.set_value(StarMonkey.score)

func _process(delta: float) -> void:
	if selected_text_mesh != null:
		selected_text_time += delta
		var t: float = (sin(selected_text_time * select_text_speed * TAU) + 1.0) * 0.5
		var color: Color = text_color.lerp(select_text_color, t)
		selected_text_material.albedo_color = color
		selected_text_material.emission = color
	
	match state:
		MenuState.INSERT_COIN:
			pass
		MenuState.LOCALE_SELECT:
			#if StarMonkey.is_action_just_pressed(&"back"):
				#change_state(MenuState.INSERT_COIN)
				#%AudioStreamPlayerSelect.pitch_scale = randf_range(0.9, 1.1)
				#%AudioStreamPlayerSelect.play()
			if (StarMonkey.is_action_just_pressed(&"move_up") or
				StarMonkey.is_action_just_pressed(&"move_down")
			):
				if StarMonkey.locale == StarMonkey.Locales.EN:
					StarMonkey.locale = StarMonkey.Locales.JP
					select_text(%JapaneseText)
				else:
					StarMonkey.locale = StarMonkey.Locales.EN
					select_text(%EnglishText)
				
				%AudioStreamPlayerMove.pitch_scale = randf_range(0.9, 1.1)
				%AudioStreamPlayerMove.play()
				
				show_game_title()
			elif StarMonkey.is_action_just_pressed(&"forward"):
				change_state(MenuState.LOADING)
				%AudioStreamPlayerSelect.pitch_scale = randf_range(0.9, 1.1)
				%AudioStreamPlayerSelect.play()
				StarMonkey.player_states.clear()
				StarMonkey.score = 0
				StarMonkey.load_next_level()
				
		MenuState.CHARACTER_SELECT:
			pass
		MenuState.CONTINUE:
			current_continue_countdown -= delta
			
			if %Countdown.set_value(roundi(current_continue_countdown)):
				%AudioStreamPlayerCountdown.pitch_scale = randf_range(0.95, 1.05)
				%AudioStreamPlayerCountdown.play()
			
			if current_continue_countdown <= -0.5:
				change_state(MenuState.LOADING)
				%AudioStreamPlayerCountdownEnd.pitch_scale = randf_range(0.9, 1.1)
				%AudioStreamPlayerCountdownEnd.play()
				StarMonkey.load_level(StarMonkey.menu_level)
			elif (StarMonkey.is_action_just_pressed(&"move_left") or
				StarMonkey.is_action_just_pressed(&"move_right")
			):
				continue_yes = !continue_yes
				
				if StarMonkey.locale == StarMonkey.Locales.EN:
					if continue_yes:
						select_text(%YesText)
					else:
						select_text(%NoText)
				else:
					if continue_yes:
						select_text(%YesJPText)
					else:
						select_text(%NoJPText)
				
				%AudioStreamPlayerMove.pitch_scale = randf_range(0.9, 1.1)
				%AudioStreamPlayerMove.play()
			elif (
				StarMonkey.is_action_just_pressed(&"forward") or
				StarMonkey.is_action_just_pressed(&"back")
			):
				change_state(MenuState.LOADING)
				%AudioStreamPlayerSelect.pitch_scale = randf_range(0.9, 1.1)
				%AudioStreamPlayerSelect.play()
				
				if continue_yes:
					StarMonkey.load_level(StarMonkey.current_level)
				else:
					StarMonkey.load_level(StarMonkey.menu_level)
		MenuState.SKIP_SCENE:
			if (StarMonkey.is_action_just_pressed(&"move_left") or
				StarMonkey.is_action_just_pressed(&"move_right")
			):
				skip_scene_yes = !skip_scene_yes
				
				if StarMonkey.locale == StarMonkey.Locales.EN:
					if skip_scene_yes:
						select_text(%YesText)
					else:
						select_text(%NoText)
				else:
					if skip_scene_yes:
						select_text(%YesJPText)
					else:
						select_text(%NoJPText)
				
				%AudioStreamPlayerMove.pitch_scale = randf_range(0.9, 1.1)
				%AudioStreamPlayerMove.play()
			elif (
				StarMonkey.is_action_just_pressed(&"forward") or
				StarMonkey.is_action_just_pressed(&"back")
			):
				change_state(MenuState.NONE)
				%AudioStreamPlayerSelect.pitch_scale = randf_range(0.9, 1.1)
				%AudioStreamPlayerSelect.play()
				StarMonkey.unpause()
				skip_scene.emit(skip_scene_yes)
		MenuState.VICTORY:
			if (
				StarMonkey.is_action_just_pressed(&"forward") or
				StarMonkey.is_action_just_pressed(&"back")
			):
				change_state(MenuState.LOADING)
				%AudioStreamPlayerSelect.pitch_scale = randf_range(0.9, 1.1)
				%AudioStreamPlayerSelect.play()
				StarMonkey.load_level(StarMonkey.menu_level)

func _on_insert_coin() -> void:
	change_state(MenuState.LOCALE_SELECT)
	%AudioStreamPlayerSelect.pitch_scale = randf_range(0.9, 1.1)
	%AudioStreamPlayerSelect.play()

func _physics_process(delta: float) -> void:
	match state:
		MenuState.INSERT_COIN:
			%Logo.rotate_y(logo_rotation_speed * delta)
		MenuState.PAUSE:
			%Logo.rotate_y(logo_rotation_speed * delta)
			
func show_game_title() -> void:
	if StarMonkey.locale == StarMonkey.Locales.EN:
		%StarMonkeyText.visible = true
		%StarMonkeyJPText.visible = false
	else:
		%StarMonkeyJPText.visible = true
		%StarMonkeyText.visible = false
	
func hide_game_title() -> void:
	%StarMonkeyText.visible = false
	%StarMonkeyJPText.visible = false

func show_logo() -> void:
	%Logo.visible = true
	
func hide_logo() -> void:
	%Logo.visible = false

func show_yes_no() -> void:
	if StarMonkey.locale == StarMonkey.Locales.EN:
		%NoJPText.visible = false
		%YesJPText.visible = false
		
		%NoText.visible = true
		%YesText.visible = true
	else:
		%NoText.visible = false
		%YesText.visible = false
		
		%NoJPText.visible = true
		%YesJPText.visible = true
	
func hide_yes_no() -> void:
	%NoText.visible = false
	%YesText.visible = false
	
	%NoJPText.visible = false
	%YesJPText.visible = false

func select_text(mesh: MeshInstance3D) -> void:
	if selected_text_mesh != null:
		unselect_text(selected_text_mesh)
		
	selected_text_mesh = mesh
	mesh.set_surface_override_material(0, selected_text_material)
	selected_text_time = 0.0
	
func unselect_text(mesh: MeshInstance3D) -> void:
	mesh.set_surface_override_material(0, null)

func _on_jelly_pose_completed(pose: StarMonkeyCharacter.Poses) -> void:
	if state == MenuState.INSERT_COIN:
		if pose == StarMonkeyCharacter.Poses.NORMAL:
			%Jelly.set_pose(StarMonkeyCharacter.Poses.SALUTE, -1.0, 2.0)
		else:
			%Jelly.set_pose(StarMonkeyCharacter.Poses.NORMAL, -1.0, 2.0)

func _on_level_loaded(alias: StringName) -> void:
	if alias == StarMonkey.menu_level:
		change_state(MenuState.INSERT_COIN)
	else:
		change_state(MenuState.NONE)
