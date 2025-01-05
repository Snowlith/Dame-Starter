extends Door
class_name SlidingDoor

@export var open_offset := Vector3(0, 0, 0.5)
@export var closed_offset: Vector3

var _init_pos: Vector3

# TODO: sounds

func _ready():
	super()
	if not target:
		return
	if not target.is_node_ready():
		await target.ready
	_init_pos = target.position

func interact(interactor: Interactor):
	super(interactor)
	
	var target_pos = _init_pos
	if enabled:
		target_pos += target.basis * open_offset
	else:
		target_pos += target.basis * closed_offset
	
	var tween = create_tween().bind_node(target).set_trans(get_interpolation()).set_ease(get_easing())
	tween.tween_property(target, "position", target_pos, get_duration())
