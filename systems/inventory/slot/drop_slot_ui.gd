extends SlotUI
class_name DropSlotUI

var _dropped_scene = preload("res://systems/inventory/item/dropped_item.tscn")

@onready var drag_drop: SlotUIDragDrop = $SlotUIDragDrop

func _ready():
	slot = Slot.new()
	slot.capacity = 100000000
	
	drag_drop.set_drop_validation_callable(_on_drop_requested)
	drag_drop.dropped.connect(_on_dropped)

func _on_drop_requested(data: Dictionary):
	var has_source_slot = data.has("slot")
	var has_desired_amount = data.has("amount")
	
	return has_source_slot and has_desired_amount
	
func _on_dropped(data):
	var source_slot = data["slot"] as Slot
	var desired_amount = data["amount"] as int
	
	var dropped = _dropped_scene.instantiate() as DroppedItem
	if not dropped:
		return
	var dropped_slot = Slot.new()
	dropped_slot.item = source_slot.item #.duplicate()
	dropped_slot.amount = desired_amount
	
	dropped.slot = dropped_slot
	get_tree().current_scene.add_child(dropped)
	
	var cam = get_viewport().get_camera_3d()
	dropped.global_position = cam.global_position - cam.global_basis.z * 3
	print(cam.global_basis.z)
		
	slot.exchange_with(source_slot, desired_amount)
	slot.amount = 0
