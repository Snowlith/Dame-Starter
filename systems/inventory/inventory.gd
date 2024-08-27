extends Area3D

class_name Inventory

@export var size: int = 12
@export var items: Array[Item]

@export var slot_scene: PackedScene

@onready var nine_patch_rect: Control = $NinePatchRect
@onready var slot_container: Control = $NinePatchRect/SlotContainer


var is_open = false

func insert(item: Item):
	print(item)
	var index = items.find(null)
	if (index == -1):
		return
	items[index] = item
	update_ui()
	
func _ready() -> void:
	clear()
	create_ui()
	update_ui()
	close()
	
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area3D):
	var dropped_item := area as DroppedItem
	if not dropped_item:
		return
	insert(dropped_item.item)
	print(items)
	dropped_item.despawn()

func update_ui():
	var ui_slots: Array = slot_container.get_children()
	for i in range (size):
		print(i)
		var item = items[i]
		var slot = ui_slots[i]
		slot.update(item)
		
	
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
		var itemCell = slot_scene.instantiate()
		slot_container.add_child(itemCell)

func clear():
	items.clear()
	for i in range (size):
		items.append(null)
		
	print(items)
		
