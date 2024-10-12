extends Node3D
class_name Entity

@export var physics_body: PhysicsBody3D
var components: Dictionary

var _cached_typed_components: Dictionary

func _ready():
	for c in find_children("", "Component"):
		var c_name = _get_component_name(c)
		if components.has(c_name):
			push_error("Duplicate component " + str(c) + " at " + str(self))
			continue
		components[c_name] = c
	physics_body.top_level = true

func get_components_of_type(t_name: String) -> Array[Component]:
	if _cached_typed_components.has(t_name):
		return _cached_typed_components[t_name]
	var array: Array[Component] = []
	for c in find_children("", t_name):
		array.append(c)
	_cached_typed_components[t_name] = array
	return array

func get_component(c_name: String) -> Component:
	if components.has(c_name):
		return components[c_name]
	return null

func has_component(c_name: String) -> bool:
	return components.has(c_name)

func _get_component_name(c: Component):
	var default = c.script.get_global_name()
	if not default:
		return c.script.get_base_script().get_global_name()
	return default
	
func _physics_process(delta):
	if not is_instance_valid(physics_body):
		return
	if global_transform != physics_body.global_transform:
		global_transform = physics_body.global_transform

func get_physics_body():
	return physics_body
