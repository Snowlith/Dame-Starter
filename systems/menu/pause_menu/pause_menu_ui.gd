extends MenuUI
class_name PauseMenuUI

@onready var main_menu_button = $PanelContainer/MarginContainer/VBoxContainer/MainMenuButton

# TODO: don't pause when lobby has players
func _ready():
	super()
	main_menu_button.pressed.connect(close)
	
func open():
	super()
	get_tree().paused = true

func close():
	super()
	get_tree().paused = false
