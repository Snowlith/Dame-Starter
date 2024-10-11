extends Area3D

var entities: Array[Entity]

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D):
	var entity = body.get_parent() as Entity
	if not entity:
		return
	var water_state = entity.get_component("WaterState")
	if not water_state:
		return
	if water_state.enter_water(self):
		entities.append(entity)

func _on_body_exited(body: Node3D):
	var entity = body.get_parent() as Entity
	if not entity:
		return
	var found = entities.find(entity)
	if found != -1:
		entity.get_component("WaterState").exit_water()
		entities.remove_at(found)
