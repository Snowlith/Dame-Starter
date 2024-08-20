extends Camera3D
class_name SmoothCamera3D

var target: Node3D

var start_pos: Vector3

var old_transform: Transform3D
var new_transform: Transform3D

var use_interp: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	target = get_parent()
	
	start_pos = position
	
	# Copy the target transform
	new_transform = target.global_transform
	old_transform = target.global_transform
	
func _physics_process(delta):
	# Update the transform, lagging old_transform one physics frame behind
	old_transform = new_transform
	new_transform = target.transform

func update_camera(delta: float, offset: Vector3):
	var f = Engine.get_physics_interpolation_fraction()
	if use_interp:
		global_transform.origin = old_transform.interpolate_with(new_transform, f).origin
	else:
		global_transform.origin = new_transform.origin # Disable interpolation for debugging
	position += start_pos + offset
	
