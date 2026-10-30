extends Node3D
class_name StarMonkeyBuildingSide

@export var max_health: int = 150

# /materials/object/forgotten_city/building_damage_overlay.tres
const BUILDING_DAMAGE_OVERLAY = preload("uid://djvud4dohyr50")

var current_health: int = 150
var is_destroyed: bool = false

signal damaged(node: Node3D)
signal destroyed(node: Node3D)

func _ready() -> void:
	%DamageArea3D.body_entered.connect(_on_body_entered)
	%DamageArea3D.area_entered.connect(_on_area_entered)

func reset() -> void:
	is_destroyed = false
	current_health = max_health
	
	%MeshExploder.reset()
	%DamageArea3D.monitoring = true
	
	%MeshCollection.clear_material_overlay()
	%MeshCollection.show_meshes()
	
func destroy(silent: bool = false) -> void:
	if is_destroyed:
		return
 
	is_destroyed = true
	%DamageArea3D.set_deferred("monitoring", false)

	%MeshExploder.explode(%MeshCollection.get_meshes(), 1.0)
	
	StarMonkey.score += 25
	
	if not silent:
		StarMonkey.sfx.play_destroy()
		destroyed.emit(self)
	
func _on_body_entered(body: Node3D) -> void:
	if body.is_queued_for_deletion():
		return
		
	if (body is StarMonkeyPlayer or 
		body is StarMonkeyEnemy
	):
		destroy()

func _on_area_entered(area: Area3D) -> void:
	if area.is_queued_for_deletion():
		return
		
	if area is StarMonkeyProjectile:
		if current_health == max_health:
			%MeshCollection.set_material_overlay(BUILDING_DAMAGE_OVERLAY)
		
		current_health -= area.damage
		
		if current_health <= 0:
			destroy()
		else:
			damaged.emit()
		
		# If there is no max life, then removal is handled manually
		if not is_zero_approx(area.max_life_span):
			area.set_deferred("monitorable", false)
			area.set_deferred("monitoring", false)
			area.queue_free()
