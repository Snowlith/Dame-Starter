extends Toggleable
class_name Carryable

@export var carry_distance: float = 2.5
@export var carry_velocity_multiplier: float = 15
@export var carry_lock_rotation: bool = true
@export var drop_distance_threshold: float = 3.5
#
#@export var throw_input_action: String = "primary"
#@export var throw_strength: float = 10

@export_flags_3d_physics var layers_while_carrying: int = 0b00000000_00000000_00000000_00000010

@onready var rigid_body: RigidBody3D = get_parent_entity().get_physics_body()

var carry_interactor: Interactor

var _default_layers: int

# TODO: combine carryable and throwable, allow for multiple input mappings

# TODO: add a method to interactor to wait for stop interaction

# TODO: sounds
# TODO: disable hotbar when carrying

func _unhandled_key_input(event):
	if event.is_echo():
		return
	if event.is_action_pressed(required_input_action):
		drop()
		get_viewport().set_input_as_handled()
		
func _ready():
	assert(is_instance_valid(rigid_body))
	_default_layers = rigid_body.collision_layer
	_toggle_process()

func _physics_process(_delta):
	var carry_position = carry_interactor.get_pos_along_ray(carry_distance)
	rigid_body.set_linear_velocity((carry_position - rigid_body.global_position) * carry_velocity_multiplier)
	# Square other side to avoid sqrt()
	if (carry_position - rigid_body.global_position).length_squared() > pow(drop_distance_threshold, 2):
		drop()

func drop():
	if carry_interactor:
		super.interact(carry_interactor)
		carry_interactor.enable()
	carry_interactor = null
	_toggle_process()

func _toggle_process():
	rigid_body.set_lock_rotation_enabled(enabled)
	set_process_unhandled_key_input(enabled)
	set_physics_process(enabled)
	
	if enabled:
		rigid_body.collision_layer = layers_while_carrying
	else:
		rigid_body.collision_layer = _default_layers

func interact(interactor: Interactor):
	print("STARTING CARRY")
	super(interactor)
	carry_interactor = interactor
	carry_interactor.disable()
	_toggle_process()
