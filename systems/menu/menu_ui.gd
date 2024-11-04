extends Control
class_name MenuUI

@export var opening_actions: Array[String]
@export var closing_actions: Array[String] = ["close_menu"]

@export var blocked_actions: Array[String] = ["up", "down", "left", "right", "jump", "crouch"]
@export var blocked_ui_actions: Array[String] = ["hotbar_left", "hotbar_right"]

var _last_mouse_pos: Vector2

func _ready():
	close()

func _unhandled_key_input(event):
	if not event.is_echo():
		for action in opening_actions:
			if event.is_action_pressed(action):
				accept_event()
				open()
				return

func _input(event):
	if event is InputEventMouseMotion:
		return
	if not event.is_echo():
		for action in closing_actions:
			if event.is_action_pressed(action):
				accept_event()
				close()
				return
	block_actions()
	for action in blocked_ui_actions:
		if event.is_action(action):
			accept_event()
		
func toggle():
	if visible:
		close()
	else:
		open()

var _blocked: Dictionary

func block_actions():
	for action in blocked_actions:
		if Input.is_action_pressed(action):
			Input.action_release(action)
			if _blocked.has(action):
				continue
			_blocked[action] = true

func unblock_actions():
	for action in _blocked.keys():
		var pressed = false
		for input_event: InputEvent in InputMap.action_get_events(action):
			var input_event_key = input_event as InputEventKey
			if not input_event_key:
				continue
			if Input.is_key_pressed(input_event_key.get_physical_keycode_with_modifiers()):
				pressed = true
				break
		if pressed:
			Input.action_press(action)
	_blocked.clear()
		
func open():
	block_actions()
	set_process_unhandled_key_input(false)
	set_process_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if _last_mouse_pos and get_viewport_rect().has_point(global_position + _last_mouse_pos):
		warp_mouse(_last_mouse_pos)
	show()

func close():
	hide()
	unblock_actions()
	set_process_unhandled_key_input(true)
	set_process_input(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_last_mouse_pos = get_local_mouse_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
