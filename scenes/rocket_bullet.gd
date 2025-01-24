extends ItemBehavior
class_name ProjectileBehavior

@export var damage: Curve
@export var knockback: Curve
@export var speed: float = 50

@onready var rigid_body: RigidBody3D = $"."
@onready var shape_cast = $ShapeCast3D
@onready var explosion_radius = shape_cast.shape.radius


var _previous_position: Vector3
var _current_position: Vector3

func _ready():
	_reset_shitpos.call_deferred()
	shape_cast.enabled = false

func shoot(direction):
	rigid_body.apply_central_impulse(direction * speed)

func _reset_shitpos():
	_previous_position = global_position
	_current_position = global_position
	
func _physics_process(delta):
	_previous_position = _current_position
	_current_position = global_position
	
	if not rigid_body.get_colliding_bodies().is_empty():
		rigid_body.freeze = true
		rigid_body.rotation = -Vector3.FORWARD
		shape_cast.force_shapecast_update()
		#DebugDraw3D.draw_sphere(shape_cast.global_position, explosion_radius, Color.YELLOW, 1)
		#DebugDraw3D.draw_position(Transform3D(Basis(), shape_cast.global_position), Color.GREEN_YELLOW, 1)
		for i in shape_cast.get_collision_count():
			var collider = shape_cast.get_collider(i)
			var entity = collider as Entity
			if not entity:
				continue
			var collision_point = shape_cast.get_collision_point(i)
			var displacement = collision_point - rigid_body.global_position
			#DebugDraw3D.draw_arrow(rigid_body.global_position, collision_point, Color.GREEN, 0.1, true, 10)
			var distance = displacement.length()
			var direction = displacement.normalized()
			#DebugDraw3D.draw_arrow(collision_point, direction, Color.GREEN, 0.1, true, 10)
			var normalized_falloff = distance / explosion_radius
			var health: Health = entity.get_component(Health)
			if health:
				var damage_amount = damage.sample(normalized_falloff)
				health.decrease(damage_amount)
			var explosion_state = entity.get_component(ExplosionState)
			if explosion_state:
				var explosion_amount = knockback.sample(normalized_falloff)
				explosion_state.receive_impulse(direction * explosion_amount)
				DebugDraw3D.draw_arrow(entity.global_position, entity.global_position + explosion_amount * direction / 50, Color.RED, 0.1, true, 10)
			elif entity.get_physics_body() is RigidBody3D:
				var rigid_body: RigidBody3D = entity.get_physics_body()
				var explosion_amount = knockback.sample(normalized_falloff)
				rigid_body.apply_central_impulse(direction * explosion_amount)
		queue_free()
	else:
		DebugDraw3D.draw_arrow(_previous_position, _current_position, Color.BLUE, 0.1, true, 2)
