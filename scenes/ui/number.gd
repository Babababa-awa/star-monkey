extends Node3D

# /scenes/ui/digit.tscn
const DIGIT = preload("uid://b8ud1s0gw21tc")

@export var digit_count: int = 1
@export var digit_width: float = 0.28
@export var start_value: int = 0
@export var wireframe: StarMonkeyWireframe = null

var digits: Array[Node3D] = []
var current_value: int = 0

func _ready() -> void:
	var offset: float = digit_width * digit_count / 2.0
	
	for i: int in digit_count:
		var digit = DIGIT.instantiate()
		digits.append(digit)
		
		if wireframe != null:
			digit.wireframe = wireframe
		digit.position.x = -offset + (i * digit_width) + (digit_width / 2.0)
		add_child(digit)
		#if wireframe != null:
			#for node: Node3D in digit.get_children():
				#if node is MeshInstance3D:
					#wireframe.add_wireframe(node)
		
	set_value(start_value)
		
func set_value(value: int) -> bool:
	value = maxi(0, value)
	
	if current_value == value:
		return false
		
	current_value = value
	
	var chars = str(value).split()
	
	if chars.size() > digit_count:
		for i: int in digit_count:
			digits[i].set_digit(int(chars[i]))
		return true
		
	var offset: int = digit_count - chars.size()
		
	for i: int in digit_count:
		if i < offset:
			digits[i].set_digit(0)
		else:
			digits[i].set_digit(int(chars[i - offset]))
	
	return true

func add_value(value: int) -> void:
	set_value(current_value + value)
