extends Interactable
class_name Door

@export var is_open: bool = false

@export var open_angle: float = 90
@export var closed_angle: float = 0

@export_enum("Counterclockwise:0", "Clockwise:1") var rotation_direction: int = 0

@export var open_close_speed: float = 10

@onready var parent: Entity = get_parent_entity()

var _ab: AnimatableBody3D
var _init_angle: float

var _epsilon: float = 0.01

# TODO: bidirectional door, goes away from opener
# TODO: sounds

func _ready():
	if parent:
		_ab = parent.get_physics_body()
		_ab.sync_to_physics = false
		await parent.ready # Make sure top level == true
		_init_angle = _ab.rotation.y
	else:
		queue_free()

func interact(interactor: Interactor = null):
	is_open = not is_open
	set_physics_process(true)
	if interactor:
		interactor.end_interaction(false)

func _physics_process(delta):
	var target_angle_rad = _init_angle
	if is_open:
		if rotation_direction:
			target_angle_rad -= deg_to_rad(open_angle)
		else:
			target_angle_rad += deg_to_rad(open_angle)
	else:
		target_angle_rad += deg_to_rad(closed_angle)
	if abs(target_angle_rad - _ab.rotation.y) < _epsilon:
		set_physics_process(false)
		return
	_ab.rotation.y = lerp_angle(_ab.rotation.y, target_angle_rad, open_close_speed * delta)
