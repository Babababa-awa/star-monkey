extends Node3D

@export var max_spire_health: int = 100
@export var max_base_health: int = 100

@export var spire_rotate_speed: float = 1.0
@export var spire_fall_speed: float = 9.0

# /materials/object/forgotten_city/building_damage_overlay.tres
const DAMAGE_OVERLAY = preload("uid://djvud4dohyr50")

var current_spire_health: int = 100
var current_base_health: int = 100

var is_spire_destroyed: bool = false
var is_spire_destroyed_completely: bool = false
var is_base_destroyed: bool = false

var spire_fall_direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	%DamageArea3DSpire.body_entered.connect(_on_spire_body_entered)
	%DamageArea3DSpire.area_entered.connect(_on_spire_area_entered)
	
	%DamageArea3DBase.body_entered.connect(_on_base_body_entered)
	%DamageArea3DBase.area_entered.connect(_on_base_area_entered)

func reset() -> void:
	is_spire_destroyed = false
	is_spire_destroyed_completely = false
	is_base_destroyed = false
	
	current_spire_health = max_spire_health
	current_base_health = max_base_health
	
	%MeshExploderSpire.reset()
	%MeshExploderBase.reset()
	
	%DamageArea3DSpire.monitoring = true
	%DamageArea3DBase.monitoring = true
	
	%MeshCollectionBase.clear_material_overlay()
	%MeshCollectionBase.show_meshes()
	
	%MeshCollectionSpire.clear_material_overlay()
	%MeshCollectionSpire.show_meshes()
	
func _physics_process(delta: float) -> void:
	if not is_spire_destroyed or is_spire_destroyed_completely:
		return
	
	if (%Spire.rotation_degrees.x > -90.0 and 
		%Spire.rotation_degrees.x < 90.0 and
		%Spire.rotation_degrees.z > -90.0 and 
		%Spire.rotation_degrees.z < 90.0 
	):
		%Spire.rotate(spire_fall_direction, spire_rotate_speed * delta)
		
	if %Spire.position.y > 0.0:
		%Spire.global_position.y -= (spire_fall_speed * delta)
	else:
		is_spire_destroyed_completely = true
		%MeshExploderSpire.explode(%MeshCollectionSpire.get_meshes(), 1.0)
		StarMonkey.sfx.play_collapse()
	
func destroy_spire() -> void:
	if is_spire_destroyed:
		return
 
	is_spire_destroyed = true
	%DamageArea3DSpire.set_deferred("monitoring", false)
	
	var angle: float = randf() * TAU 
	spire_fall_direction = Vector3(cos(angle), 0.0, sin(angle))
	
	StarMonkey.score += 50

func destroy_base() -> void:
	if is_base_destroyed:
		return
 
	is_base_destroyed = true
	%DamageArea3DBase.set_deferred("monitoring", false)
	
	%MeshExploderBase.explode(%MeshCollectionBase.get_meshes(), 1.0)

	StarMonkey.score += 50
	
	StarMonkey.sfx.play_collapse()
	
	destroy_spire()

func _on_base_body_entered(body: Node3D) -> void:
	if (body is StarMonkeyPlayer or 
		body is StarMonkeyEnemy
	):
		destroy_base()

func _on_base_area_entered(area: Area3D) -> void:
	if area.is_queued_for_deletion():
		return
		
	if area is StarMonkeyProjectile:
		if current_base_health == max_base_health:
			%MeshCollectionBase.set_material_overlay(DAMAGE_OVERLAY)
		
		current_base_health -= area.damage
		
		if current_base_health <= 0:
			destroy_base()
		
		if not is_zero_approx(area.max_life_span):
			area.set_deferred("monitorable", false)
			area.set_deferred("monitoring", false)
			area.queue_free()
			
func _on_spire_body_entered(body: Node3D) -> void:
	if body.is_queued_for_deletion():
		return
		
	if (body is StarMonkeyPlayer or 
		body is StarMonkeyEnemy
	):
		destroy_spire()

func _on_spire_area_entered(area: Area3D) -> void:
	if area.is_queued_for_deletion():
		return
		
	if area is StarMonkeyProjectile:
		if current_base_health == max_base_health:
			%MeshCollectionSpire.set_material_overlay(DAMAGE_OVERLAY)
		
		current_base_health -= area.damage
		
		if current_base_health <= 0:
			destroy_spire()
		
		if not is_zero_approx(area.max_life_span):
			area.set_deferred("monitorable", false)
			area.set_deferred("monitoring", false)
			area.queue_free()
