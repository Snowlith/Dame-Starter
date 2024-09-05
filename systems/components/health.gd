extends Node
class_name Health

@export var max_health: int = 100

@onready var health_bar: ProgressBar = $HealthBar

var current_health = 50:
	set(value):
		value = clamp(value, 0, max_health)
		if value == current_health:
			return
		current_health = value
		update()

func _ready():
	health_bar.max_value = max_health
	update()

func update():
	health_bar.value = current_health
	
	
