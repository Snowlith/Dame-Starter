extends Component
class_name InputManager

var _bool_signals: Dictionary
var _vec1_signals: Dictionary
var _vec2_signals: Dictionary

var _actions: Dictionary

# Dictionary of each keyboard key -> array of signals that are called

# 1. Convert event to array of actions
# 2. Dictionary of each input action -> array of signals

#var shit = {"jump": jump_signal, shit_signal}

#func _ready():
#
	#print(InputMap.get_actions())

func _input(event):
	if not event is InputEventKey and not event is InputEventMouseButton:
		return
	for action in _actions.keys():
		if event.is_action_pressed(action):
			for sig in _actions[action]:
				sig.emit()

func get_bool_signal(action: String):
	var bool_signal = Signal(self, action)
	add_user_signal(action, [{"name": "is_pressed", "type": TYPE_BOOL}])
	if _actions.has(action):
		_actions[action].append(bool_signal)
	else:
		_actions[action] = [bool_signal]
	return bool_signal
	
	#var inputs = get_keyboard_inputs_for_action(action)
	#for input in inputs:
		#if _input_events.has(input):
			#_input_events[input].append(bool_signal)
		#else:
			#_input_events[input] = [bool_signal]
	#print(_input_events)
	#return bool_signal
			
	#if not _bool_signals.has(action):
		#for event in InputMap.action_get_events(input_action):
			#var event_string = event.as_text()
			#if not _input_events.has(event_string):
				#_input_events[event_string] = Signal(self, input_action)
			#_input_events[event_string].append("this is the signal")
		#print(_input_events)
		#_bool_signals[input_action] = Signal(self, input_action)
		#add_user_signal(input_action, [{"name": "is_pressed", "type": TYPE_BOOL}])
	#return _bool_signals[input_action]

func get_keyboard_inputs_for_action(action: String) -> Array[InputEvent]:
	return InputMap.action_get_events(action).filter(func(event):
		return event is InputEventKey or event is InputEventMouseButton
	)

func get_keyboard_input_for_action(action: String) -> InputEvent:
	var inputs: Array[InputEvent] = get_keyboard_inputs_for_action(action)
	return null if inputs.is_empty() else inputs[0]

#func create_vec1_signal(positive_x: StringName, negative_x: StringName):
	#var signal_name: StringName = positive_x + "/" + negative_x
	#if not _vec1_signals.has(signal_name):
		#_vec1_signals[signal_name] = Signal(self, signal_name)
		#add_user_signal(signal_name, [{"name": "value", "type": TYPE_INT}])
	#return _vec1_signals[signal_name]
#
#func create_vec2_signal(positive_x: StringName, negative_x: StringName, positive_y: StringName, negative_y: StringName):
	#var signal_name: StringName = positive_x + "/" + negative_x + "/" + positive_y + "/" + negative_y
	#if not _vec1_signals.has(signal_name):
		#_vec1_signals[signal_name] = Signal(self, signal_name)
		#add_user_signal(signal_name, [{"name": "value", "type": TYPE_VECTOR2I}])
	#return _vec1_signals[signal_name]

#func _input(event):
	#if event is InputEventMouseMotion or event is InputEventScreenDrag:
		#return
	#print(event)
	#print(event.as_text())
	#print(_input_events.has(event))
	#
	
	#for signal_name in _bool_signals.keys():
		#if event.is_action(signal_name):
			#_bool_signals[signal_name].emit(event.is_pressed())
	
	#for signal_name in _vec1_signals.keys():
		#var positive_x = signal_name.split("/")[0]
		#var negative_x = signal_name.split("/")[1]
		#var value = 0.0
		#if event.is_action(positive_x) or event.is_action(negative_x):
			#_vec1_signals[signal_name].emit(value)
	
	# Handle 2D vector signals (e.g., movement with 4 directions)
	#for signal_name in _input_signals.keys():
		#if signal_name.ends_with("_2d"):
			#var components = signal_name.split("_")
			#var left = components[0]
			#var right = components[1]
			#var up = components[2]
			#var down = components[3]
			#var vector = Vector2(
				#int(Input.is_action_pressed(right)) - int(Input.is_action_pressed(left)),
				#int(Input.is_action_pressed(down)) - int(Input.is_action_pressed(up))
			#)
			#_input_signals[signal_name].emit(vector)
