extends Interactable
class_name Carryable

@export var rigid_body: RigidBody3D
@export var carry_distance: float = 2.5
@export var carry_velocity_multiplier: float = 15
@export var carry_lock_rotation: bool = true
@export var drop_distance_threshold: float = 3.5
@export var throw_strength: float = 10

var carry_interactor = null

# TODO: sounds
# TODO: disable carry if holding item?

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		drop()
	if event.is_action_pressed("primary attack"):
		throw()

func _ready():
	drop()

func _physics_process(_delta):
	var carry_position = carry_interactor.get_pos_along_ray(carry_distance)
	rigid_body.set_linear_velocity((carry_position - rigid_body.global_position) * carry_velocity_multiplier)
	# Square other side to avoid sqrt()
	if (carry_position - rigid_body.global_position).length_squared() > pow(drop_distance_threshold, 2):
		carry_interactor.end_interaction(true)

func drop():
	if carry_interactor:
		carry_interactor.enable()
	carry_interactor = null
	set_process_unhandled_input(false)
	set_physics_process(false)

func throw():
	var impulse = carry_interactor.get_pos_along_ray(carry_distance + throw_strength) - rigid_body.global_position
	rigid_body.apply_central_impulse(impulse)
	drop()

func interact(interactor: Interactor):
	carry_interactor = interactor
	carry_interactor.disable()
	rigid_body.set_lock_rotation_enabled(carry_lock_rotation)
	set_process_unhandled_input(true)
	set_physics_process(true)
