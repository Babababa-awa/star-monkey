class_name StarMonkeyInputHandler

var is_special: bool = false
var is_just_special: bool = false
var is_shoot: bool = false
var is_just_shoot: bool = false

var axis_x: float = 0.0
var axis_y: float = 0.0

var is_up: bool = false
var is_just_up: bool = false
var is_down: bool = false
var is_just_down: bool = false
var is_left: bool = false
var is_just_left: bool = false
var is_right: bool = false
var is_just_right: bool = false

var _queue: Dictionary = {}

var _input_left: float = 0.0
var _input_right: float = 0.0
var _input_up: float = 0.0
var _input_down: float = 0.0

func process() -> void:
	if _queue.has(&"fire"):
		if _queue.fire == true:
			is_shoot = true
			is_just_shoot = true
		else:
			is_shoot = false
			is_just_shoot = false
	else:
		is_just_shoot = false
		
	if _queue.has(&"bomb"):
		if _queue.bomb == true:
			is_special = true
			is_just_special = true
		else:
			is_special = false
			is_just_special = false
	else:
		is_just_special = false
		
	if _queue.has(&"left"):
		if _queue.left == true:
			is_left = true
			is_just_left = true
		else:
			is_left = false
			is_just_left = false
	else:
		is_just_left = false
	
	
	if _queue.has(&"right"):
		if _queue.right == true:
			is_right = true
			is_just_right = true
		else:
			is_right = false
			is_just_right = false
	else:
		is_just_right = false
		
	
	if _queue.has(&"up"):
		if _queue.up == true:
			is_up = true
			is_just_up = true
		else:
			is_up = false
			is_just_up = false
	else:
		is_just_up = false
		
	
	if _queue.has(&"down"):
		if _queue.down == true:
			is_down = true
			is_just_down = true
		else:
			is_down = false
			is_just_down = false
	else:
		is_just_down = false
	
	axis_x = _input_right - _input_left
	axis_y = _input_up - _input_down
	
	_queue.clear()
	
func update_input(event: InputEvent) -> void:
	if event.is_action(&"fire"):
		if event.is_pressed():
			if not is_shoot:
				_queue.set(&"fire", true)
		else:
			_queue.set(&"fire", false)

	if event.is_action(&"bomb"):
		if event.is_pressed():
			if not is_special:
				_queue.set(&"bomb", true)
		else:
			_queue.set(&"bomb", false)
			
	if event.is_action("left"):
		_input_left = event.get_action_strength("left")

		if event.is_pressed():
			if not is_left:
				_queue.set(&"left", true)
		else:
			_queue.set(&"left", false)
			
	if event.is_action("right"):
		_input_right = event.get_action_strength("right")
		
		if event.is_pressed():
			if not is_right:
				_queue.set(&"right", true)
		else:
			_queue.set(&"right", false)
	
	if event.is_action("up"):
		_input_up = event.get_action_strength("up")
		
		if event.is_pressed():
			if not is_up:
				_queue.set(&"up", true)
		else:
			_queue.set(&"up", false)
			
	if event.is_action("down"):
		_input_down = event.get_action_strength("down")
		
		if event.is_pressed():
			if not is_down:
				_queue.set(&"down", true)
		else:
			_queue.set(&"down", false)

func get_axis_x() -> float:
	return axis_x

func get_axis_y() -> float:
	return axis_y

func is_action_just_pressed(action_: StringName) -> bool:
	if action_ == &"forward" or action_ == &"shoot":
		return is_just_shoot
	elif action_ == &"back" or action_ == &"special":
		return is_just_special
	elif action_ == &"move_up":
		return is_just_up
	elif action_ == &"move_down":
		return is_just_down
	elif action_ == &"move_left":
		return is_just_left
	elif action_ == &"move_right":
		return is_just_right
			
	return false
	
func is_action_pressed(action_: StringName) -> bool:
	if action_ == &"forward" or action_ == &"shoot":
		return is_shoot
	elif action_ == &"back" or action_ == &"special":
		return is_special
	elif action_ == &"move_up":
		return is_up
	elif action_ == &"move_down":
		return is_down
	elif action_ == &"move_left":
		return is_left
	elif action_ == &"move_right":
		return is_right
		
	return false
