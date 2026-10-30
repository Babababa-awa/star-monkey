extends Node
class_name StarMonkey

const ARCADE_MODE: bool = true

static var _self: StarMonkey = null
static var gravity = 9.8
static var state: GameState = GameState.MENU
static var camera: StarMonkeyCamera = null
static var menu: StarMonkeyMenu = null
static var hud: StarMonkeyHud = null
static var speech: StarMonkeySpeech = null
static var level: StarMonkeyLevel = null
static var player: StarMonkeyPlayer = null
static var bounds: StarMonkeyBounds
static var character: Characters = Characters.NONE
static var locale: Locales = Locales.EN
static var sfx: StarMonkeyGameSFX = null

static var input: StarMonkeyInputHandler = null

static var score: int = 0:
	set = _set_score

static var menu_level: StringName = &"phase_command"
static var levels: Array[StringName] = [
	&"strategy_chamber",
	&"forgotten_city",
	&"upper_phasis",
	&"daughter_ship_filia",
	&"boulder_space",
	&"tuberosa",
	&"back_space",
	&"mother_ship_anulus",
	&"dioscorea",
	&"patata_regina"
]
static var current_level: StringName = &""

static var disable_input: bool = false

static var player_states: Dictionary[StringName, StarMonkeyPlayerState] = {}

enum GameState {
	MENU,
	LOADING,
	LEVEL,
}

enum Weapons {
	NONE,
	LASER_CANNON,
	DUAL_LASER_CANNON,
	TRIPLE_LASER_CANNON,
	PULSE_CANNON,
	DUAL_PULSE_CANNON,
	TRIPLE_PULSE_CANNON,
	MONKEY_BALL
}

enum Characters {
	NONE,
	DIZZY,
	EMBER,
	JELLY,
	LUMI,
	SAKANA
}

enum Enemies {
	NONE,
	FLYING_SHOOTER_SP,
}

enum Pickups {
	NONE,
	SHIELD,
	SPECIAL,
	WEAPON_UPGRADE,
}

enum Locales {
	EN,
	JP,
}

signal level_loaded(level: StringName)
signal level_error(level: StringName)

func _ready() -> void:
	_self = self
	
	input = StarMonkeyInputHandler.new()
	
	camera = %Camera3D
	menu = %Menu
	hud = %Hud
	speech = %Speech
	bounds = %Bounds
	sfx = %GameSFX
		
	menu.start()

func _process(delta: float) -> void:
	input.process()
	
	if StarMonkey.is_action_just_pressed(&"pause"):
		if StarMonkey.menu.state == StarMonkey.menu.MenuState.PAUSE:
			StarMonkey.menu.change_state(StarMonkey.menu.MenuState.NONE)
			unpause()
		elif StarMonkey.menu.state == StarMonkey.menu.MenuState.NONE:
			StarMonkey.menu.change_state(StarMonkey.menu.MenuState.PAUSE)
			pause()

static func pause() -> void:
	_self.get_node("%Overlay").visible = false
	_self.get_node("%World").process_mode = Node.PROCESS_MODE_DISABLED
	_self.get_node("%Speech").process_mode = Node.PROCESS_MODE_DISABLED
	_self.get_node("%Hud").process_mode = Node.PROCESS_MODE_DISABLED
	#_self.get_tree().paused = true

static func unpause() -> void:
	_self.get_node("%Overlay").visible = true
	_self.get_node("%World").process_mode = Node.PROCESS_MODE_PAUSABLE
	_self.get_node("%Speech").process_mode = Node.PROCESS_MODE_PAUSABLE
	_self.get_node("%Hud").process_mode = Node.PROCESS_MODE_PAUSABLE
	#_self.get_tree().paused = false

static func load_next_level() -> void:
	load_level(get_next_level())

static func load_level(alias: StringName) -> void:
	disable_input = true
	
	clear_level()

	var path: String = get_real_path("/scenes/levels/" + alias + ".tscn")

	var err: Error = ResourceLoader.load_threaded_request(path, "PackedScene")
	if err != OK:
		push_error("Failed to start loading: " + path)
		_self.level_error.emit(alias)
		return

	var progress: Array = []
	
	while true:
		var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(path, progress)
		
		# menu.set_progress(progress[0] if progress.size() > 0 else 0.0)

		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				break
			ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				push_error("Failed to load level: " + path)
				_self.level_error.emit(alias)
				return
			_:
				await _self.get_tree().process_frame

	var scene: PackedScene = ResourceLoader.load_threaded_get(path) as PackedScene
	if scene == null:
		push_error("Loaded resource is null: " + path)
		_self.level_error.emit(alias)
		return

	level = scene.instantiate()

	if level.has_player:
		if (level.character_override != Characters.NONE and 
			level.character_override != character
		):
			await load_player(level.character_override)
		else:
			await load_player(character)
	elif player != null:
		clear_player()

	_self.get_node_or_null("%Level").add_child(level)
	level.start()
	current_level = alias
	_self.level_loaded.emit(alias)
	
	if player != null:
		enable_input_delay(0.75)
	else:
		disable_input = false

static func enable_input_delay(delay: float) -> void:
	await _self.get_tree().create_timer(delay, false).timeout
	disable_input = false

static func clear_level() -> void:
	if level != null:
		level.stop()
		level.queue_free()
		bounds.visible = false
		
	
static func load_menu(alias) -> void:
	pass

static func load_player(character_: Characters) -> void:
	clear_player()
	
	character = character_
	
	if character == Characters.NONE:
		character= Characters.JELLY
	
	var alias = &"jelly"
	
	#match character:
		#Characters.DIZZY:
			#alias = &"dizzy"
		#Characters.EMBER:
			#alias = &"ember"
		#Characters.JELLY:
			#alias = &"jelly"
		#Characters.LUMI:
			#alias = &"lumi"
	
	var path: String = get_real_path("/scenes/units/players/" + alias + ".tscn")
	var scene: PackedScene = load(path)
	player = scene.instantiate()
	
	if _self.player_states.has(alias):
		player.load_state(_self.player_states[alias])
	else:
		_self.player_states[alias] = player.save_state()
	
	_self.get_node_or_null("%Player").add_child(player)
	bounds.visible = true

static func clear_player() -> void:
	if player != null:
		player.stop()
		player.queue_free()
		player = null

static func reset_player() -> void:
	player.position = Vector3.ZERO
	player.stop()
	
static func get_instance() -> StarMonkey:
	return _self

static func get_next_level() -> StringName:
	var next = false
	
	if current_level == &"" or current_level == menu_level:
		next = true
	
	for level_: StringName in levels:
		if next:
			return level_
		elif level_ == current_level:
			next = true
	
	return &""

static func set_environment(environment: Environment) -> void:
	_self.get_node_or_null("%WorldEnvironment").environment = environment

static func add_level_child(node_: Node3D) -> void:
	level.add_child(node_)

static func _set_score(value: int) -> void:
	score = value
	hud.set_score(score)

func _input(event: InputEvent) -> void:
	input.update_input(event)

static func get_axis_x() -> float:
	if disable_input:
		return 0.0
	
	return input.get_axis_x()
	
static func get_axis_y() -> float:
	if disable_input:
		return 0.0
	
	return input.get_axis_y()

static func is_action_just_pressed(action_: StringName) -> bool:
	if disable_input:
		return false
	
	return input.is_action_just_pressed(action_)
	
	
static func is_action_pressed(action_: StringName) -> bool:
	if disable_input:
		return false
	
	return input.is_action_pressed(action_)

static func get_real_path(path_: StringName) -> StringName:
	return "res://Arcade Games/Star Monkey" + path_
