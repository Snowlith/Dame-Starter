extends ItemBehavior
class_name ProjectileBehavior

@export var damage: int = 100
@export var speed: float = 50

@onready var rigid_body: RigidBody3D = $"."
@onready var ray_cast: RayCast3D = $RayCast3D

var _previous_position: Vector3
var _current_position: Vector3

func _ready():
	_reset_shitpos.call_deferred()

func shoot(direction):
	rigid_body.apply_central_impulse(direction * speed)

func _reset_shitpos():
	_previous_position = global_position
	_current_position = global_position
	
func _physics_process(delta):
	_previous_position = _current_position
	_current_position = global_position
	
	#ray_cast.global_position = _previous_position
	#ray_cast.target_position = _current_position - _previous_position
	#
	#ray_cast.force_raycast_update()
	DebugDraw3D.draw_arrow(_previous_position, _current_position, Color.RED, 0.1, true, 2)
	#if ray_cast.is_colliding():
		#print("COLLIDING")
		#print(ray_cast.get_collider())
		#var point = ray_cast.get_collision_point()
		#DebugDraw3D.draw_position(Transform3D(Basis(), point), Color.GREEN, 1)
		#rigid_body.freeze = true
		#DebugDraw3D.draw_arrow(_previous_position, _current_position, Color.RED, 0.5, true, 2)
