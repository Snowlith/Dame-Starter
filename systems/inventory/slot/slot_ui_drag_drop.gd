extends Control
class_name SlotUIDragDrop

@export var drag_preview_size := Vector2(64, 64)
@export var drag_preview_opacity: float = 0.75

var _drag_data_callable := Callable(func(): return null)
var _drop_validation_callable := Callable(func(): return null)

signal dropped(data: Dictionary)

func _ready():
	var control := get_parent_control()
	if not control:
		queue_free()
	control.set_drag_forwarding(_on_drag, _can_drop, _on_drop)

## Drag
func set_drag_data_callable(callable: Callable):
	assert(callable.get_argument_count() == 0)
	_drag_data_callable = callable

func _on_drag(pos: Vector2):
	var data = _drag_data_callable.call()
	if not data:
		return
	set_drag_preview(get_preview(data["slot"], pos))
	return data

func drag(data: Dictionary, pos = drag_preview_size / 2):
	force_drag(data, get_preview(data["slot"], pos))

func get_preview(slot: Slot, pos: Vector2):
	var preview = Control.new()
	preview.z_index = 100
	
	var sub_preview: TextureRect = TextureRect.new()
	sub_preview.position -= pos
	sub_preview.texture = slot.item.icon
	sub_preview.custom_minimum_size = drag_preview_size
	sub_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sub_preview.modulate.a = drag_preview_opacity
	preview.add_child(sub_preview)
	
	return preview

## Drop
func set_drop_validation_callable(callable: Callable):
	assert(callable.get_argument_count() == 1)
	_drop_validation_callable = callable
	
func _can_drop(pos: Vector2, data: Dictionary):
	return _drop_validation_callable.call(data) as bool
	
func _on_drop(pos: Vector2, data: Dictionary):
	dropped.emit(data)
