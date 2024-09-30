extends Component
class_name StateMachine

@export var default_state: State

var states: Array = []
var selected_state: State
var _input_state_map: Dictionary

@onready var label = $PanelContainer/Label

signal state_changed

# TODO: remove priority system, do in node order

# BIND METHOD FOR Signals
# TODO: put all input events passed in as a dictionary from the state machine
# * Could either run a custom event bus each time an event is received
# * Or could combine is_active and input methods to create a more uniform update bool

# TODO: inherit a player movement specific state machine
# TODO: add a data class for persistent info across states

# DICTIONARY MERGE

func _ready():
	states = find_children("", "State")
	states.sort_custom(sort_priority)
	_create_input_state_map()
	
	selected_state = default_state
	default_state.enter()
	state_changed.emit()
	
	state_changed.connect(func(): print("state: " + str(selected_state)))

func _create_input_state_map():
	_input_state_map.clear()
	for state in states:
		for action in state.input.keys():
			if _input_state_map.has(action):
				_input_state_map[action].append(state)
			else:
				_input_state_map[action] = [state]
	print(_input_state_map)

# CANT BE KEY INPUT FOR MOUSE STUFF
func _unhandled_key_input(event):
	if event.is_echo():
		return
	for action in _input_state_map.keys():
		if event.is_action(action):
			var result = int(event.is_pressed())
			for state in _input_state_map[action]:
				state.input[action] = result
				state.input_changed.emit(action, result)

func update(delta):
	_update_states(delta)

func sort_priority(a: State, b: State):
	return a.priority > b.priority

func _update_states(delta):
	var active_states = []
	
	for state in states:
		if state.is_active():
			active_states.append(state)
	
	if active_states.is_empty():
		return
	var new_state = active_states[0]
	if selected_state != new_state:
		# try exiting state
		if not selected_state or selected_state.exit():
			selected_state = new_state
			selected_state.enter()
			state_changed.emit()
	selected_state.handle(delta)
	
	_update_label(active_states)

func _update_label(active_states):
	var text = ""
	for state in active_states:
		text = text + str(state) + "\n"
	label.text = text
