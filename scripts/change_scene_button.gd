extends Button

@export_file("*.tscn") var target_scene_path: String
@export var id: String
@export var transition: PackedScene = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	var transition_data = TransitionData.new(target_scene_path)
	transition_data.transition = transition
	transition_data.id = id
	print("changed")
	SceneManager.change_scene(transition_data)
	
