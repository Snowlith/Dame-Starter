extends Node3D
class_name Entity

var components: Dictionary

var _physics_body: PhysicsBody3D

func _ready():
	for c in find_children("", "Component"):
		components[get_component_name(c)] = c
	var bodies = find_children("", "PhysicsBody3D")
	if not bodies.is_empty():
		_physics_body = bodies[0]
		_physics_body.top_level = true

func get_component(c_name: String) -> Component:
	if components.has(c_name):
		return components[c_name]
	return null

func has_component(c_name: String) -> bool:
	return components.has(c_name)

func get_component_name(c: Component):
	var default = c.script.get_global_name()
	if not default:
		return c.script.get_base_script().get_global_name()
	return default

func _physics_process(delta):
	if global_transform != _physics_body.global_transform:
		global_transform = _physics_body.global_transform
