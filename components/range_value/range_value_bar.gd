extends ProgressBar

var _parent: RangeValue
var _interp_value: float

func _process(delta):
	if is_equal_approx(_interp_value, _parent.value):
		return
	_interp_value = lerp(_interp_value, float(_parent.value), 10 * delta)
	_update()

func _ready():
	_parent = get_parent()
	assert(_parent is Health)
	max_value = _parent.max_value
	min_value = _parent.min_value
	_interp_value = _parent.value
	_update()

func _update():
	value = _interp_value
	
