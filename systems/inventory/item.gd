extends Node3D
class_name Item

var icon_dir = "res://items/icons/"

@export var stack_size: int = 1:
	set(value):
		if stack_size == value:
			return
		
		if _allow_animations:
			if value < stack_size:
				play_removed()
			else:
				play_added()
		stack_size = value
		
@export var view_name: String = "Item"
@export_multiline var view_description: String = ""
@export var is_stackable: bool = true
@export var view_model_scale: float = 0.5
@export_enum("Common", "Rare", "Dame") var rarity: String = "Common"
@export_enum("Front", "Side", "Angled", "Top") var icon_orientation: String = "Front"

@export var pickup_sound: AudioStream
@export var drop_sound: AudioStream

var is_equipped: bool = false
var allow_unequip: bool = true
var _bob_time: float

var _init_transform: Transform3D
var _user: Node3D
var _allow_animations: bool = false

@onready var view_model: Node3D = $ViewModel

@onready var area: Area3D = $Area3D
@onready var area_col: CollisionShape3D = $Area3D/CollisionShape3D
@onready var base_anim_player: AnimationPlayer = $BaseAnimationPlayer



# TODO: add droppable flag
# TODO: design unique way to represent item stacks
# TODO: add holster animation

func _ready() -> void:
	base_anim_player.process_mode = Node.PROCESS_MODE_ALWAYS
	area.monitoring = false
	_init_transform = view_model.transform
	_toggle_process_mode()
	if not is_equipped:
		_bob_time += (global_position.x + global_position.z) / 10
	_allow_animations = true

func pick_up(new_user: Node3D):
	if not new_user:
		drop()
		return
	if _user:
		print(str(self) + " already has user " + str(_user))
		return
	_user = new_user
	is_equipped = true
	area_col.disabled = true
	_toggle_process_mode()
	transform = Transform3D.IDENTITY.scaled_local(Vector3.ONE * view_model_scale)
	_reset_bob()

func drop():
	_user = null
	is_equipped = false
	area_col.disabled = false
	_toggle_process_mode()
	transform.basis = _init_transform.basis
	play_drop()

func is_same(item: Item):
	if not item:
		return false
	return scene_file_path == item.scene_file_path

# kinda shit
func in_animation():
	for child in get_children():
		var ap = child as AnimationPlayer
		if not ap:
			continue
		if ap.is_playing():
			return true
	return false

## THIS IS CONFUSING AND TERRIBLE; MAKE AN ACTION SYSTEM
# TODO: add 3 different animation functions
# 1. await player
# 2. player that takes into account if animation is playing
# 3. normal player

func play_collect():
	Audio.play_sound(pickup_sound)
	if not base_anim_player.has_animation("collect"):
		return
	base_anim_player.play("collect")
	await base_anim_player.animation_finished
	base_anim_player.play("RESET")
	base_anim_player.advance(0)

func play_added():
	Audio.play_sound(drop_sound)
	if not base_anim_player.has_animation("added"):
		return
	base_anim_player.play("added")

func play_removed():
	Audio.play_sound(pickup_sound)
	if not base_anim_player.has_animation("removed"):
		return
	base_anim_player.play("removed")

func play_drop():
	Audio.play_sound(drop_sound)
	if not base_anim_player.has_animation("drop"):
		return
	base_anim_player.play("drop")

func play_inspect():
	if in_animation():
		return
	if not base_anim_player.has_animation("inspect"):
		return
	base_anim_player.play("inspect")
	
func _toggle_process_mode() -> void:
	set_process(not is_equipped)
	set_process_unhandled_input(is_equipped)

func _unhandled_input(event):
	if event.is_echo():
		return
	if event.is_action_pressed("inspect"):
		play_inspect()

## Dropped functionality
	
func _process(delta) -> void:
	_bob(delta)

func _reset_bob():
	_bob_time = 0
	view_model.transform = _init_transform
	view_model.rotation.y = 0

func _bob(delta):
	_bob_time += delta
	view_model.transform.origin = _init_transform.origin + Vector3(0, (sin(_bob_time) + 1) * 0.1, 0)
	view_model.rotate_y(delta)
