extends Door
class_name RotatingDoor

@export var open_angle: float = 90
@export var closed_angle: float = 0

@export_enum("Bidirectional", "Counterclockwise", "Clockwise") var rotation_direction: String = "Bidirectional"

var _init_angle: float

var _last_tween: Tween

# TODO: sounds
# TODO: make an option to move the collider like a minecraft door
# less glitchy 
# use test body motion thing to validate door opening

# tween col shape angle in opposite dir

func _ready():
	super()
	if not target:
		return
	if not target.is_node_ready():
		await target.ready
	_init_angle = target.rotation.y

func interact(interactor: Interactor):
	super(interactor)
	
	var side = _get_entity_side(interactor.get_parent_entity().global_position)
	var target_rotation = Vector3(0, _init_angle, 0)
	if enabled:
		target_rotation.y += side * deg_to_rad(open_angle)
	else:
		target_rotation.y += deg_to_rad(closed_angle)
	
	_last_tween = create_tween().bind_node(target).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_last_tween.tween_property(target, "rotation", target_rotation, get_duration())

func _get_entity_side(entity_position: Vector3) -> int:
	match rotation_direction:
		"Bidirectional":
			var door_to_player = (entity_position - target.global_position).normalized()
			var local_player_direction = door_to_player * target.global_basis
			return 1 if local_player_direction.z > 0 else -1
		"Counterclockwise":
			return 1
		"Clockwise":
			return -1
	return 1
