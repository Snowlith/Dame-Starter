extends Interactable
class_name Carryable

@export var rigid_body: RigidBody3D
@export var carry_distance: float = 2.5
@export var carry_velocity_multiplier: float = 15
@export var carry_lock_rotation: bool = true
@export var drop_distance_threshold: float = 3.5
@export var throw_strength: float = 10

var _is_being_carried = false
var carry_interactor = null

# TODO: sounds
# TODO: disable carry if holding item?

func _unhandled_input(event):
	if event.is_action_pressed("primary attack"):
		throw()
		carry_interactor.end_interaction(true)

func _ready():
	set_process_unhandled_input(false)

func _physics_process(_delta):
	if _is_being_carried:
		var carry_position = carry_interactor.get_pos_along_ray(carry_distance)
		rigid_body.set_linear_velocity((carry_position - rigid_body.global_position) * carry_velocity_multiplier)
		# Square other side to avoid sqrt()
		if (carry_position - rigid_body.global_position).length_squared() > pow(drop_distance_threshold, 2):
			carry_interactor.end_interaction(true)

func throw():
	var impulse = carry_interactor.get_pos_along_ray(carry_distance + throw_strength) - rigid_body.global_position
	rigid_body.apply_central_impulse(impulse)

func interact(interactor: Interactor):
	_is_being_carried = not _is_being_carried
	print(_is_being_carried)
	rigid_body.set_lock_rotation_enabled(carry_lock_rotation and _is_being_carried)
	set_process_unhandled_input(_is_being_carried)
	#if not is_being_carried:
		#throw()
	if _is_being_carried:
		carry_interactor = interactor
	else:
		carry_interactor = null
	set_physics_process(_is_being_carried)
