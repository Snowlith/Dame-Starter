extends Node3D
class_name Item

var icon_dir = "res://items/icons/"

@onready var view_model_stack: Node3D = $ViewModelStack
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

@onready var area: Area3D = $Area3D
@onready var anim_player: AnimationPlayer = null

@export var stack_size: int = 1:
	set(value):
		if stack_size == value:
			return
		stack_size = value
		update_model_stack()
		
@export var view_name: String = ""
@export_multiline var view_description: String = ""
@export var is_stackable: bool = true
@export_enum("Common", "Rare", "Dame") var rarity: String = "Common"
@export_enum("Front", "Angled", "Top") var icon_orientation: String = "Front"

const VIEWMODEL_SCALE: float = 0.5

var dropped = true

var user: Node3D:
	set(new_user):
		if user == new_user:
			return
		user = new_user
		if user:
			set_process(false)
			set_process_unhandled_input(true)
			dropped = false
			area.monitorable = false
			transform = Transform3D.IDENTITY
			transform = transform.scaled_local(Vector3.ONE * VIEWMODEL_SCALE)
			clear_model_stack()
			_reset_bob()
		else:
			set_process(true)
			set_process_unhandled_input(false)
			dropped = true
			area.monitorable = true

var init_transform: Transform3D
var bob_time: float

# NOTE: NOT QUEUE FREED
func despawn() -> void:
	get_parent().remove_child(self)

func _ready() -> void:
	anim_player = $AnimationPlayer if has_node("AnimationPlayer") else null
	if anim_player:
		anim_player.process_mode = Node.PROCESS_MODE_ALWAYS
	area.monitoring = false
	init_transform = mesh_instance.transform
	if dropped:
		set_process_unhandled_input(false)
		update_model_stack()
		bob_time += (global_position.x + global_position.z) / 10

## Dropped functionality
	
func _process(delta) -> void:
	_bob(delta)

func _reset_bob():
	bob_time = 0
	mesh_instance.transform = init_transform
	mesh_instance.rotation.y = 0
	view_model_stack.transform = mesh_instance.transform

func _bob(delta):
	bob_time += delta
	mesh_instance.transform.origin = init_transform.origin + Vector3(0, sin(bob_time) * 0.1, 0)
	mesh_instance.rotate_y(delta)
	view_model_stack.transform = mesh_instance.transform

func clear_model_stack() -> void:
	if not view_model_stack:
		return
	var models = view_model_stack.get_children()
	for model in models:
		view_model_stack.remove_child(model)
		model.queue_free()

func update_model_stack() -> void:
	if not view_model_stack:
		return
	var models = view_model_stack.get_children()
	# Remove all children of the mesh stack except the first one
	var old_stack_size: int = models.size()
	var real_stack_size: int = clamp(stack_size-1, 0, 3)
	
	var diff = real_stack_size - old_stack_size
	
	if diff == 0:
		return
	elif diff > 0:
		for i in diff:
			duplicate_mesh_instance()
	else:
		for i in range(models.size(), models.size()-diff, -1):
			view_model_stack.remove_child(models[i])
			models[i].queue_free()

# Function to duplicate the mesh instance with a random offset
func duplicate_mesh_instance() -> void:
	# Create a new instance of MeshInstance3D
	var dupe = mesh_instance.duplicate()
	
	# Add the new instance to the mesh stack
	view_model_stack.add_child(dupe)
	
	var d: float = 0.75
	# Set a random offset position for the new mesh instance
	var random_offset = Vector3(randf() * d - d/2, 0, randf() * d - d/2)
	dupe.transform.origin = random_offset
