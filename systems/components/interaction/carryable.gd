extends Interactable
class_name Carryable

@export var carry_distance: float = 2.5
@export var carry_velocity_multiplier: float = 15
@export var drop_distance_threshold: float = 3.5
@export var throw_strength: float = 10

var parent: RigidBody3D

var is_being_carried = false
var carry_interactor = null

func _ready():
	assert(get_parent() is RigidBody3D)
	parent = get_parent() as RigidBody3D

func _physics_process(_delta):
	if is_being_carried:
		var carry_position = carry_interactor.get_pos_along_ray(carry_distance)
		parent.set_linear_velocity((carry_position - parent.global_position) * carry_velocity_multiplier)
		# replace sqrt with square
		if (carry_position - parent.global_position).length() > drop_distance_threshold:
			carry_interactor.end_interaction()

func throw():
	var impulse = carry_interactor.get_pos_along_ray(carry_distance + throw_strength) - parent.global_position
	parent.apply_central_impulse(impulse)

func interact(interactor: Interactor = null):
	is_being_carried = interactor != null
	if not is_being_carried:
		throw()
	carry_interactor = interactor
