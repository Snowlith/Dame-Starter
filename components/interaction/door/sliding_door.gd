extends Door
class_name SlidingDoor

@export var open_offset := Vector3(0, 0, 0.5)
@export var closed_offset: Vector3

var _init_pos: Vector3

# TODO: sounds

func _ready():
	if target:
		if target is AnimatableBody3D:
			target.sync_to_physics = false
		await get_parent_entity().ready # Make sure top level == true
		_init_pos = target.position
	else:
		queue_free()

func interact(interactor: Interactor):
	is_open = not is_open
	
	var target_pos = _init_pos
	if is_open:
		target_pos += target.basis * open_offset
	else:
		target_pos += target.basis * closed_offset
	
	var tween = create_tween().bind_node(target).set_trans(get_interpolation()).set_ease(get_easing())
	tween.tween_property(target, "position", target_pos, get_duration())