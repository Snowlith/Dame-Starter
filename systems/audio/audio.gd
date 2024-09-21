extends Node

@onready var tree := get_tree() # Gets the slightest of performance improvements by caching the SceneTree

var _is_ready = false

func _enter_tree():
	_is_ready = true
	
func _play_sound(sound: AudioStream, player, autoplay := true):
	if not sound or not _is_ready:
		return
	player.stream = sound
	player.autoplay = autoplay
	player.finished.connect(func(): player.queue_free())
	tree.current_scene.call_deferred("add_child", player)
	return player

# Use this for non-diagetic music or UI sounds which have no position
func play_sound(sound: AudioStream, autoplay := true) -> AudioStreamPlayer:
	return _play_sound(sound, AudioStreamPlayer.new(), autoplay)
