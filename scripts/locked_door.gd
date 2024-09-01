extends StaticBody3D

@export var key_item: Item
@onready var area: Area3D = $Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	var children = body.get_children()
	var inventory: Inventory
	for child in children:
		if child is Inventory:
			inventory = child
	if inventory.has(key_item):
		inventory.remove(key_item)
		queue_free()
