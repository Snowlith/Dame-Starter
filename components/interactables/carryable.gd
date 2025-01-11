extends Toggleable
class_name Carryable

@export var carry_distance: float = 2.5
@export var carry_velocity_multiplier: float = 15
@export var carry_lock_rotation: bool = true
@export var drop_distance_threshold: float = 3.5

@onready var throwable = $Throwable

@export_flags_3d_physics var layers_while_carrying: int = 0b00000000_00000000_00000000_00000010

@onready var rigid_body: RigidBody3D = get_parent_entity().get_physics_body()

var carry_interactor: Interactor

var _default_layers: int

# TODO: sounds
# TODO: disable hotbar when carrying

func _ready():
	assert(is_instance_valid(rigid_body))
	_default_layers = rigid_body.collision_layer
	_toggle_process()
	
func _physics_process(_delta):
	var carry_position = carry_interactor.get_pos_along_ray(carry_distance)
	rigid_body.set_linear_velocity((carry_position - rigid_body.global_position) * carry_velocity_multiplier)
	# Square other side to avoid sqrt()
	if (carry_position - rigid_body.global_position).length_squared() > pow(drop_distance_threshold, 2):
		interact(carry_interactor)

func _toggle_process():
	rigid_body.set_lock_rotation_enabled(toggled)
	set_process_unhandled_key_input(toggled)
	set_physics_process(toggled)
	
	if toggled:
		rigid_body.collision_layer = layers_while_carrying
	else:
		rigid_body.collision_layer = _default_layers
	
	throwable.is_active = toggled

func interact(interactor: Interactor):
	super(interactor)
	
	if toggled:
		interactor.start_entity_lock()
		carry_interactor = interactor
		throwable.thrown.connect(interact.bind(interactor))
	else:
		interactor.end_entity_lock()
		carry_interactor = null
		throwable.thrown.disconnect(interact)
	print("carry")
	_toggle_process()
