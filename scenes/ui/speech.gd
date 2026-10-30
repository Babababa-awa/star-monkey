extends Node3D
class_name StarMonkeySpeech

@export var next_rotate_speed: float = 1.0

var current_has_next = false
var pause_visibility: bool = false

func reset() -> void:
	current_has_next = false

func _physics_process(delta: float) -> void:
	%Continue.rotation.x = wrapf(%Continue.rotation.x + -next_rotate_speed * delta, 0.0, TAU)

func show_speech(
	character: StarMonkey.Characters,
	text: String,
	has_next: bool = false,
) -> void:
	%LabelName.text = get_character_name(character)
	%LabelSpeech.text = text
	visible = true
	%MarginContainer.visible = true
	
	if current_has_next:
		%AudioStreamPlayerNext.pitch_scale = randf_range(0.9, 1.1)
		%AudioStreamPlayerNext.play()
	
	current_has_next = has_next

func restore_speech() -> void:
	visible = true
	%MarginContainer.visible = true
	
func hide_speech() -> void:
	visible = false
	%MarginContainer.visible = false
	
func get_character_name(character: StarMonkey.Characters) -> String:
	var character_name = ""
	
	if StarMonkey.locale == StarMonkey.Locales.EN:
		match character:
			StarMonkey.Characters.DIZZY:
				character_name = "Dizzy (Bugout)"
			StarMonkey.Characters.EMBER:
				character_name = "Ember (Embargo)"
			StarMonkey.Characters.JELLY:
				character_name = "Jelly (Star Monkey)"
			StarMonkey.Characters.LUMI:
				character_name = "Lumi (Yay Okay)"
			StarMonkey.Characters.SAKANA:
				character_name = "Sakana (Fishman)"
	else:
		match character:
			StarMonkey.Characters.DIZZY:
				character_name = "ディズィー (バグアウト)"
			StarMonkey.Characters.EMBER:
				character_name = "エンバー (エンバーゴ)"
			StarMonkey.Characters.JELLY:
				character_name = "ジェリー (スターモンキー)"
			StarMonkey.Characters.LUMI:
				character_name = "瑠美 (イェーイ オッケー)"
			StarMonkey.Characters.SAKANA:
				character_name = "サカナ (フィッシュマン)"
	
	return character_name
	
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PAUSED:
			pause_visibility = %MarginContainer.visible
			%MarginContainer.visible = false
		NOTIFICATION_UNPAUSED:
			%MarginContainer.visible = pause_visibility
