extends Interactable
class_name Carryable

#@export var rigid_body: RigidBody3D
@export var carry_distance: float = 2.5
@export var carry_velocity_multiplier: float = 15
@export var carry_lock_rotation: bool = true
@export var drop_distance_threshold: float = 3.5
@export var throw_strength: float = 10

@export_flags_3d_physics var layers_while_carrying: int = 0b00000000_00000000_00000000_00000010

@onready var _rb: RigidBody3D = get_parent_entity() as PhysicsBody3D

var _interactor = null

var _default_layers: int

# TODO: sounds
# TODO: disable carry if holding item?
# TODO: carry from center of collision aabb

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		drop()
	if event.is_action_pressed("primary_attack"):
		throw()

func _ready():
	_default_layers = _rb.collision_layer
	drop()

func _physics_process(_delta):
	var carry_position = _interactor.get_pos_along_ray(carry_distance)
	_rb.set_linear_velocity((carry_position - _rb.global_position) * carry_velocity_multiplier)
	# Square other side to avoid sqrt()
	if (carry_position - _rb.global_position).length_squared() > pow(drop_distance_threshold, 2):
		drop()

func drop():
	if _interactor:
		_interactor.enable()
	_interactor = null
	_toggle_mode()

func _toggle_mode():
	var mode = is_instance_valid(_interactor)
	_rb.set_lock_rotation_enabled(mode)
	set_process_unhandled_input(mode)
	set_physics_process(mode)
	_rb.collision_layer = layers_while_carrying if mode else _default_layers

func throw():
	var impulse = _interactor.get_pos_along_ray(carry_distance + throw_strength) - _rb.global_position
	_rb.apply_central_impulse(impulse)
	drop()

func interact(interactor: Interactor):
	_interactor = interactor
	_interactor.disable()
	_toggle_mode()
