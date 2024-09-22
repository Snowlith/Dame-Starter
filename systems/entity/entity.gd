extends PhysicsBody3D
class_name Entity

var attributes: Dictionary
var components: Dictionary

func _ready():
	for attribute in find_children("", "Attribute"):
		attributes[attribute.script.get_global_name()] = attribute
	for component in find_children("", "Component"):
		components[get_component_name(component)] = component

func get_attribute(attr_name: String) -> Attribute:
	if attributes.has(attr_name):
		return attributes[attr_name]
	return null

func has_attribute(attr_name: String) -> bool:
	return attributes.has(attr_name)

func get_component(comp_name: String) -> Component:
	if components.has(comp_name):
		return components[comp_name]
	return null

func has_component(comp_name: String) -> bool:
	return components.has(comp_name)

func get_component_name(comp: Component):
	var default = comp.script.get_global_name()
	if not default:
		return comp.script.get_base_script().get_global_name()
	return default
