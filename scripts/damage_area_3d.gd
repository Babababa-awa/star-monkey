extends Area3D
class_name StarMonkeyDamageArea3D

@export var damage: int = 25
@export var independent: bool = false

@export var grow: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	set_deferred("monitorable", false)
	
	if not is_zero_approx(grow):
		var shape := $CollisionShape3D.shape as ConcavePolygonShape3D
		if shape:
			var grown_data := grow_concave_shape(shape.data, grow)
			var new_shape := ConcavePolygonShape3D.new()
			new_shape.data = grown_data
			
			$CollisionShape3D.shape = new_shape
	
func _on_body_entered(body) -> void:
	if body == get_parent() or is_queued_for_deletion():
		return

	if body is StarMonkeyPlayer:
		body.take_damage(damage, independent, self)
	elif body is StarMonkeyEnemy:
		body.take_damage(damage, independent, self)
	
func grow_concave_shape(
	data: PackedVector3Array, 
	distance: float
) -> PackedVector3Array:
	var new_data := PackedVector3Array()
	
	for i in range(0, data.size(), 3):
		var v0: Vector3 = data[i]
		var v1: Vector3 = data[i + 1]
		var v2: Vector3 = data[i + 2]
		
		var normal: Vector3 = -(v1 - v0).cross(v2 - v0).normalized()
		
		new_data.append(v0 + normal * distance)
		new_data.append(v1 + normal * distance)
		new_data.append(v2 + normal * distance)
	
	return new_data
