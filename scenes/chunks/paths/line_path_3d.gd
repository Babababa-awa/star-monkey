@tool
extends Path3D

@export var distance: float = 12.0:
	set(value):
		distance = value
		_update_curve()
		
@export_enum("Left", "Right", "Up", "Down", "Forward", "Back") var direction: int = 0:
	set(value):
		direction = value
		_update_curve()

func _ready() -> void:
	_update_curve()
	
func _update_curve() -> void:
	match direction:
		0: # Left
			curve.set_point_position(1, Vector3(-distance, 0.0, 0.0))
		1: # Right
			curve.set_point_position(1, Vector3(distance, 0.0, 0.0))
		2: # Up
			curve.set_point_position(1, Vector3(0.0, distance, 0.0))
		3: # Down
			curve.set_point_position(1, Vector3(0.0, -distance, 0.0))
		4: # Forward
			curve.set_point_position(1, Vector3(0.0, 0.0, -distance))
		5: # Back
			curve.set_point_position(1, Vector3(0.0, 0.0, distance))
