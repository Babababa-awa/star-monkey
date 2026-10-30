extends Path3D

@export var radius: float = 6.0
@export var counter_clockwise: bool = false

func _ready() -> void:
	if counter_clockwise:
		curve.set_point_position(0, Vector3(0.0, radius, 0.0))
		curve.set_point_in(0, Vector3(radius / 2.0, 0.0, 0.0))
		curve.set_point_out(0, Vector3(-radius / 2.0, 0.0, 0.0))
		
		curve.set_point_position(1, Vector3(-radius, 0.0, 0.0))
		curve.set_point_in(1, Vector3(0.0, radius / 2.0, 0.0))
		curve.set_point_out(1, Vector3(0.0, -radius / 2.0, 0.0))
		
		curve.set_point_position(2, Vector3(0.0, -radius, 0.0))
		curve.set_point_in(2, Vector3(-radius / 2.0, 0.0, 0.0))
		curve.set_point_out(2, Vector3(radius / 2.0, 0.0, 0.0))
		
		curve.set_point_position(3, Vector3(radius, 0.0, 0.0))
		curve.set_point_in(3, Vector3(0.0, -radius / 2.0, 0.0))
		curve.set_point_out(3, Vector3(0.0, radius / 2.0, 0.0))
	else:
		curve.set_point_position(0, Vector3(0.0, radius, 0.0))
		curve.set_point_in(0, Vector3(-radius / 2.0, 0.0, 0.0))
		curve.set_point_out(0, Vector3(radius / 2.0, 0.0, 0.0))
		
		curve.set_point_position(1, Vector3(radius, 0.0, 0.0))
		curve.set_point_in(1, Vector3(0.0, radius / 2.0, 0.0))
		curve.set_point_out(1, Vector3(0.0, -radius / 2.0, 0.0))
		
		curve.set_point_position(2, Vector3(0.0, -radius, 0.0))
		curve.set_point_in(2, Vector3(radius / 2.0, 0.0, 0.0))
		curve.set_point_out(2, Vector3(-radius / 2.0, 0.0, 0.0))
		
		curve.set_point_position(3, Vector3(-radius, 0.0, 0.0))
		curve.set_point_in(3, Vector3(0.0, -radius / 2.0, 0.0))
		curve.set_point_out(3, Vector3(0.0, radius / 2.0, 0.0))
