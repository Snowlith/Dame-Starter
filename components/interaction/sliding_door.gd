extends Interactable
class_name SlidingDoor

@export var is_open: bool = false

@export var open_offset := Vector3(0, 0, 0.5)
@export var closed_offset: Vector3

@export var open_close_speed: float = 10

@onready var parent: Entity = get_parent_entity()

var _ab: AnimatableBody3D
var _init_pos: Vector3
var _target_offset: Vector3

var _epsilon: float = 0.01

# TODO: sounds

func _ready():
	if parent:
		_ab = parent.get_physics_body()
		_ab.sync_to_physics = false
		await parent.ready # Make sure top level == true
		_init_pos = _ab.transform.origin
	else:
		queue_free()

func interact(interactor: Interactor = null):
	is_open = not is_open
	set_physics_process(true)
	if interactor:
		interactor.end_interaction(false)

func _physics_process(delta):
	var target_pos = _init_pos
	if is_open:
		target_pos += open_offset
	else:
		target_pos += closed_offset
	if (target_pos - _ab.global_transform.origin).length_squared() < pow(_epsilon, 2):
		set_physics_process(false)
		return
	_ab.global_transform.origin = _ab.global_transform.origin.lerp(target_pos, open_close_speed * delta)
