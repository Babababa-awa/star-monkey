extends CharacterBody3D
class_name StarMonkeyEnemy

@export_group("Sweet Potato")
@export var sweet_potato_max_move: float = 0.12
@export var sweet_potato_speed: float = 1.5

@export_subgroup("Boss")
@export var is_boss: bool = false

@export_group("Movement")
@export var move_speed: float = 6.0
@export var hover_max_move: float = 1.0
@export var hover_speed: float = 1.5

@export_group("Defense")
@export var max_health: int = 100
@export var max_shield: int = 100

@export_group("Offense")
@export var current_weapon: StarMonkey.Weapons = StarMonkey.Weapons.LASER_CANNON:
	set = _set_current_weapon
@export var attack_proximity: float = 56.0

@export_group("Damage")
@export var damage_delay: float = 0.0
@export var kill_delay: float = 0.0

@export_subgroup("Pulse Cannon")
@export var pulse_cannon_cooldown: float = 1.0
@export var pulse_cannon_rotate_speed: float = 24.0
@export var pulse_cannon_roate_limit: float = 35.0
@export var pulse_shot_follow_speed: float = 0.0

var current_health: int = 100
var current_shield: int = 0

var state: EnemyState = EnemyState.IDLE
	
enum EnemyState {
	IDLE,
	ATTACK,
}

var is_invincible: bool = false

signal kill_before
signal kill_after
signal damage_taken
signal shield_taken

var is_weapon_cooldown: bool = false
var is_special_cooldown: bool = false
var is_killed: bool = false

var _hover_origin_y: float = 0.0
var _hover_time: float = 0.0
var path_follow: PathFollow3D = null
var path_follow_reverse_loop: bool = false
var _path_follow_reverse: bool = false
var _has_set_initial_position: bool = false

func _ready() -> void:
	current_health = max_health

	_hover_origin_y = global_position.y
	%DamageArea3D.body_entered.connect(_on_body_entered)
	%Weapon.cooldown = pulse_cannon_cooldown
	
func _process(delta: float) -> void:
	if is_killed:
		return
	
	_update_state()
	
	if state == EnemyState.ATTACK:
		_shoot_weapon()

func _update_state() -> void:
	if not is_instance_valid(StarMonkey.player):
		return
		
	if StarMonkey.player.is_killed:
		state = EnemyState.IDLE
		return
		
	if StarMonkey.level is StarMonkeyChunkLevel:
		if (StarMonkey.level.chunk_type == StarMonkeyChunkLevel.ChunkType.LINE or
			StarMonkey.level.chunk_type == StarMonkeyChunkLevel.ChunkType.LINE_REPEATING
		):
			if StarMonkey.player.global_position.z < global_position.z - 16:
				state = EnemyState.IDLE
				return
	
	var diff: Vector3 = StarMonkey.player.global_position - global_position
	var distance: float = diff.length()

	if distance > attack_proximity:
		state = EnemyState.IDLE
	else:
		state = EnemyState.ATTACK
		
func _physics_process(delta: float) -> void:
	if is_killed:
		return
	
	_aim_weapon(delta)
	if state == EnemyState.ATTACK:
		_aim_weapon(delta)
		
	if path_follow == null:
		_hover_time += delta
		global_position.y = _hover_origin_y + sin(_hover_time * hover_speed) * hover_max_move
	else:
		var t: float = path_follow.progress_ratio
		var ease_value: float = 1.0
		if t < 0.2:
			t = t / 0.2
			ease_value = t * t * (3.0 - 2.0 * t)
			pass
		elif t > 0.8:
			t = (0.2 - (t - 0.8)) / 0.2
			ease_value = t * t * (3.0 - 2.0 * t)
			pass
			
		ease_value = max(0.4, ease_value)
		
		if _path_follow_reverse:
			path_follow.progress -= move_speed * ease_value * delta
			global_position = path_follow.global_position
			
			if path_follow.progress <= 0.0:
				_path_follow_reverse = false
		else:
			path_follow.progress += move_speed * ease_value * delta
			global_position = path_follow.global_position
			
			var max_progress: float = path_follow.get_parent().curve.get_baked_length()
			if path_follow.progress >= max_progress:
				if path_follow_reverse_loop:
					_path_follow_reverse = true
				elif not path_follow.loop:
					path_follow = null

func _aim_weapon(delta: float) -> void:
	pass

func _shoot_weapon() -> void:
	pass

func take_damage(damage: int, independent: bool = false, source: Node3D = null) -> void:
	if is_invincible and not independent:
		return
		
	is_invincible = true
	
	if current_shield > 0.0:
		current_shield -= damage
		shield_taken.emit()
		
		if is_boss:
			StarMonkey.hud.set_boss_shield(current_shield, max_shield)
	else:
		current_health -= damage
		damage_taken.emit()
		
		if is_boss:
			StarMonkey.hud.set_boss_health(current_health, max_health)
	
	if current_health <= 0.0:
		kill()
		return
	
	if damage_delay > 0.0:
		await get_tree().create_timer(damage_delay, false).timeout
	
	is_invincible = false
		
func kill() -> void:
	if is_killed:
		return
		
	kill_before.emit()
	
	StarMonkey.score += 1000
	
	is_killed = true
	
	%DamageArea3D.set_deferred("monitoring", false)
	%MeshExploder.explode(%UnitMeshCollection.get_meshes(), 2.0)
	%Explosion.explode()
	
	StarMonkey.sfx.play_enemy_explosion()
	
	if StarMonkey.player != null:
		StarMonkey.player.get_frame_ai().enemy_killed()
	
	if kill_delay > 0.0:
		await get_tree().create_timer(kill_delay, false).timeout
		
	queue_free()
	kill_after.emit()

func _set_current_weapon(value: StarMonkey.Weapons) -> void:
	current_weapon = value

func _on_body_entered(body: Node3D) -> void:
	kill()
	
