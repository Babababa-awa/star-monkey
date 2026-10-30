extends Area3D
class_name StarMonkeyAttackArea3D

@export_group("Damage")
@export var damage: int = 25
@export var independent: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	monitorable = false
	
func _on_body_entered(body) -> void:
	if body == get_parent():
		return
		
	if body is StarMonkeyPlayer:
		body.take_damage(damage, independent, self)
	elif body is StarMonkeyEnemy:
		body.take_damage(damage, independent, self)
	
