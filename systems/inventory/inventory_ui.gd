extends MenuUI
class_name InventoryUI

@export var inventory: Inventory

@onready var hotbar_ui = $DontInheritVisibility/HotbarUI
@onready var backpack_grid_ui = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/BackpackGridUI
@onready var external_grid_ui = $HBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/ExternalGridUI

# TODO: when pressing number keys, switch with hotbar ui
# TODO: block hotbar actions when menu open


# TODO: click instead of drag to move items 

var _is_external_loaded: bool = false

func _ready():
	super()
	inventory.inventory_loaded.connect(_on_inventory_loaded)
	inventory.external_inventory_loaded.connect(_on_external_inventory_loaded)
	inventory.external_inventory_closed.connect(_on_external_inventory_closed)

func _input(event):
	super(event)
	
	# THIS IS NECESSARY
	#for i in range(0, 6, 1):
			#if Input.is_action_just_pressed("hotbar_"+str(i+1)):
				#var hovered = inventory_ui.get_hovered_slot_ui()
				#if hovered:
					#var target = hotbar[i].slot
					#target.swap_with(hovered.slot)
					#return
				#previous_slot_ui = hotbar[selected_slot_index]
				#selected_slot_index = i
				#selected_slot_ui = hotbar[selected_slot_index]
				#_selected_slot_changed()
				#return
				
func _on_inventory_loaded():
	print("hello")
	backpack_grid_ui.create_slots(inventory)
	hotbar_ui.create_slots(inventory)

func _on_external_inventory_loaded(external_inventory: Inventory):
	external_grid_ui.create_slots(external_inventory)
	open()
	_is_external_loaded = true

func _on_external_inventory_closed():
	close()

func close():
	super()
	if _is_external_loaded:
		external_grid_ui.clear_slots()
