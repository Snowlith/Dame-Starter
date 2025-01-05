extends State
class_name JumpState

@export var strength: float = 5
@export var coyote_time: float = 0.15
@export var input_leniency: float = 0.15
@export var allow_bunnyhop: bool = false
@export var allow_slope_boost_jump: bool = false

var _time_since_left_ground: float = 0
var _input_leniency_timer: SceneTreeTimer
var _is_input_queued: bool = false

# TODO: make slope boost jump less op, maybe add area where it is possible
# TODO: add force jump (maybe better to have a more flexible impulse system)
	
func _physics_process(delta):
	if Input.is_action_just_pressed("jump") or (allow_bunnyhop and Input.is_action_pressed("jump")):
		_is_input_queued = true
		if is_instance_valid(_input_leniency_timer):
				_input_leniency_timer.timeout.disconnect(_leniency_over)
		_input_leniency_timer = get_tree().create_timer(input_leniency)
		_input_leniency_timer.timeout.connect(_leniency_over)
	
	if _cb.is_on_floor():
		_time_since_left_ground = 0
	else:
		_time_since_left_ground += delta
				
func _leniency_over():
	_is_input_queued = false
	
func update_status(delta: float):
	if _is_input_queued and (_cb.is_on_floor() or _time_since_left_ground < coyote_time):
		return Status.ACTIVE
	return Status.INACTIVE

func handle(delta: float):
	if allow_slope_boost_jump:
		_cb.velocity.y += strength
	else:
		if _cb.velocity.y < strength:
			_cb.velocity.y = strength
	
	_time_since_left_ground = 100
	_is_input_queued = false
	
	_cb.move_and_slide()
