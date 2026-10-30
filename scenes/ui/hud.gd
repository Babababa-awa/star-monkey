extends Node3D
class_name StarMonkeyHud

var _player_health_ratio: float = 0.0
var _player_shield_ratio: float = 0.0

func _ready() -> void:
	set_player_health(100, 100)
	set_player_shield(100, 100)
	set_player_special_count(5, 5)
	
func show_hud() -> void:
	visible = true
	update_text()
	
func hide_hud() -> void:
	visible = false
	
func show_boss_box() -> void:
	%BossBox.visible = true
	%BossHealth.visible = true
	%BossShield.visible = true
	
	if StarMonkey.locale == StarMonkey.Locales.EN:
		%BossText.visible = true
		%BossJPText.visible = false
	else:
		%BossJPText.visible = true
		%BossText.visible = false

func hide_boss_box() -> void:
	%BossBox.visible = false
	%BossHealth.visible = false
	%BossShield.visible = false
	%BossText.visible = false
	%BossJPText.visible = false

func set_boss_health(current_health: int, max_health: int) -> void:
	pass

func set_boss_shield(current_health: int, max_health: int) -> void:
	pass

func set_score(score: int) -> void:
	pass

func set_player_health(current_health: int, max_health: int) -> void:
	if current_health == 0:
		%PlayerHealth.visible = false
	else:
		%PlayerHealth.visible = true
		
		_player_health_ratio = maxf(0.0, current_health) / max_health
		
		var width: float = 1.31 * _player_health_ratio
		%PlayerHealth.position.x = -2.475 - ((1.31 - width) / 2)
		%PlayerHealth.mesh.size.x = width
		
	update_text()

func set_player_shield(current_shield: int, max_shield: int) -> void:
	if current_shield == 0:
		%PlayerShield.visible = false
	else:
		%PlayerShield.visible = true
		
		_player_shield_ratio = maxf(0.0, current_shield) / max_shield
		
		var width: float = 1.31 * _player_shield_ratio
		%PlayerShield.position.x = -2.475 - ((1.31 - width) / 2)
		%PlayerShield.mesh.size.x = width
		
	update_text()
	
func set_player_special_count(current_special_count: int, max_special_count: int) -> void:
	if current_special_count >= 5:
		%PlayerSpecial5.visible = true
	else:
		%PlayerSpecial5.visible = false

	if current_special_count >= 4:
		%PlayerSpecial4.visible = true
	else:
		%PlayerSpecial4.visible = false
		
	if current_special_count >= 4:
		%PlayerSpecial4.visible = true
	else:
		%PlayerSpecial4.visible = false
	
	if current_special_count >= 3:
		%PlayerSpecial3.visible = true
	else:
		%PlayerSpecial3.visible = false
	
	if current_special_count >= 2:
		%PlayerSpecial2.visible = true
	else:
		%PlayerSpecial2.visible = false
		
	if current_special_count >= 1:
		%PlayerSpecial1.visible = true
	else:
		%PlayerSpecial1.visible = false
		
	update_text()

func update_text() -> void:
	if StarMonkey.locale == StarMonkey.Locales.EN:
		%BossJPText.visible = false
		%FrameIntegrityJPText.visible = false
		%MonkeyBallsJPText.visible = false
		%ShieldJPText.visible = false
		
		if %PlayerShield.visible:
			%ShieldText.visible = true
			%FrameIntegrityText.visible = false
		else:
			%ShieldText.visible = false
			%FrameIntegrityText.visible = true
			
		%MonkeyBallsText.visible = %PlayerSpecial1.visible
	else:
		%BossText.visible = false
		%FrameIntegrityText.visible = false
		%MonkeyBallsText.visible = false
		%ShieldText.visible = false
		
		if %PlayerShield.visible:
			%ShieldJPText.visible = true
			%FrameIntegrityJPText.visible = false
		else:
			%ShieldJPText.visible = false
			%FrameIntegrityJPText.visible = true
			
		%MonkeyBallsJPText.visible = %PlayerSpecial1.visible
