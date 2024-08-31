extends Area3D

class_name Inventory

@export var items: Array[Item]
@export var view_model: MeshInstance3D

@onready var hand_slot: Slot = $NinePatchRect/HandSlot
@onready var nine_patch_rect: Control = $NinePatchRect

var slots: Array[Slot]
var size: int

var is_open = false

const SLOT = "inv_slot"

# TODO: add item stacks
	
func _ready() -> void:
	close()
	# Gets too wide scene tree
	for slot: Slot in get_tree().get_nodes_in_group(SLOT):
		if not slot:
			continue
		slots.append(slot)
	size = slots.size()
	
	items.resize(size)
	_update()
	
	for slot in slots:
		slot.item_dropped.connect(switch_slots)
	hand_slot.item_changed.connect(update_hand)
	
	area_entered.connect(_on_area_entered)
	
	print(hand_slot)

func has_item(item: Item):
	if not item:
		return false
	return item in items
	
func insert(item: Item):
	var index = items.find(null)
	if (index == -1):
		return
	items[index] = item
	_update()
	
func _on_area_entered(area: Area3D):
	var dropped_item := area as DroppedItem
	if not dropped_item:
		return
	insert(dropped_item.item)
	dropped_item.despawn()

func _update():
	for i in slots.size():
		var slot: Slot = slots[i]
		if not slot:
			continue
		slot.update(items[i])
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			close()
		else:
			open()

func update_hand():
	if not view_model:
		return
	if hand_slot.current_item:
		print(hand_slot)
		view_model.mesh = hand_slot.current_item.mesh
	else:
		view_model.mesh = null

func open():
	SceneManager.in_menu = true
	nine_patch_rect.visible = true
	is_open = true

func close():
	SceneManager.in_menu = false
	nine_patch_rect.visible = false
	is_open = false

func switch_slots(slot_1, slot_2):
	var index_1 = slots.find(slot_1)
	var index_2 = slots.find(slot_2)
	var temp = slot_1.current_item
	slot_1.update(slot_2.current_item)
	slot_2.update(temp)
	
	items[index_1] = slot_1.current_item
	items[index_2] = slot_2.current_item
