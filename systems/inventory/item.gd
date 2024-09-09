extends Node3D
class_name Item

var icon_dir = "res://items/icons/"

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

var dropped: bool = true
var allow_unequip: bool = true
var _bob_time: float

var init_transform: Transform3D
var user: Node3D:
	set(new_user):
		if user == new_user:
			return
		user = new_user
		_toggle_process_mode(user != null)
		dropped = not user
		area.monitorable = dropped
		if user:
			transform = Transform3D.IDENTITY.scaled_local(Vector3.ONE * VIEWMODEL_SCALE)
			clear_model_stack()
			_reset_bob()
		else:
			transform = init_transform
			update_model_stack()

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

@onready var area: Area3D = $Area3D
@onready var anim_player: AnimationPlayer = null

var _view_model_stack: Node3D

# TODO: refactor dropped to is_equipped

func _toggle_process_mode(is_equipped: bool) -> void:
	set_process(not is_equipped)
	set_process_unhandled_input(is_equipped)

func _ready() -> void:
	anim_player = $AnimationPlayer if has_node("AnimationPlayer") else null
	if anim_player:
		anim_player.process_mode = Node.PROCESS_MODE_ALWAYS
	area.monitoring = false
	init_transform = mesh_instance.transform
	if dropped:
		set_process_unhandled_input(false)
		update_model_stack()
		_bob_time += (global_position.x + global_position.z) / 10

## Dropped functionality
	
func _process(delta) -> void:
	_bob(delta)

func _reset_bob():
	_bob_time = 0
	mesh_instance.transform = init_transform
	mesh_instance.rotation.y = 0
	_view_model_stack.transform = mesh_instance.transform

func _bob(delta):
	_bob_time += delta
	mesh_instance.transform.origin = init_transform.origin + Vector3(0, sin(_bob_time) * 0.1, 0)
	mesh_instance.rotate_y(delta)
	_view_model_stack.transform = mesh_instance.transform

func clear_model_stack() -> void:
	for model in _view_model_stack.get_children():
		_view_model_stack.remove_child(model)
		model.queue_free()

func update_model_stack() -> void:
	# Skip when runs before ready
	if not mesh_instance:
		return
	if not _view_model_stack:
		_view_model_stack = Node3D.new()
		add_child(_view_model_stack)
	var models = _view_model_stack.get_children()
	# Remove all children of the mesh stack except the first one
	var real_stack_size: int = clamp(stack_size - 1, 0, 3)
	
	var diff = real_stack_size - models.size()
	
	if diff == 0:
		return
	elif diff > 0:
		for i in diff:
			duplicate_mesh_instance()
	else:
		for i in range(models.size(), models.size()-diff, -1):
			_view_model_stack.remove_child(models[i])
			models[i].queue_free()

# Function to duplicate the mesh instance with a random offset
func duplicate_mesh_instance() -> void:
	# Create a new instance of MeshInstance3D
	var dupe = mesh_instance.duplicate()
	
	# Add the new instance to the mesh stack
	_view_model_stack.add_child(dupe)
	
	var d: float = 0.75
	# Set a random offset position for the new mesh instance
	var random_offset = Vector3(randf() * d - d/2, 0, randf() * d - d/2)
	dupe.transform.origin = random_offset

# NOTE: NOT QUEUE FREED
func despawn() -> void:
	get_parent().remove_child(self)
