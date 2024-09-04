extends Node
class_name Jump

@export var strength: float = 13.0
@export var coyote_time: float = 0.2

var current_coyote_time: float = 0

var active: bool = false

func handle(input: bool, cb: CharacterBody3D, delta: float) -> void:
	active = false
	if cb.is_on_floor():
		current_coyote_time = coyote_time
		if input:
			active = true
			cb.velocity.y = strength
			current_coyote_time = 0
	else:
		current_coyote_time = max(current_coyote_time - delta, 0)
		
		if current_coyote_time > 0 and input:
			active = true
			cb.velocity.y = strength
			current_coyote_time = 0
