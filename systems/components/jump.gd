extends Node
class_name Jump

@export var strength: float = 13.0
@export var coyote_time: float = 0.2
@export var leniency: float = 0.15

@export var jump_sound: AudioStream

var current_coyote_time: float = 0
var time_since_input: float = 0

var input: bool = false

func _unhandled_key_input(event):
	if event.is_echo():
		return
	if event.is_action_pressed("jump"):
		input = true
		time_since_input = 0
	elif event.is_action_released("jump"):
		input = false

func handle(cb: CharacterBody3D, delta: float) -> bool:
	_handle_leniency(delta)
	
	if cb.is_on_floor():
		current_coyote_time = coyote_time
		if input:
			cb.velocity.y = strength
			current_coyote_time = 0
			Audio.play_sound(jump_sound)
			return true
	else:
		current_coyote_time = max(current_coyote_time - delta, 0)
		
		if current_coyote_time > 0 and input:
			cb.velocity.y = strength
			current_coyote_time = 0
			Audio.play_sound(jump_sound)
			return true
	return false

func _handle_leniency(delta: float):
	if input:
		time_since_input += delta
		
	if time_since_input > leniency:
		input = false
		time_since_input = 0
