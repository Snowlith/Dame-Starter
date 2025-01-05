extends Control

@onready var input_icon = $MarginContainer/InputIcon
@onready var prompt_container = $PromptContainer

var _interactable_to_prompt: Dictionary

func set_input_action(input_action: String):
	input_icon.input_action = input_action
	input_icon.update()

func add_interactable(interactable: Interactable):
	var label = Label.new()
	
	var prompt = interactable.get_prompt()
	_on_interactable_prompt_changed(prompt, label)
	interactable.prompt_changed.connect(_on_interactable_prompt_changed.bind(label))
	prompt_container.add_child(label)

func _on_interactable_prompt_changed(prompt: String, label: Label):
	if not prompt:
		label.hide()
		return
	label.text = prompt
	label.show()
