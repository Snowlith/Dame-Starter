extends State
class_name ExplosionState

@export var explosion_mass: float = 10

var is_in_explosion: bool = false

var _new_velocity: Vector3

func update_status(delta: float):
	if is_in_explosion:
		return Status.ACTIVE_FORCED
	return Status.INACTIVE

func receive_impulse(impulse: Vector3):
	var current_momentum = explosion_mass * _cb.velocity
	_new_velocity = (impulse + current_momentum) / explosion_mass
	is_in_explosion = true

func handle(delta: float):
	_cb.velocity = _new_velocity
	is_in_explosion = false
	
	_cb.move_and_slide()
