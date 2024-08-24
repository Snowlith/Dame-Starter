extends Area3D

class_name Inventory

@export var size: int = 12
@export var slots: Array[InventorySlot]

@export var bg_scene: PackedScene
@export var slot_scene: PackedScene

@onready var nine_patch_rect: Control = $NinePatchRect
@onready var bg_container: Control = $NinePatchRect/BGContainer
@onready var slot_container: Control = $NinePatchRect/SlotContainer

var is_open = false

func insert(item: Item):
	print(item)
	var occupied_slots = slots.filter(func(slot): return slot.item == item)
	if not occupied_slots.is_empty():
		occupied_slots[0].amount += 1
	else:
		var empty_slots = slots.filter(func(slot): return slot.item == null)
		if not empty_slots.is_empty():
			empty_slots[0].item = item
			empty_slots[0].amount = 1
	update_ui()
	
func _ready() -> void:
	create_ui()
	update_ui()
	close()
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area3D):
	var dropped_item := area as DroppedItem
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
			close()
		else:
			open()

func open():
	SceneManager.in_menu = true
	nine_patch_rect.visible = true
	is_open = true

func close():
	SceneManager.in_menu = false
	nine_patch_rect.visible = false
	is_open = false
	
func create_ui():
	for i in range(size):
		var cell = bg_scene.instantiate()
		bg_container.add_child(cell)
		
		
	
