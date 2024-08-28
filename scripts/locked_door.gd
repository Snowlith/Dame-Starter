extends Area3D

@export var key_item: Item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node3D):
	var children = body.get_children()
	var inventory: Inventory
	for child in children:
		if child is Inventory:
			inventory = child
	if inventory.has_item(key_item):
		get_parent().queue_free()
