extends Area3D
class_name StarMonkeyPickup

@export_group("Pickup")
@export var pickup: StarMonkey.Pickups = StarMonkey.Pickups.NONE

@export_group("Rotation")
@export var base_speed: float = 30.0
@export var drift_speed: float = 2.0
@export var drift_amount: float = 15.0
@export var main_axis: Vector3 = Vector3.UP

var _time: float = 0.0

# Extra test in case rotation causes double trigger before removed
var is_used: bool = false 

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if StarMonkey.player == null:
		return
	
	if StarMonkey.player.global_position.z < global_position.z - 10:
		queue_free()

func _physics_process(delta: float) -> void:
	if (StarMonkey.player != null and
		StarMonkey.player.global_position.z > global_position.z + 64
	):
		return
	
	_time += delta
	
	var main_rotation: float = base_speed * delta
	
	var drift_x: float = sin(_time * drift_speed * 0.7) * drift_amount * delta
	var drift_z: float = cos(_time * drift_speed * 0.5) * drift_amount * delta
	
	rotate(main_axis.normalized(), deg_to_rad(main_rotation))
	rotate_object_local(Vector3.RIGHT, deg_to_rad(drift_x))
	rotate_object_local(Vector3.FORWARD, deg_to_rad(drift_z))

func _on_body_entered(body: Node3D) -> void:
	if not body is StarMonkeyPlayer and not is_used:
		return

	if pickup == StarMonkey.Pickups.SHIELD:
		body.add_shield(25)
	elif pickup == StarMonkey.Pickups.SPECIAL:
		body.add_special()
	elif pickup == StarMonkey.Pickups.WEAPON_UPGRADE:
		body.upgrade_weapon()
	
	is_used = true
	queue_free()
