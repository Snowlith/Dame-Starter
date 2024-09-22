extends Component
class_name Carryable

@export var carry_distance: float = 2.5
@export var carry_velocity_multiplier: float = 15
@export var carry_lock_rotation: bool = true
@export var drop_distance_threshold: float = 3.5
@export var throw_strength: float = 10

var parent: RigidBody3D

var is_being_carried = false
var carry_interactor = null

# TODO: sounds
# TODO: disable carry if holding item?

func _unhandled_input(event):
	if event.is_action_pressed("primary attack"):
		throw()
		carry_interactor.end_interaction()

func _ready():
	parent = get_parent_entity()
	assert(parent is RigidBody3D)
	set_process_unhandled_input(false)

func _physics_process(_delta):
	if is_being_carried:
		var carry_position = carry_interactor.get_pos_along_ray(carry_distance)
		parent.set_linear_velocity((carry_position - parent.global_position) * carry_velocity_multiplier)
		# Square other side to avoid sqrt()
		if (carry_position - parent.global_position).length_squared() > pow(drop_distance_threshold, 2):
			carry_interactor.end_interaction()

func throw():
	var impulse = carry_interactor.get_pos_along_ray(carry_distance + throw_strength) - parent.global_position
	parent.apply_central_impulse(impulse)

func interact(interactor: Interactor = null):
	is_being_carried = interactor != null
	parent.set_lock_rotation_enabled(carry_lock_rotation and is_being_carried)
	set_process_unhandled_input(is_being_carried)
	#if not is_being_carried:
		#throw()
	carry_interactor = interactor
