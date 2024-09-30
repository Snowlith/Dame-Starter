extends Node3D

@onready var area: Area3D = $Area3D
var ladder_normal = Vector2(0, 1)

var entities: Array[Entity]

# Called when the node enters the scene tree for the first time.
func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D):
	var entity = body.get_parent() as Entity
	if not entity:
		return
	var ladder_state = entity.get_component("LadderState")
	if not ladder_state:
		return
	ladder_state.enter_ladder(self, ladder_normal)
	entities.append(entity)

func _on_body_exited(body: Node3D):
	var entity = body.get_parent() as Entity
	if not entity:
		return
	var found = entities.find(entity)
	if found != -1:
		entity.get_component("LadderState").exit_ladder()
		entities.remove_at(found)
