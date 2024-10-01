extends Node3D
class_name Entity

var components: Dictionary
var physics_body: PhysicsBody3D

func _ready():
	for c in find_children("", "Component"):
		components[_get_component_name(c)] = c
	var bodies = find_children("", "PhysicsBody3D")
	if not bodies.is_empty():
		physics_body = bodies[0]
		physics_body.top_level = true

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
