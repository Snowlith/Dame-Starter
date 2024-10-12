extends Component
class_name Cheats

@onready var label = $Label

@onready var physics_body: PhysicsBody3D = get_parent_entity() as PhysicsBody3D

func _process(delta):
	label.text = "Velocity: " + str(snapped(Vector3(physics_body.velocity.x, 0, physics_body.velocity.z).length(), 0.01))

func _unhandled_key_input(event):
	if event.is_echo():
		return
	if event.is_action_pressed("reset"):
		physics_body.global_position = Vector3(0, 50, 0)
