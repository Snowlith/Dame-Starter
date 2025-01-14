extends Door
class_name RotatingDoor

@export var open_angle: float = 90
@export var closed_angle: float = 0

@export var rotation_axis: Vector3 = Vector3.UP # Default to y-axis (Vector3(0, 1, 0))

enum RotationDirection {
	Bidirectional,
	Counterclockwise,
	Clockwise
}

@export var rotation_direction: RotationDirection = RotationDirection.Bidirectional

var _init_rotation: Vector3

var _last_tween: Tween

# TODO: sounds
# TODO: use test body motion thing to validate door opening

func _ready():
	super()
	if not target:
		return
	if not target.is_node_ready():
		await target.ready
	_init_rotation = target.rotation

func interact(interactor: Interactor):
	super(interactor)
	
	var side = _get_entity_side(interactor.get_parent_entity().global_position)
	var target_angle: float
	if toggled:
		target_angle = side * deg_to_rad(open_angle)
	else:
		target_angle = deg_to_rad(closed_angle)
	
	var shit = _init_rotation * target.global_basis
	var target_rotation = set_angle_along_axis(shit, target_angle, rotation_axis)
	print(target_rotation)
	_last_tween = create_tween().bind_node(target).set_trans(transition).set_ease(easing)
	_last_tween.tween_property(target, "rotation", target_rotation, get_duration())

func _get_entity_side(entity_position: Vector3) -> int:
	match rotation_direction:
		RotationDirection.Bidirectional:
			var door_to_player = (entity_position - target.global_position).normalized()
			var local_player_direction = door_to_player * target.global_basis
			return 1 if local_player_direction.z > 0 else -1
		RotationDirection.Counterclockwise:
			return 1
		RotationDirection.Clockwise:
			return -1
	return 1


# Helper function to get the rotation angle along a specific axis
func get_angle_along_axis(rotation: Vector3, axis: Vector3) -> float:
	axis = axis.normalized()
	return axis.dot(rotation)

# Helper function to set the rotation angle along a specific axis
func set_angle_along_axis(rotation: Vector3, angle: float, axis: Vector3) -> Vector3:
	axis = axis.normalized()
	return rotation + axis * angle
