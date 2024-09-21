extends Component
class_name InventoryGetter

var inventory: Inventory

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(get_parent() is Inventory)
	inventory = get_parent()
