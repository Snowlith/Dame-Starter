extends SlotUI
class_name HotbarSlotUI

@onready var interface: SlotUIInterface = $SlotUIInterface
@onready var input_icon = $InputIcon

func _set_slot(new_slot):
	if slot == new_slot:
		return
	interface.disconnect_slot_signals(slot)
	slot = new_slot
	interface.connect_slot_signals(slot)
	interface.refresh(slot)

func set_input_icon_action(action):
	input_icon.input_action = action
