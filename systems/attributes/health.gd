extends Attribute
class_name Health

@export var max_health: int = 100

@onready var health_bar: ProgressBar = $HealthBar

var current_health: int = 50:
	set(value):
		value = clamp(value, 0, max_health)
		if value == current_health:
			return
		current_health = value

var _interp_health: float = current_health

func _process(delta):
	if is_equal_approx(_interp_health, current_health):
		return
	_interp_health = lerp(_interp_health, float(current_health), 10 * delta)
	update()

func _ready():
	health_bar.max_value = max_health
	update()

func update():
	health_bar.value = _interp_health
	
	
