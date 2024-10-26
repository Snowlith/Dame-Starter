extends SlotUI
class_name StandardSlotUI

@onready var interface: SlotUIInterface = $SlotUIInterface
@onready var drag_drop: SlotUIDragDrop = $SlotUIDragDrop
@onready var button: Control = $Button

func _set_slot(new_slot):
	if slot == new_slot:
		return
	interface.disconnect_slot_signals(slot)
	slot = new_slot
	interface.connect_slot_signals(slot)
	interface.refresh(slot)

func _ready():
	drag_drop.set_drag_data_callable(_on_drag_requested)
	drag_drop.set_drop_validation_callable(_on_drop_requested)
	
	drag_drop.dropped.connect(_on_dropped)
	button.pressed.connect(_on_pressed)

func _on_pressed():
	if not slot.item:
		return
	context_menu_requested.emit()

func register_context_actions():
	context_action_registered.emit("Take one", func(): 
		drag_drop.drag({"slot": slot, "amount": 1}))
		
	context_action_registered.emit("Take half", func(): 
		drag_drop.drag({"slot": slot, "amount": ceil(float(slot.amount) / 2)}))

func _on_drag_requested():
	if not slot.item:
		return null
	var data = {
		"slot": slot,
		"amount": slot.amount
	}
	return data

func _on_drop_requested(data: Dictionary):
	var has_source_slot = data.has("slot")
	var has_desired_amount = data.has("amount")
	
	return has_source_slot and has_desired_amount

func _on_dropped(data):
	var source_slot = data["slot"] as Slot
	var desired_amount = data["amount"] as int
	
	slot.exchange_with(source_slot, desired_amount)
