extends StarMonkeyLevel

# /materials/object/holo_table/grid.tres
const GRID = preload("uid://capwab15eh1qf")

var current_speech: int = -1

var step: int = 0

var restore_speech: bool = false

var wireframe_rotate_speed: float = 40.0

var speech: Array = [
	{
		&"character": StarMonkey.Characters.SAKANA,
		&"text": {
			&"EN": "Hey man, our defense array picked up these things flying around the forgotten city.",
			&"JP": "おい、うちの防衛アレイが、忘れられた都市の周辺を飛んでいるものを探知したぞ。"
		}
	},
	{
		&"character": StarMonkey.Characters.SAKANA,
		&"text": {
			&"EN": "They appear to have weapons so they probably aren't friendly.",
			&"JP": "武器を持っているみたいだから、たぶん味方じゃないな。"
		}
	},
	{
		&"character": StarMonkey.Characters.JELLY,
		&"text": {
			&"EN": "Okay sir, so should I go out and destroy them?",
			&"JP": "了解です、閣下。では外に出て破壊しますか？"
		}
	},
	{
		&"character": StarMonkey.Characters.SAKANA,
		&"text": {
			&"EN": "Yes, they should have called first.",
			&"JP": "ああ、先に連絡してくるべきだったな。"
		}
	},
	{
		&"character": StarMonkey.Characters.JELLY,
		&"text": {
			&"EN": "What's that thing in the center? It looks like a Sweet Potato.",
			&"JP": "中央にあるあれは何だ？サツマイモみたいだな。"
		},
		&"pose": StarMonkeyCharacter.Poses.POINT,
	},
	{
		&"character": StarMonkey.Characters.SAKANA,
		&"text": {
			&"EN": "We believe it's the brain. Their behavior doesn't really make sense to us, so keep your bananas peeled.",
			&"JP": "あれが脳だと思う。奴らの行動は我々にはよくわからないから、バナナの皮をしっかりむいておけ"
		}
	},
	{
		&"character": StarMonkey.Characters.JELLY,
		&"text": {
			&"EN": "Will do sir!",
			&"JP": "了解です、閣下！"
		}
	},
	{
		&"character": StarMonkey.Characters.SAKANA,
		&"text": {
			&"EN": "Alright, suit up and head out!",
			&"JP": "よし、装備を整えて出撃しろ！"
		},
		&"pose": StarMonkeyCharacter.Poses.POINT,
	},
	{
		&"character": StarMonkey.Characters.JELLY,
		&"text": {
			&"EN": "Sir, yes sir!",
			&"JP": "はいっ、閣下！"
		},
		&"pose": StarMonkeyCharacter.Poses.SALUTE,
	},
]

func _ready() -> void:
	super._ready()

	StarMonkey.menu.skip_scene.connect(_on_skip_scene)

func start_camera() -> void:
	StarMonkey.camera.rotate_around_target_offset = Vector3(0.0, 0.0, 0.0)
	StarMonkey.camera.rotate_around_offset = Vector3(0.0, 7.0, 0.0)
	StarMonkey.camera.rotate_around_target_distance = 8.0
	StarMonkey.camera.rotate_around_look_distance = 1.0
	
	super.start_camera()

func _process(delta: float) -> void:
	%Wireframe.rotation_degrees.y += wireframe_rotate_speed * delta
	
	if StarMonkey.menu.state != StarMonkey.menu.MenuState.NONE:
		return
	
	if step == 0:
		turn_table_on()
		
	if step == 3 or step == 5:
		if current_speech == -1 or StarMonkey.is_action_just_pressed(&"forward"):
			if current_speech == 4:
				sweet_potato()
				return
			else:
				current_speech += 1
			
			if current_speech == speech.size():
				end_scene()
			else:
				show_speech()
				pose()
				dialogue_audio()
				
			if current_speech == 0:
				pass
				
	if StarMonkey.is_action_just_pressed(&"back"):
		restore_speech = StarMonkey.speech.visible
		if restore_speech:
			StarMonkey.speech.hide_speech()
		StarMonkey.menu.change_state(StarMonkey.menu.MenuState.SKIP_SCENE)

func turn_table_on() -> void:
	step = 2
	await get_tree().create_timer(1.0, false).timeout
	%Sakana.set_pose(StarMonkeyCharacter.Poses.PRESS_BUTTON)
	await get_tree().create_timer(0.375, false).timeout
	%AudioStreamPlayerTurnOn.play()
	await get_tree().create_timer(0.5, false).timeout
	%AudioStreamPlayerHum.play()
	await get_tree().create_timer(0.25, false).timeout
	%HoloTable.mesh.surface_set_material(2, GRID)
	%Wireframe.visible = true
	await get_tree().create_timer(0.5, false).timeout
	step = 3

func sweet_potato() -> void:
	step = 4
	StarMonkey.speech.hide_speech()
	await get_tree().create_timer(0.5, false).timeout
	%Sakana.set_pose(StarMonkeyCharacter.Poses.PRESS_BUTTON)
	await get_tree().create_timer(0.375, false).timeout
	%AudioStreamPlayerTurnOn.play()
	await get_tree().create_timer(0.5, false).timeout
	%Wireframe.get_node("Wireframe_Base").visible = false
	%Wireframe.get_node("Wireframe_GlassDome").visible = false
	%Wireframe.get_node("Wireframe_BottomDome").visible = false
	%Wireframe.get_node("Wireframe_PulseCannonNoBarrelRight").visible = false
	%Wireframe.get_node("Wireframe_PulseCannonNoBarrelLeft").visible = false
	step = 5
	current_speech += 1
	show_speech()
	pose()
	dialogue_audio()

func pose() -> void:
	if not speech[current_speech].has(&"pose"):
		%Jelly.set_pose(StarMonkeyCharacter.Poses.NORMAL)
		%Sakana.set_pose(StarMonkeyCharacter.Poses.NORMAL)
		return
		
	if speech[current_speech].character == StarMonkey.Characters.JELLY:
		%Jelly.set_pose(speech[current_speech].pose)
		%Sakana.set_pose(StarMonkeyCharacter.Poses.NORMAL)
	else:
		%Sakana.set_pose(speech[current_speech].pose)
		%Jelly.set_pose(StarMonkeyCharacter.Poses.NORMAL)

func show_speech() -> void:
	var has_next = current_speech < speech.size()
	
	if StarMonkey.locale == StarMonkey.Locales.EN:
		StarMonkey.speech.show_speech(
			speech[current_speech].character,
			speech[current_speech].text.EN,
			has_next
		)
	else:
		StarMonkey.speech.show_speech(
			speech[current_speech].character,
			speech[current_speech].text.JP,
			has_next
		)

func end_scene() -> void:
	StarMonkey.speech.hide_speech()
	StarMonkey.menu.change_state(StarMonkey.menu.MenuState.LOADING)
	StarMonkey.load_next_level()
	
func _on_skip_scene(skip: bool) -> void:
	if skip:
		end_scene()
	elif restore_speech:
		StarMonkey.speech.restore_speech()

func dialogue_audio() -> void:
	if current_speech == 2:
		%AudioStreamPlayerJelly1.play()
	elif current_speech == 3:
		%AudioStreamPlayerJelly1.stop()
	elif current_speech == 4:
		%AudioStreamPlayerJelly2.play()
	elif current_speech == 5:
		%AudioStreamPlayerJelly2.stop()
	elif current_speech == 6:
		%AudioStreamPlayerJelly3.play()
	elif current_speech == 7:
		%AudioStreamPlayerJelly3.stop()
	elif current_speech == 8:
		%AudioStreamPlayerJelly4.play()
