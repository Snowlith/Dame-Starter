extends Component
class_name Interactor

@export_flags_3d_physics var interactable_layers: int = 0b00000000_00000000_00000000_00000010

@onready var ray_cast: RayCast3D = $RayCast3D
@onready var panel: Control = $Panel
@onready var label: Label = $Panel/Label

var _enabled: bool = true

# TODO: add cooldown after interacting and dropping carryable

func _ready():
	ray_cast.add_exception(get_parent_entity() as PhysicsBody3D)
	ray_cast.enabled = true
	panel.hide()

func _unhandled_key_input(event):
	if event.is_echo():
		return
	if not _enabled:
		return
	if event.is_action_pressed("interact"):
		ray_cast.force_raycast_update()
		var target_entity = ray_cast.get_collider() as Entity
		if not target_entity or not is_on_interactable_layer(target_entity):
			return
		start_interaction(target_entity)
		get_viewport().set_input_as_handled()

func is_on_interactable_layer(col_obj: CollisionObject3D) -> bool:
	return (col_obj.collision_layer & interactable_layers) != 0

func _physics_process(delta):
	var target_entity = ray_cast.get_collider() as Entity
	if not target_entity or not is_on_interactable_layer(target_entity):
		panel.hide()
		return
	var text = ""
	for interactable: Interactable in target_entity.get_components_of_type("Interactable"):
		if not is_instance_valid(interactable):
			continue
		text = interactable.get_prompt()
		if text:
			break
	if text:
		label.text = text
	else:
		label.text = "[F] Interact"
	panel.show()

func get_pos_along_ray(distance: float):
	return ray_cast.global_position - ray_cast.global_transform.basis.z * distance
	
func start_interaction(entity: Entity):
	for interactable: Interactable in entity.get_components_of_type("Interactable"):
		if not is_instance_valid(interactable):
			continue
		interactable.interact(self)

func enable():
	_enabled = true
	ray_cast.enabled = true

func disable():
	_enabled = false
	ray_cast.enabled = false

###
func apply_cooldown():
	pass
		

#func Get_Look_Direction() -> Vector3:
	#var viewport = get_viewport().get_visible_rect().size
	#var camera = get_viewport().get_camera_3d()
	#return camera.project_ray_normal(viewport/2)
