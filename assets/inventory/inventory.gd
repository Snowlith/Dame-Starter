extends Area3D

class_name Inventory

signal update

var is_open = false

@export var slots: Array[InventorySlot]
@onready var ui_slots: Array = $NinePatchRect/GridContainer.get_children()
@onready var ui: Control = $NinePatchRect



func insert(item: Item):
	print(item)
	var itemslots = slots.filter(func(slot): return slot.item == item)
	if not itemslots.is_empty():
		itemslots[0].amount += 1
	else:
		var emptyslots = slots.filter(func(slot): return slot.item == null)
		if !emptyslots.is_empty():
			emptyslots[0].item = item
			emptyslots[0].amount = 1
	update.emit()
	
func _ready() -> void:
	close()
	ui.visible = false
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area3D):
	var dropped_item:= area as DroppedItem
	if not dropped_item:
		return
	insert(dropped_item.item)
	dropped_item.despawn()

func update_ui():
	for i in range(min(ui_slots.size(), slots.size())):
		ui_slots[i].update(slots[i])
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			close()
		else:
			open()

func open():
	ui.visible = true
	is_open = true

func close():
	ui.visible = false
	is_open = false
