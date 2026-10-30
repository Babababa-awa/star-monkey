extends Resource
class_name StarMonkeyPlayerState

@export var max_health: int = 100
@export var current_health: int = 100
@export var max_shield: int = 100
@export var current_shield: int = 100
@export var max_special_count: int = 5
@export var current_special_count: int = 2

@export var current_weapon: StarMonkey.Weapons = StarMonkey.Weapons.LASER_CANNON
