extends Area3D

class_name Inventory

@export var size: int = 12
@export var items: Array[Item]

@export var slot_scene: PackedScene

@onready var nine_patch_rect: Control = $NinePatchRect
@onready var slot_container: Control = $NinePatchRect/SlotContainer


var is_open = false

func insert(item: Item):
	var index = items.find(null)
	if (index == -1):
		return
	items[index] = item
	update_ui()
	
func _ready() -> void:
	add_nulls()
	
	create_ui()
	update_ui()
	close()
	
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area3D):
	var dropped_item := area as DroppedItem
	if not dropped_item:
		return
	insert(dropped_item.item)
	dropped_item.despawn()

func update_ui():
	var ui_slots: Array = slot_container.get_children()
	for i in range(size):
		ui_slots[i].update(items[i])
	
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
		var item_cell = slot_scene.instantiate()
		item_cell.current_inventory = self
		slot_container.add_child(item_cell)

func clear():
	items.clear()
	for i in range(size):
		items.append(null)

func add_nulls():
	for i in range(size - items.size()):
		items.append(null)

func switch_slots(slot_1, slot_2):
	var ui_slots: Array = slot_container.get_children()
	var index_1 = ui_slots.find(slot_1)
	var index_2 = ui_slots.find(slot_2)
	var temp = slot_1.current_item
	slot_1.update(slot_2.current_item)
	slot_2.update(temp)
	
	items[index_1] = slot_1.current_item
	items[index_2] = slot_2.current_item
