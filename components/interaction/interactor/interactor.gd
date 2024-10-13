extends Component
class_name Interactor

@onready var ray_cast: RayCast3D = $RayCast3D

var _enabled: bool = true

# TODO: add cooldown after interacting and dropping carryable

func _ready():
	var parent = get_parent_entity()
	if parent:
		ray_cast.add_exception(parent)
	ray_cast.enabled = false

func _unhandled_key_input(event):
	if event.is_echo():
		return
	if not _enabled:
		return
	if event.is_action_pressed("interact"):
		#print("interacted")
		
		ray_cast.enabled = true
		ray_cast.force_raycast_update()
		var target_entity = ray_cast.get_collider() as Entity
		#print(target_entity)
		ray_cast.enabled = false
		if not target_entity:
			return
		start_interaction(target_entity)
		get_viewport().set_input_as_handled()

func get_pos_along_ray(distance: float):
	return ray_cast.global_position - ray_cast.global_transform.basis.z * distance

func start_interaction(entity: Entity):
	for interactable: Interactable in entity.get_components_of_type("Interactable"):
		if not is_instance_valid(interactable):
			continue
		interactable.interact(self)

func enable():
	_enabled = true

func disable():
	_enabled = false

###
func apply_cooldown():
	pass
		

#func Get_Look_Direction() -> Vector3:
	#var viewport = get_viewport().get_visible_rect().size
	#var camera = get_viewport().get_camera_3d()
	#return camera.project_ray_normal(viewport/2)
