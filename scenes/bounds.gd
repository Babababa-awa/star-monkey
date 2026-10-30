extends StaticBody3D
class_name StarMonkeyBounds

@export var bounds: Vector3 = Vector3(15.0, 10.0, 15.0)
@export var offset: Vector3 = Vector3(0, 0, 5.0)

func start() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	visible = true
	
func stop() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Left
	%Left.position.x = -bounds.x
	%Left.mesh.size.x = bounds.y * 2
	%Left.mesh.size.y = bounds.z
	
	%Area3DLeft.position.x = -bounds.x
	%CollisionShape3DLeft.position.x = -bounds.x - 0.5
	%CollisionShape3DLeft.shape.size.y = bounds.y * 2
	%CollisionShape3DLeftArea.shape.size.y = bounds.y * 2
	
	# Right
	%Right.position.x = bounds.x
	%Right.mesh.size.x = bounds.y * 2
	%Right.mesh.size.y = bounds.z
	
	%Area3DRight.position.x = bounds.x
	%CollisionShape3DRight.position.x = bounds.x + 0.5
	%CollisionShape3DRight.shape.size.y = bounds.y * 2
	%CollisionShape3DRightArea.shape.size.y = bounds.y * 2
	
	# Top
	%Top.position.y = bounds.y
	%Top.mesh.size.x = bounds.x * 2
	%Top.mesh.size.y = bounds.z
	
	%Area3DTop.position.y = bounds.y
	%CollisionShape3DTop.position.y = bounds.y + 0.5
	%CollisionShape3DTop.shape.size.x = bounds.x * 2
	%CollisionShape3DTopArea.shape.size.x = bounds.x * 2
	
	# Bottom
	%Bottom.position.y = -bounds.y
	%Bottom.mesh.size.x = bounds.x * 2
	%Bottom.mesh.size.y = bounds.z
	
	%Area3DBottom.position.y = -bounds.y
	%CollisionShape3DBottom.position.y = -bounds.y - 0.5
	%CollisionShape3DBottom.shape.size.x = bounds.x * 2
	%CollisionShape3DBottomArea.shape.size.x = bounds.x * 2

func _physics_process(delta: float) -> void:
	if StarMonkey.player != null:
		var player_position: Vector3 = StarMonkey.player.global_position
		global_position = Vector3(0.0, 0.0, player_position.z)

func _on_area_3d_left_body_entered(body: Node3D) -> void:
	if body is StarMonkeyPlayer:
		turn_on(%Left)
		turn_on(%Right)
		turn_on(%Top)
		turn_on(%Bottom)

func _on_area_3d_left_body_exited(body: Node3D) -> void:
	if body is StarMonkeyPlayer:
		turn_off(%Left)
		turn_off(%Right)
		turn_off(%Top)
		turn_off(%Bottom)

func _on_area_3d_right_body_entered(body: Node3D) -> void:
	if body is StarMonkeyPlayer:
		turn_on(%Left)
		turn_on(%Right)
		turn_on(%Top)
		turn_on(%Bottom)

func _on_area_3d_right_body_exited(body: Node3D) -> void:
	if body is StarMonkeyPlayer:
		turn_off(%Left)
		turn_off(%Right)
		turn_off(%Top)
		turn_off(%Bottom)

func _on_area_3d_top_body_entered(body: Node3D) -> void:
	if body is StarMonkeyPlayer:
		turn_on(%Left)
		turn_on(%Right)
		turn_on(%Top)
		turn_on(%Bottom)

func _on_area_3d_top_body_exited(body: Node3D) -> void:
	if body is StarMonkeyPlayer:
		turn_off(%Left)
		turn_off(%Right)
		turn_off(%Top)
		turn_off(%Bottom)

func _on_area_3d_bottom_body_entered(body: Node3D) -> void:
	if body is StarMonkeyPlayer:
		turn_on(%Left)
		turn_on(%Right)
		turn_on(%Top)
		turn_on(%Bottom)

func _on_area_3d_bottom_body_exited(body: Node3D) -> void:
	if body is StarMonkeyPlayer:
		turn_off(%Left)
		turn_off(%Right)
		turn_off(%Top)
		turn_off(%Bottom)

func turn_on(side: MeshInstance3D) -> void:
	var material: ShaderMaterial = side.get_active_material(0) as ShaderMaterial
	material.set_shader_parameter("shield_active", 1.0)

func turn_off(side: MeshInstance3D) -> void:
	var material: ShaderMaterial = side.get_active_material(0) as ShaderMaterial
	material.set_shader_parameter("shield_active", 0.0)
