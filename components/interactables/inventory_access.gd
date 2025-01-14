extends Interactable
class_name InventoryAccess

@onready var own_inventory = get_parent_entity().get_component(Inventory)

@export var entities_to_interact: Array[Entity]

#TODO: open external inventories with this

func interact(interactor: Interactor):
	if not own_inventory:
		return
	var entity: Entity = interactor.get_parent_entity()
	var inventory: Inventory = entity.get_component(Inventory)
	if not inventory:
		return
	inventory.open_external(own_inventory)
	for triggered_entity in entities_to_interact:
		var interactables = triggered_entity.get_components(Interactable)
		for interactable: Interactable in interactables:
			interactable.interact(interactor)
