extends State
class_name JumpState

@export var strength: float = 5
@export var coyote_time: float = 0.15
@export var input_leniency: float = 0.15

var _time_since_left_ground: float = 0
var _input_leniency_timer: SceneTreeTimer
var _is_input_queued: bool = false

func _init():
	input = {"jump": 0}

func _ready():
	super()
	input_changed.connect(_on_input_changed)

func _on_input_changed(action: String, value: int):
	if action == "jump":
		_is_input_queued = bool(value)
		if is_instance_valid(_input_leniency_timer):
				_input_leniency_timer.timeout.disconnect(_leniency_over)
				_input_leniency_timer = null
		if value:
			_input_leniency_timer = get_tree().create_timer(input_leniency)
			_input_leniency_timer.timeout.connect(_leniency_over)
				
func _leniency_over():
	_is_input_queued = false
	
func is_active():
	if (character_body.is_on_floor() or _time_since_left_ground < coyote_time) and _is_input_queued:
		return true
	return false

func _physics_process(delta):
	if character_body.is_on_floor():
		_time_since_left_ground = 0
	else:
		_time_since_left_ground += delta

func handle(delta: float):
	character_body.velocity.y = strength
	
	_time_since_left_ground = 100
	character_body.move_and_slide()
	input["jump"] = 0
	_is_input_queued = false
