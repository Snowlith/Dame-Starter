extends Label

func connect_interactable_signals(interactable: Interactable):
	text = interactable.prompt
	visible = interactable.is_active
	interactable.prompt_changed.connect(func(t): text = t)
	interactable.is_active_changed.connect(func(v): visible = v)
