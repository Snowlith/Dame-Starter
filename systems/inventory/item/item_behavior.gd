extends Node3D
class_name ItemBehavior

var is_equipped: bool = false

func _ready():
	set_process_unhandled_input(false)

func equip():
	is_equipped = true
	scale = Vector3.ONE * 0.5
	set_process_unhandled_input(true)

func unequip():
	#animation
	queue_free()

func _unhandled_input(event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		print("box")
