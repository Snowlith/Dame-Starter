extends StaticBody3D

@export var key: PackedScene
@onready var area: Area3D = $Area3D

var key_item: Item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	key_item = key.instantiate() as Item

#func _on_body_entered(body: Node3D):
	#if not key_item:
		#return
	#var children = body.get_children()
	#var inventory: Inventory
	#for child in children:
		#if child is Inventory:
			#inventory = child
			#break
	#if not inventory:
		#return
	#if inventory.has(key_item):
		#inventory.remove(key_item)
		#queue_free()

func _on_body_entered(body: Node3D):
	if not key_item:
		return
	var player = body as Entity
	if not player or not player.is_in_group("player"):
		return
	var inventory = player.components["Inventory"]
	if inventory.has(key_item):
		inventory.remove(key_item)
		queue_free()
