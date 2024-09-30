extends Component
class_name RangeValue

@export var min_value: int = 0
@export var max_value: int = 100
@export var value: int = 100:
	set(new_value):
		if value == new_value:
			return
		changed.emit()
		value = clamp(new_value, 0, max_value)
		if value == 0:
			depleted.emit()

signal changed
signal depleted

func increase(amount_gained: int):
	value += amount_gained

func decrease(amount_lost: int):
	value -= amount_lost
