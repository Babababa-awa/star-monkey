extends StarMonkeyProjectile

@export var explode_delay: float = 0.75
@export var rotate_speed: float = 1.0

var is_exploded: bool = false
var current_delay_delta: float = 0.0
var current_explosion_delta: float = 0.0

func _ready():
	super._ready()
	%Explosion.exploded.connect(_on_exploded)
	monitorable = false
	monitoring = false

func _physics_process(delta):
	rotation.x = wrapf(rotation.x + rotate_speed * delta, 0.0, TAU)
	
	if not is_exploded:
		super._physics_process(delta)
		
		current_delay_delta += delta
		
		if current_delay_delta >= explode_delay:
			explode()
	else:
		current_explosion_delta += delta
		
		var weight: float = clampf(current_explosion_delta / %Explosion.explosion_duration, 0.0, 1.0)

		var radius: float = lerpf(
			%Explosion.start_radius, 
			%Explosion.end_radius, 
			weight
		)
		%CollisionShape3D.shape.radius = radius
		
func explode() -> void:
	is_exploded = true
	var meshes: Array[MeshInstance3D] = []
	meshes.append(%Bomb)
	%MeshExploder.explode(meshes, 5.0)
	%Explosion.explode()
	monitorable = true
	monitoring = true
	
	%AudioStreamPlayer.pitch_scale = randf_range(0.9, 1.0)
	%AudioStreamPlayer.play()

func _on_exploded() -> void:
	queue_free()
