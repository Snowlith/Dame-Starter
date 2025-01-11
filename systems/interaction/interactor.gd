extends Component
class_name Interactor

@export_flags_3d_physics var interactable_layers: int = 0b00000000_00000000_00000000_00000100

@onready var ray_cast: RayCast3D = $RayCast3D

var _enabled: bool = true

var _hovered_entity: Entity
var _hovered_input_actions: Dictionary

var _locked: bool = false

signal entity_changed(entity: Entity)
signal interactable_added(interactable: Interactable)
signal interactable_updated(interactable: Interactable)

# TODO: is_active needs some work

# TODO: interaction_cooldown

func _ready():
	ray_cast.add_exception(get_parent_entity().get_physics_body())
	ray_cast.enabled = true

func _unhandled_input(event):
	if event.is_echo():
		return
	if not _enabled:
		return
	for input_action in _hovered_input_actions.keys():
		if event.is_action_pressed(input_action):
			for interactable in _hovered_input_actions[input_action]:
				print(interactable)
				if not interactable.is_active:
					continue
				interactable.interact(self)
			get_viewport().set_input_as_handled()

func is_on_interactable_layer(col_obj: CollisionObject3D) -> bool:
	return (col_obj.collision_layer & interactable_layers) != 0

func _physics_process(delta):
	if _locked:
		return
	var target_entity = ray_cast.get_collider() as Entity
	if _hovered_entity:
		# same entity
		if target_entity == _hovered_entity:
			return
			
		_hovered_entity = null
		_hovered_input_actions.clear()
		entity_changed.emit(null)
		
	if not target_entity or not is_on_interactable_layer(target_entity):
		return
	var interactables = target_entity.get_components(Interactable)
	if interactables.is_empty():
		return
	_hovered_entity = target_entity
	entity_changed.emit(_hovered_entity)
	
	for interactable: Interactable in interactables:
		if not interactable:
			continue
		var input_action = interactable.input_action
		if _hovered_input_actions.has(input_action):
			_hovered_input_actions[input_action].append(interactable)
		else:
			_hovered_input_actions[input_action] = [interactable]
			interactable_added.emit(interactable)

func get_pos_along_ray(distance: float):
	return ray_cast.global_position - ray_cast.global_basis.z * distance

func start_entity_lock():
	_locked = true

func end_entity_lock():
	_locked = false

func is_entity_locked():
	return _locked
#
#func enable():
	#_enabled = true
	#ray_cast.enabled = true
	#print("enabled")
#
#func disable():
	#_enabled = false
	#ray_cast.enabled = false
	#print("disabled")

#func Get_Look_Direction() -> Vector3:
	#var viewport = get_viewport().get_visible_rect().size
	#var camera = get_viewport().get_camera_3d()
	#return camera.project_ray_normal(viewport/2)
