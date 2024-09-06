extends Node3D
class_name Item

@onready var area: Area3D = $Area3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

@export var amount: int = 1
@export var view_name: String = ""
@export_multiline var view_description: String = ""
@export var is_stackable: bool = true
@export_enum("Common", "Rare", "Dame") var rarity: String = "Common"
@export_enum("Front", "Angled", "Top") var icon_orientation: String = "Front"

const VIEWMODEL_SCALE: float = 0.5

var dropped = false

var user: Node3D:
	set(new_user):
		if user == new_user:
			return
		user = new_user
		if user:
			process_mode = PROCESS_MODE_DISABLED
			dropped = false
			area.monitorable = false
			transform = Transform3D.IDENTITY
			transform = transform.scaled_local(Vector3.ONE * VIEWMODEL_SCALE)
			_reset_bob()
		else:
			process_mode = PROCESS_MODE_ALWAYS
			dropped = true
			area.monitorable = true

var init_transform: Transform3D
var bob_time: float

func primary_attack():
	pass

func secondary_attack():
	pass

func inspect():
	pass

func _ready() -> void:
	area.monitoring = false
	init_transform = mesh_instance.transform
	bob_time += (global_position.x + global_position.z) / 10
	
func _process(delta) -> void:
	_bob(delta)

func _reset_bob():
	bob_time = 0
	mesh_instance.transform = init_transform
	mesh_instance.rotation.y = 0

func _bob(delta):
	bob_time += delta
	mesh_instance.transform.origin = init_transform.origin + Vector3(0, sin(bob_time) * 0.1, 0)
	mesh_instance.rotate_y(delta)

func get_icon_path():
	return "res://assets/textures/icon.svg"

# NOTE: NOT QUEUE FREED
func despawn() -> void:
	get_parent().remove_child(self)
