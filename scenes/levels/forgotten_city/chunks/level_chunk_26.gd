extends StarMonkeyGroundLevelChunk

func _ready() -> void:
	super._ready()
	
	for ring_group: StarMonkeyRingGroup in StarMonkey.level.ring_groups:
		if ring_group.alias == &"first":
			if ring_group.completed:
				_enable_weapon_upgrade()
			else:
				StarMonkey.level.level_state_changed.connect(_on_level_state_changed)
	
func _on_level_state_changed(keys: Array[StringName]) -> void:
	if keys.has(&"ring_group_completed"):
		_enable_weapon_upgrade()
		
func _enable_weapon_upgrade() -> void:
		%WeaponUpgradePickup.process_mode = Node.PROCESS_MODE_INHERIT
		%WeaponUpgradePickup.visible = true
		
		%ShieldPickup.process_mode = Node.PROCESS_MODE_DISABLED
		%ShieldPickup.visible = false
