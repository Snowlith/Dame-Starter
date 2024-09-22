extends RangeValue
class_name Health

@onready var inventory = $"../Inventory"

func _ready():
	depleted.connect(_on_depleted)

func _on_depleted():
	inventory.drop_all()
	get_parent().queue_free()
