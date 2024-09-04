extends MeshInstance3D

@export var health_gain: int

@onready var anim_player = $AnimationPlayer

var is_held

func _ready():
	is_held = get_parent() is HeldItem

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_held or SceneManager.in_menu:
		return
	if Input.is_action_just_pressed("primary attack"):
		anim_player.play("inspect")
