extends Area3D
class_name StarMonkeyProjectile

@export var max_life_span: float = 5.0

@export_group("Movement")
@export var speed: float = 30.0

@export_group("Damage")
@export var damage: int = 25
@export var independent: bool = false

var launcher: Node3D = null
var direction: Vector3 = Vector3.ZERO
var _hit_targets: Array[Node3D] = []

func _ready():
	body_entered.connect(_on_body_entered)
	
	# Automatically clean up
	if not is_zero_approx(max_life_span):
		await get_tree().create_timer(max_life_span, false).timeout
		queue_free()
	
func launch(launcher_: Node3D, direction_: Vector3) -> void:
	launcher = launcher_
	direction = direction_
	
	# Fake one physics tick of movement if interpolation on
	if is_physics_interpolated_and_enabled():
		var delta = 1.0 / Engine.physics_ticks_per_second
		position += direction * speed * delta
	
func _physics_process(delta) -> void:
	if direction == Vector3.ZERO:
		return
	
	position += direction * speed * delta
	
	# TODO: Check if ground or grid level
	if global_position.y < -12.0 and not is_queued_for_deletion():
		queue_free()
	
func _on_body_entered(body: Node3D):
	if body == launcher:
		return
	
	if _hit_targets.has(body):
		return
	
	if body is StarMonkeyPlayer:
		body.take_damage(damage, independent)
	elif body is StarMonkeyEnemy:
		body.take_damage(damage, independent)
	
	if not is_zero_approx(max_life_span):
		queue_free()
	else:
		_hit_targets.append(body)
