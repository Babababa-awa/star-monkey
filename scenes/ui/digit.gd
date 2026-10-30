extends Node3D

@export var wireframe: StarMonkeyWireframe = null

func _ready() -> void:
	_init_wireframes()
	
func _init_wireframes() -> void:
	await get_tree().process_frame 
	
	if wireframe != null:
		for child: Node3D in get_children():
			wireframe.add_wireframe(child, self)

func set_digit(digit: int) -> void:
	var digit_node = get_node_or_null("digit_" + str(digit))
	
	if digit_node != null:
		for child: Node3D in get_children():
			if child != digit_node:
				child.visible = false
				
		digit_node.visible = true

		if wireframe != null:
			var wireframe_node: Node3D = get_node_or_null("Wireframe_digit_" + str(digit))
			if wireframe_node != null:
				wireframe_node.visible = true
