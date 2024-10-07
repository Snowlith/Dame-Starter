extends Component
class_name StateMachine

@export_enum("First child is highest priority:0", "First child is lowest priority:1") var state_priority_order: int = 1

var states: Array = []
var selected_state: State
var _input_state_map: Dictionary

@onready var label = $PanelContainer/Label

signal state_changed

# BUG: slide is forced when under an obstacle even though the crouch is more valid
# This is because slide has a higher priority than the crouch
# Slide does not want to be active, just has to because there is an object above it
# Crouch wants to be active but is a lower priority
# Crouch should be selected

# Return two values with exit (active, forced)
# Use these to determine it

func _ready():
	states = find_children("", "State")
	if state_priority_order:
		states.reverse()
	_create_input_state_map()

func _create_input_state_map():
	_input_state_map.clear()
	for state in states:
		for action in state.input.keys():
			if _input_state_map.has(action):
				_input_state_map[action].append(state)
			else:
				_input_state_map[action] = [state]

# For mouse input, use a different method
func _unhandled_key_input(event):
	if event.is_echo():
		return
	for action in _input_state_map.keys():
		if event.is_action(action):
			var result = int(event.is_pressed())
			for state in _input_state_map[action]:
				state.input[action] = result
				state.input_changed.emit(action, result)

func _physics_process(delta):
	_update_states(delta)

func _update_states(delta):
	var state_priority = []
	
	for state in states:
		if state.disabled:
			continue
		var status = state.update_status(delta)
		state_priority.append([state, status])
	
	state_priority.sort_custom(_compare_status)
	
	if state_priority.is_empty():
		return
	var new_state = state_priority[0][0]
	if selected_state != new_state:
		if selected_state:
			selected_state.exit()
		selected_state = new_state
		selected_state.enter()
		state_changed.emit()
	
	selected_state.handle(delta)
	
	_update_label(state_priority)

func _compare_status(a: Array, b: Array):
	return a[1] > b[1]

func _update_label(active_states):
	var text = ""
	for state in active_states:
		text = text + str(state) + "\n"
	label.text = text
