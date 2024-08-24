extends Area3D

class_name Inventory


var is_open = false
@onready var bg_container: Control = $NinePatchRect/BGContainer
@onready var slot_container: Control = $NinePatchRect/SlotContainer
@export var cell_number: int = 12
@export var slots: Array[InventorySlot]
@export var bg: PackedScene
@export var slot: PackedScene
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
	update_ui()
	
func _ready() -> void:
	create_ui()
	update_ui()
	close()
	ui.visible = false
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area3D):
	var dropped_item:= area as DroppedItem
	if not dropped_item:
		return
	insert(dropped_item.item)
	print(slots)
	dropped_item.despawn()

func update_ui():
	var ui_slots: Array = slot_container.get_children()
	for i in range(min(ui_slots.size(), slots.size())):
		ui_slots[i].update(slots[i])
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			SceneManager.in_menu = false
			close()
		else:
			SceneManager.in_menu = true
			open()

func open():
	ui.visible = true
	is_open = true

func close():
	ui.visible = false
	is_open = false
	
func create_ui():
	for i in range(cell_number):
		var cell = bg.instantiate()
		bg_container.add_child(cell)
		
		
	
