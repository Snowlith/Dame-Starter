extends Node3D
class_name Item

var icon_dir = "res://items/icons/"

@export var stack_size: int = 1:
	set(value):
		if stack_size == value:
			return
		stack_size = value
		
@export var view_name: String = ""
@export_multiline var view_description: String = ""
@export var is_stackable: bool = true
@export_enum("Common", "Rare", "Dame") var rarity: String = "Common"
@export_enum("Front", "Angled", "Top") var icon_orientation: String = "Front"

const VIEWMODEL_SCALE: float = 0.5

var is_equipped: bool = false
var allow_unequip: bool = true
var _bob_time: float

var init_transform: Transform3D
var user: Node3D:
	set(new_user):
		if user == new_user:
			return
		user = new_user
		is_equipped = user != null
		area.monitorable = not is_equipped
		_toggle_process_mode()
		if user:
			transform = Transform3D.IDENTITY.scaled_local(Vector3.ONE * VIEWMODEL_SCALE)
			_reset_bob()
		else:
			transform = init_transform

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

@onready var area: Area3D = $Area3D
@onready var anim_player: AnimationPlayer = null

# TODO: design unique way to represent item stacks 
# TODO: refactor dropped to is_equipped

func is_same(item: Item):
	if not item:
		return false
	return scene_file_path == item.scene_file_path

func _toggle_process_mode() -> void:
	set_process(not is_equipped)
	set_process_unhandled_input(is_equipped)

func _ready() -> void:
	anim_player = $AnimationPlayer if has_node("AnimationPlayer") else null
	if anim_player:
		anim_player.process_mode = Node.PROCESS_MODE_ALWAYS
	area.monitoring = false
	init_transform = mesh_instance.transform
	if not is_equipped:
		set_process_unhandled_input(false)
		_bob_time += (global_position.x + global_position.z) / 10

## Dropped functionality
	
func _process(delta) -> void:
	_bob(delta)

func _reset_bob():
	_bob_time = 0
	mesh_instance.transform = init_transform
	mesh_instance.rotation.y = 0

func _bob(delta):
	_bob_time += delta
	mesh_instance.transform.origin = init_transform.origin + Vector3(0, sin(_bob_time) * 0.1, 0)
	mesh_instance.rotate_y(delta)
