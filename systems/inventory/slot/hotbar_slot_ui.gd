extends SlotUI
class_name HotbarSlotUI

@onready var interface: SlotUIInterface = $SlotUIInterface

func _set_slot(new_slot):
	if slot == new_slot:
		return
	interface.disconnect_slot_signals(slot)
	slot = new_slot
	interface.connect_slot_signals(slot)
	interface.refresh(slot)
