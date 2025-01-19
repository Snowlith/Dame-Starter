extends ItemBehavior
class_name ProjectileBehavior

@export var damage: int = 100
@export var speed: float = 50
@export var knockback: float = 100
@export var explosion_curve: Curve

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
		shape_cast.force_shapecast_update()
		for i in shape_cast.get_collision_count():
			var collider = shape_cast.get_collider(i)
			var collision_point = shape_cast.get_collision_point(i)
			var entity = collider as Entity
			if not entity:
				continue
			var explosion_state = entity.get_component(ExplosionState)
			if not explosion_state:
				continue
			var displacement = collision_point - rigid_body.global_position
			#DebugDraw3D.draw_arrow(rigid_body.global_position, collision_point, Color.GREEN, 0.1, true, 10)
			var distance = displacement.length()
			var direction = displacement.normalized()
			#DebugDraw3D.draw_arrow(collision_point, direction, Color.GREEN, 0.1, true, 10)
			var explosion_amount = explosion_curve.sample(distance / explosion_radius)
			explosion_state.receive_impulse(direction * explosion_amount * knockback)
			DebugDraw3D.draw_arrow(entity.global_position, entity.global_position + explosion_amount * direction * knockback / 50, Color.RED, 0.1, true, 10)
		queue_free()
	else:
		DebugDraw3D.draw_arrow(_previous_position, _current_position, Color.BLUE, 0.1, true, 2)
