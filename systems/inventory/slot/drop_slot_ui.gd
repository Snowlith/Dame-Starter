extends SlotUI
class_name DropSlotUI

@export var user: Entity
@export var user_camera: Camera3D

@export var throw_strength: float = 10
@export var hotbar_ui: HotbarUI

const DROPPED_ITEM_PACKED = preload("res://systems/inventory/item/dropped_item.tscn")

@onready var drag_drop: SlotUIDragDrop = $SlotUIDragDrop

func _ready():
	slot = Slot.new()
	
	drag_drop.set_drop_validation_callable(_on_drop_requested)
	drag_drop.dropped.connect(_on_dropped)

func _unhandled_key_input(event):
	if event.is_echo():
		return
	if event.is_action_pressed("drop"):
		var dropping_shit_slot = hotbar_ui.hotbar[hotbar_ui.selected_slot_index].slot
		if dropping_shit_slot.is_empty():
			return
		_on_dropped({"slot": dropping_shit_slot, "amount": 1})

func _on_drop_requested(data: Dictionary):
	var has_source_slot = data.has("slot")
	var has_desired_amount = data.has("amount")
	
	return has_source_slot and has_desired_amount
	
func _on_dropped(data):
	var source_slot = data["slot"] as Slot
	var desired_amount = data["amount"] as int
	
	var dropped_item = DROPPED_ITEM_PACKED.instantiate() as DroppedItem
	if not dropped_item:
		return
	var dropped_item_slot = Slot.new()
	dropped_item_slot.item = source_slot.item
	dropped_item_slot.amount = desired_amount
	dropped_item_slot.cached_viewmodel = source_slot.cached_viewmodel
	
	dropped_item.slot = dropped_item_slot
	get_tree().current_scene.add_child(dropped_item)
	
	dropped_item.global_position = user_camera.global_position-user_camera.global_basis.z
	dropped_item.throw(-user_camera.global_basis.z * throw_strength, [user])
		
	slot.exchange_with(source_slot, desired_amount)
	slot.amount = 0
