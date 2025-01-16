extends Toggleable
class_name InventoryAccess

@onready var own_inventory: Inventory = get_parent_entity().get_component(Inventory)

var _last_interactor: Interactor
#TODO: open external inventories with this

# todo: try to turn this into a proper toggleable, oculd avoid the container entity

func interact(interactor: Interactor):
	if not own_inventory:
		return
	super(interactor)
	
	if toggled:
		_last_interactor = interactor
		var entity: Entity = interactor.get_parent_entity()
		var inventory: Inventory = entity.get_component(Inventory)
		if not inventory:
			return
		inventory.open_external(own_inventory, close_callable)
	else:
		_last_interactor = null

func close_callable():
	_last_interactor.emulate_interaction(get_parent_entity())
