extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pressed.connect(_on_pressed)

func _on_pressed():
	get_tree().quit()
