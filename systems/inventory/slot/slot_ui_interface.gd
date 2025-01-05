extends Control
class_name SlotUIInterface

@onready var margin_container: Control = $MarginContainer
@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var amount_label: Label = $AmountLabel

# TODO: add an optional dragdrop export to hide image when starting drag

func _ready():
	mouse_filter = MOUSE_FILTER_IGNORE
	margin_container.mouse_filter = MOUSE_FILTER_IGNORE
	texture_rect.mouse_filter = MOUSE_FILTER_IGNORE

func refresh(slot: Slot):
	refresh_amount(slot)
	refresh_texture(slot)

func refresh_texture(slot: Slot):
	if slot.item:
		texture_rect.texture = slot.item.icon
		texture_rect.show()
	else:
		texture_rect.texture = null
		texture_rect.hide()

func refresh_amount(slot: Slot):
	if slot.item and slot.item.stack_size > 1:
		amount_label.show()
		amount_label.text = str(slot.amount)
	else:
		amount_label.hide()

func connect_slot_signals(slot: Slot):
	if slot:
		slot.item_changed.connect(refresh_texture.bind(slot))
		slot.amount_changed.connect(refresh_amount.bind(slot))

func disconnect_slot_signals(slot: Slot):
	if slot:
		slot.item_changed.disconnect(refresh_texture)
		slot.amount_changed.disconnect(refresh_amount)
