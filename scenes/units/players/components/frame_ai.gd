extends Node3D
class_name StarMonkeyFrameAI

var kill_count: int = 0
var kill_delta: float = -1.0

func enemy_killed() -> void:
	kill_delta = 0.0
	kill_count += 1
	
func _process(delta: float) -> void:
	if kill_delta < 0.0:
		return
		
	kill_delta += delta
	
	if kill_delta > 1.25:
		kill_delta = -1.0
		
		if kill_count > 1:
			if StarMonkey.locale == StarMonkey.Locales.EN:
				%AudioStreamPlayerEnemiesKilled.play()
			else:
				%AudioStreamPlayerEnemiesKilledJP.play()
		else:
			if StarMonkey.locale == StarMonkey.Locales.EN:
				%AudioStreamPlayerEnemyKilled.play()
			else:
				%AudioStreamPlayerEnemyKilledJP.play()
		
		kill_count = 0
		
func play_victory(delay: float = 0.0) -> void:
	if not is_zero_approx(delay):
		await get_tree().create_timer(delay, false).timeout
	
	if StarMonkey.locale == StarMonkey.Locales.EN:
		%AudioStreamPlayerVictory.play()
	else:
		%AudioStreamPlayerVictoryJP.play()
	
func play_victory_full(delay: float = 0.0) -> void:
	if not is_zero_approx(delay):
		await get_tree().create_timer(delay, false).timeout
	
	if StarMonkey.locale == StarMonkey.Locales.EN:
		%AudioStreamPlayerVictoryFull.play()
	else:
		%AudioStreamPlayerVictoryFullJP.play()

func play_pickup_speical(delay: float = 0.0) -> void:
	if not is_zero_approx(delay):
		await get_tree().create_timer(delay, false).timeout
	
	if StarMonkey.locale == StarMonkey.Locales.EN:
		%AudioStreamPlayerPickupSpecial.play()
	else:
		%AudioStreamPlayerPickupSpecialJP.play()
	
func play_pickup_weapon_upgrade(delay: float = 0.0) -> void:
	if not is_zero_approx(delay):
		await get_tree().create_timer(delay, false).timeout
	
	if StarMonkey.locale == StarMonkey.Locales.EN:
		%AudioStreamPlayerPickupWeaponUpgrade.play()
	else:
		%AudioStreamPlayerPickupWeaponUpgradeJP.play()
	
func play_pickup_shield(delay: float = 0.0) -> void:
	if not is_zero_approx(delay):
		await get_tree().create_timer(delay, false).timeout
	
	if StarMonkey.locale == StarMonkey.Locales.EN:
		%AudioStreamPlayerPickupShield.play()
	else:
		%AudioStreamPlayerPickupShieldJP.play()

func play_shields_down(delay: float = 0.0) -> void:
	if not is_zero_approx(delay):
		await get_tree().create_timer(delay, false).timeout
	
	if StarMonkey.locale == StarMonkey.Locales.EN:
		%AudioStreamPlayerShieldsDown.play()
	else:
		%AudioStreamPlayerShieldsDownJP.play()
		
func play_shields_restored(delay: float = 0.0) -> void:
	if not is_zero_approx(delay):
		await get_tree().create_timer(delay, false).timeout
	
	if StarMonkey.locale == StarMonkey.Locales.EN:
		%AudioStreamPlayerShieldsRestored.play()
	else:
		%AudioStreamPlayerShieldsRestoredJP.play()
	
func play_pickup() -> void:
	%AudioStreamPlayerPickup.pitch_scale = randf_range(0.9, 1.0)
	%AudioStreamPlayerPickup.play()
