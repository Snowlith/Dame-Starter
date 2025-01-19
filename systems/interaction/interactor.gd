extends Component
class_name Interactor

@export_flags_3d_physics var interactable_layers: int = 0b00000000_00000000_00000000_00000100

@onready var ray_cast: RayCast3D = $RayCast3D

var hovered_entity: Entity
var hovered_interactables: Dictionary

var is_entity_locked: bool = false

signal hovered_interactables_updated(hovered_interactables: Dictionary)

# TODO: interaction_cooldown

func _ready():
	ray_cast.add_exception(get_parent_entity().get_physics_body())
	ray_cast.enabled = true

func is_on_interactable_layer(col_obj: CollisionObject3D) -> bool:
	return (col_obj.collision_layer & interactable_layers) != 0

func get_pos_along_ray(distance: float):
	return ray_cast.global_position - ray_cast.global_basis.z * distance

func start_entity_lock():
	is_entity_locked = true

func end_entity_lock():
	is_entity_locked = false

func emulate_interaction(target_entity: Entity):
	var interactables = target_entity.get_components(Interactable)
	if interactables.is_empty():
		return
	for interactable: Interactable in interactables:
		if not interactable or not interactable.is_active:
			continue
		interactable.interact(self)

func _unhandled_input(event):
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event.is_echo():
		return
	for input_action in hovered_interactables.keys():
		if event.is_action_pressed(input_action):
			for interactable in hovered_interactables[input_action]:
				interactable.interact(self)
			get_viewport().set_input_as_handled()

func _physics_process(delta):
	if is_entity_locked:
		return
	var target_entity = ray_cast.get_collider() as Entity
	if hovered_entity:
		# same entity
		if target_entity == hovered_entity:
			return
			
		_clear_hovered_interactables()
		
	if not target_entity or not is_on_interactable_layer(target_entity):
		return
	var interactables = target_entity.get_components(Interactable)
	if interactables.is_empty():
		return
	hovered_entity = target_entity
	
	_update_hovered_interactables()
	#print(hovered_interactables)

func _update_hovered_interactables():
	for interactable_list in hovered_interactables.values():
		for interactable in interactable_list:
			interactable.is_active_changed.disconnect(_on_interactable_active_changed)

	hovered_interactables.clear()
	
	var interactables = hovered_entity.get_components(Interactable)
	
	for interactable: Interactable in interactables:
		# This might cause issues, idk
		if not interactable.is_active_changed.is_connected(_on_interactable_active_changed):
			interactable.is_active_changed.connect(_on_interactable_active_changed.bind(interactable))
		
		if not interactable.is_active:
			continue
			
		var input_action = interactable.input_action
		if hovered_interactables.has(input_action):
			hovered_interactables[input_action].append(interactable)
		else:
			hovered_interactables[input_action] = [interactable]
			
	hovered_interactables_updated.emit(hovered_interactables)

func _on_interactable_active_changed(is_active: bool, interactable: Interactable):
	if not hovered_entity or not interactable:
		return
	
	var input_action = interactable.input_action
	if is_active:
		if hovered_interactables.has(input_action):
			hovered_interactables[input_action].append(interactable)
		else:
			hovered_interactables[input_action] = [interactable]
	else:
		if hovered_interactables.has(input_action):
			hovered_interactables[input_action].erase(interactable)
			
			if hovered_interactables[input_action].is_empty():
				hovered_interactables.erase(input_action)
	
	hovered_interactables_updated.emit(hovered_interactables)

func _clear_hovered_interactables():
	for interactable_list in hovered_interactables.values():
		for interactable in interactable_list:
			interactable.is_active_changed.disconnect(_on_interactable_active_changed)
			
	hovered_interactables.clear()
	hovered_entity = null
	hovered_interactables_updated.emit(hovered_interactables)
