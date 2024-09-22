extends Inventory

@export var open_sound: AudioStream
@export var close_sound: AudioStream

@onready var collect_area: Area3D = $Area3D
@onready var nine_patch_rect: Control = $NinePatchRect
@onready var hand_slot: Slot = $NinePatchRect/HandSlot
@onready var drop_slot: Slot = $ColorRect
@onready var context_menu: Control = $ContextMenu

var disabled_actions: Array[String] = ["jump", "crouch", "sprint", "left", "right", "up", "down", "inspect"]

# TODO: instead of can_insert, return amount that can be inserted, or just see how many were inserted
# TODO: add collect notification
# TODO: adding items through editor -> make slots export item

var is_open = true:
	set(value):
		if is_open == value:
			return
		
		is_open = value
		nine_patch_rect.visible = is_open
		drop_slot.visible = is_open
		
		if is_open:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Audio.play_sound(open_sound)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Audio.play_sound(close_sound)
			context_menu.close()

func _ready() -> void:
	for slot: Slot in get_tree().get_nodes_in_group("inventory slot"):
		if not slot:
			continue
		slots.append(slot)
	size = slots.size()
	
	get_initial_items()
	
	collect_area.area_entered.connect(_on_area_entered)
	
	is_open = false

func _on_area_entered(area: Area3D):
	var item := area.get_parent_node_3d() as Item
	if not item:
		return
	collect(item)

func _input(event: InputEvent):
	if event.is_action_pressed("inventory") and not event.is_echo():
		is_open = not is_open
	if is_open:
		for action in disabled_actions:
			if event.is_action_pressed(action):
				get_viewport().set_input_as_handled()
				return
