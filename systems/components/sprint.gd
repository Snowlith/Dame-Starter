extends Node
class_name Sprint

@export var duration: float = 4.0
@export var speed_scalar: float = 1.4
@export var walk_recharge_rate: float = 1.0
@export var stand_recharge_rate: float = 2.5

@onready var sprint_bar: ProgressBar = $SprintBar

var time_left: float = duration:
	set(value):
		value = clamp(value, 0, duration)
		if value == time_left:
			return
		time_left = value
		sprint_bar.value = time_left / duration

var active: bool = false

func handle(input: bool, cb: CharacterBody3D, input_vector: Vector2, delta: float) -> void:
	var is_zero = input_vector == Vector2.ZERO
	active = false
	if not input or cb.is_on_wall() or is_zero:
		if is_zero:
			time_left += stand_recharge_rate * delta
		else:
			time_left += walk_recharge_rate * delta
		return
	
	# When sprinting, drain sprint time
	time_left -= delta
	if time_left <= 0:
		time_left = 0
		return
	
	active = true
