extends Node3D

@export var start_radius: float = 0.25
@export var end_radius: float = 5.0
@export var start_color: Color = Color(0.0, 0.0, 0.9, 0.5)
@export var end_color: Color = Color(0.9, 0.87, 0.0, 0.0)
@export var explosion_duration: float = 1.0

var is_exploding: bool = false
var current_delta: float = 0.0

signal exploded

func explode() -> void:
	if is_exploding:
		return
		
	is_exploding = true
	current_delta = 0.0
	
	%MeshInstance3D.mesh.radius = start_radius
	%MeshInstance3D.mesh.height = start_radius * 2.0
	
	var material: StandardMaterial3D = %MeshInstance3D.get_active_material(0) as StandardMaterial3D
	material.albedo_color = start_color
	material.emission = start_color
	%MeshInstance3D.visible = true

func _process(delta: float) -> void:
	if not is_exploding:
		return
		
	current_delta += delta
	
	var weight: float = clampf(current_delta / explosion_duration, 0.0, 1.0)
	var radius: float = lerpf(start_radius, end_radius, weight)
	var color: Color = start_color.lerp(end_color, weight)

	%MeshInstance3D.mesh.radius = radius
	%MeshInstance3D.mesh.height = radius * 2.0

	var material: StandardMaterial3D = %MeshInstance3D.get_active_material(0) as StandardMaterial3D
	material.albedo_color = color
	material.emission = color
	
	if current_delta > explosion_duration:
		is_exploding = false
		%MeshInstance3D.visible = false
		exploded.emit()
	
