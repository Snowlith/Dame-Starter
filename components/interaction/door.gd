extends Interactable
class_name Door

@export var is_open: bool = false

@export var open_angle: float = 90
@export var closed_angle: float = 0

@export var opening_duration: float = 0.35
@export var closing_duration: float = 0.35

@export_enum("Bidirectional", "Counterclockwise", "Clockwise") var rotation_direction: String = "Bidirectional"

@onready var parent: Entity = get_parent_entity()

var _ab: AnimatableBody3D
var _init_angle: float

var _epsilon: float = 0.01

# TODO: bidirectional door, goes away from opener
# TODO: sounds

func _ready():
	if parent:
		_ab = parent as PhysicsBody3D
		_ab.sync_to_physics = false
		await parent.ready # Make sure top level == true
		_init_angle = _ab.rotation.y
	else:
		queue_free()

func interact(interactor: Interactor):
	is_open = not is_open
	_start_tween(_get_entity_side(interactor.get_parent_entity().global_position))

func _get_entity_side(entity_position: Vector3) -> int:
	match rotation_direction:
		"Bidirectional":
			var door_to_player = (entity_position - _ab.global_position).normalized()
			var local_player_direction = door_to_player * _ab.global_basis
			return 1 if local_player_direction.z > 0 else -1
		"Counterclockwise":
			return 1
		"Clockwise":
			return -1
	return 1

func _start_tween(side: int):
	var target_rotation = Vector3(0, _init_angle, 0)
	if is_open:
		target_rotation.y += side * deg_to_rad(open_angle)
	else:
		target_rotation.y += deg_to_rad(closed_angle)
	var duration = opening_duration if is_open else closing_duration
	
	var tween = create_tween().bind_node(_ab).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_ab, "rotation", target_rotation, duration)
