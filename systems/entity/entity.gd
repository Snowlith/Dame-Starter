extends CharacterBody3D
class_name Entity

var attributes: Dictionary
var components: Dictionary

func _ready():
	for attribute in find_children("", "Attribute"):
		attributes[attribute.script.get_global_name()] = attribute
	for component in find_children("", "Component"):
		components[component.script.get_global_name()] = component

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




#func _ready():
	#var shit_cam = get_component(Camera3D)
	#print("Found: " + str(shit_cam))
	#print(get_component(Sprint))
#
#func get_component(type: Variant):
	#var children = find_children("", type.get_global_name())
	#if children.is_empty():
		#return null
	#return children[0]
