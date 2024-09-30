extends Component
class_name Interactor

## make this into flags
#@export_enum("Carryable") var interaction_component: String = "Carryable"
#
#@onready var ray_cast: RayCast3D = $RayCast3D
#
#var target: Component
#
#var in_interaction: bool
#
#func _ready():
	#ray_cast.add_exception(get_parent_entity())
	#ray_cast.enabled = false
#
#func _unhandled_key_input(event):
	#if event.is_echo():
		#return
	#if event.is_action_pressed("interact"):
		#if in_interaction:
			#end_interaction()
			#return
		#
		#ray_cast.enabled = true
		#ray_cast.force_raycast_update()
		#var col = ray_cast.get_collider() as Entity
		#if not col:
			#return
		#
		#var comp = col.get_component(interaction_component)
		#if not comp:
			#return
		#start_interaction(comp)
		#ray_cast.enabled = false
#
#func get_pos_along_ray(distance: float):
	#return global_position - global_transform.basis.z * distance
#
#func start_interaction(interactable: Component):
	#in_interaction = true
	#target = interactable
	#target.interact(self)
	#
#func end_interaction(recall = true):
	#in_interaction = false
	#if recall and is_instance_valid(target):
		#target.interact()
	#target = null
	#
