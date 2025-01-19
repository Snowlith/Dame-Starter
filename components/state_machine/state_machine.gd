extends Component
class_name StateMachine

@export_enum("First child is highest priority:0", "First child is lowest priority:1") var state_priority_order: int = 1

var states: Array = []
var selected_state: State

@onready var label = $PanelContainer/Label

signal state_changed

func _init():
	# Ready runs before children
	process_priority = -1

func _ready():
	states = get_parent_entity().get_components(State)
	if state_priority_order:
		states.reverse()

func _physics_process(delta):
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
		#print(selected_state)
	
	selected_state.handle(delta)
	
	_update_label(state_priority)

func _compare_status(a: Array, b: Array):
	return a[1] > b[1]

func _update_label(active_states):
	var text = ""
	for state in active_states:
		text = text + str(state) + "\n"
	label.text = text
