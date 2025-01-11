extends Control

@onready var input_icon = $MarginContainer/InputIcon
@onready var prompt_container = $PromptContainer

func set_input_action(input_action: String):
	input_icon.input_action = input_action
	
# TODO: When prompt container empty, hide
