extends Interactable
class_name SlidingDoor

@export var is_open: bool = false

@export var open_offset := Vector3(0, 0, 0.5)
@export var closed_offset: Vector3

@export var opening_duration: float = 0.5
@export var closing_duration: float = 0.5

@onready var _ab: AnimatableBody3D = get_parent_entity() as PhysicsBody3D

var _init_pos: Vector3

# TODO: sounds

func _ready():
	if _ab:
		_ab.sync_to_physics = false
		await get_parent_entity().ready # Make sure top level == true
		_init_pos = _ab.global_position
	else:
		queue_free()

func interact(interactor: Interactor):
	is_open = not is_open
	_start_tween()

func _start_tween():
	var target_pos = _init_pos
	if is_open:
		target_pos += _ab.global_basis * open_offset
	else:
		target_pos += _ab.global_basis * closed_offset
	var duration = opening_duration if is_open else closing_duration
	
	var tween = create_tween().bind_node(_ab).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_ab, "global_position", target_pos, duration)
