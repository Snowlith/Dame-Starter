extends Node

var _bool_signals: Dictionary
var _vec1_signals: Dictionary
var _vec2_signals: Dictionary

var _input_events: Dictionary

func create_bool_signal(input_action: StringName):
	#if not _bool_signals.has(input_action):
		#for event in InputMap.action_get_events(input_action):
			#var event_string = event.as_text()
			#if not _input_events.has(event_string):
				#_input_events[event_string] = Signal(self, input_action)
			#_input_events[event_string].append("this is the signal")
		#print(_input_events)
		#_bool_signals[input_action] = Signal(self, input_action)
		#add_user_signal(input_action, [{"name": "is_pressed", "type": TYPE_BOOL}])
	#return _bool_signals[input_action]
	pass

func create_string(input_event: InputEvent):
	return input_event.as_text()

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
