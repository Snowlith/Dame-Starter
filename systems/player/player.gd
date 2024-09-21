extends CharacterBody3D

@onready var cam: FPSCamera = $FPSCamera

@onready var crouch: Crouch = $FPSController/Crouch

func _process(delta: float):
	var crouch_offset = crouch.get_offset(delta)
	cam.update_camera(delta, crouch_offset)



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
