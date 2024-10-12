extends PhysicsBody3D
class_name Entity

var components: Dictionary

var _cached_typed_components: Dictionary

@onready var _all_components: Array[Component] = _find_components(self, "Component")

# TODO: rewrite as get_components when typed dicts come

func _ready():
	_register_components(_all_components)

func get_component(c_name: String) -> Component:
	if components.has(c_name):
		return components[c_name]
	return null

func get_components_of_type(t_name: String) -> Array[Component]:
	if _cached_typed_components.has(t_name):
		return _cached_typed_components[t_name]
	var filtered = _find_components(self, t_name)
	_cached_typed_components[t_name] = filtered
	return filtered

func has_component(c_name: String) -> bool:
	return components.has(c_name)
	
func _find_components(node: Node, t_name: String) -> Array[Component]:
	var result: Array[Component] = []
	result.append_array(node.find_children("", t_name, false))
	for child in node.get_children():
		if child is Entity:
			continue
		result.append_array(_find_components(child, t_name))
	return result

func _register_components(to_register: Array[Component]) -> void:
	for component in to_register:
		var c_name = _get_component_name(component)
		if components.has(c_name):
			push_error("Duplicate component " + str(component) + " at " + str(self))
		else:
			components[c_name] = component

func _get_component_name(c: Component):
	var default = c.script.get_global_name()
	if not default:
		return c.script.get_base_script().get_global_name()
	return default
