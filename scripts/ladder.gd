extends Node3D

@onready var area: Area3D = $Area3D
var ladder_normal = Vector2(0, 1)

var entities: Array[Entity]

# Called when the node enters the scene tree for the first time.
func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D):
	var entity = body as Entity
	if not entity:
		return
	var ladder_handler = entity.get_component("LadderHandler")
	if not ladder_handler:
		return
	ladder_handler.entered(self, ladder_normal)
	entities.append(entity)

func _on_body_exited(body: Node3D):
	var entity = body as Entity
	if not entity:
		return
	var found = entities.find(entity)
	if found != -1:
		entity.get_component("LadderHandler").exited()
		entities.remove_at(found)
