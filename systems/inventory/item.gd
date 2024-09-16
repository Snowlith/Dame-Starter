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
		update()

@onready var view_model: Node3D = $ViewModel

@onready var area: Area3D = $Area3D
@onready var area_col: CollisionShape3D = $Area3D/CollisionShape3D
@onready var base_anim_player: AnimationPlayer = $BaseAnimationPlayer

# TODO: add droppable flag
# TODO: design unique way to represent item stacks 

func update():
	is_equipped = user != null
	area_col.disabled = is_equipped
	_toggle_process_mode()
	if is_equipped:
		transform = Transform3D.IDENTITY.scaled_local(Vector3.ONE * VIEWMODEL_SCALE)
		_reset_bob()
	else:
		transform.basis = init_transform.basis

func is_same(item: Item):
	if not item:
		return false
	return scene_file_path == item.scene_file_path

func in_animation():
	for child in get_children():
		var ap = child as AnimationPlayer
		if not ap:
			continue
		if ap.is_playing():
			return true
	return false

func collect():
	if not base_anim_player.has_animation("collect"):
		return
	base_anim_player.play("collect")
	await base_anim_player.animation_finished
	base_anim_player.play("RESET")
	base_anim_player.advance(0)

func added():
	if not base_anim_player.has_animation("added"):
		return
	base_anim_player.play("added")

func removed():
	if not base_anim_player.has_animation("removed"):
		return
	base_anim_player.play("removed")

func drop():
	if not base_anim_player.has_animation("drop"):
		return
	base_anim_player.play("drop")

func inspect():
	if in_animation():
		return
	if not base_anim_player.has_animation("inspect"):
		return
	base_anim_player.play("inspect")
	
func _toggle_process_mode() -> void:
	set_process(not is_equipped)
	set_process_unhandled_input(is_equipped)

func _ready() -> void:
	base_anim_player.process_mode = Node.PROCESS_MODE_ALWAYS
	area.monitoring = false
	init_transform = view_model.transform
	_toggle_process_mode()
	if not is_equipped:
		_bob_time += (global_position.x + global_position.z) / 10

func _unhandled_input(event):
	if event.is_echo():
		return
	if event.is_action_pressed("inspect"):
		inspect()

## Dropped functionality
	
func _process(delta) -> void:
	_bob(delta)

func _reset_bob():
	_bob_time = 0
	view_model.transform = init_transform
	view_model.rotation.y = 0

func _bob(delta):
	_bob_time += delta
	view_model.transform.origin = init_transform.origin + Vector3(0, (sin(_bob_time) + 1) * 0.1, 0)
	view_model.rotate_y(delta)
