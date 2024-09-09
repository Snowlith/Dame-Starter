extends Item

@export var health_gain: int

func _unhandled_input(event):
	if event.is_echo():
		return
	if event.is_action_pressed("primary attack"):
		allow_unequip = false
		await primary_attack()
		allow_unequip = true
	elif event.is_action_pressed("inspect"):
		inspect()

func primary_attack():
	if anim_player.is_playing():
		return
	anim_player.play("drink")
	await anim_player.animation_finished
	
	var inv: Inventory
	var h: Health
	
	for child in user.get_children():
		if child as Inventory:
			inv = child
			continue
		if child as Health:
			h = child
			continue
	if inv:
		inv.remove_from(inv.hand_slot)
	if h:
		h.current_health += health_gain
		
func inspect():
	if anim_player.is_playing():
		return
	anim_player.play("inspect")
	await anim_player.animation_finished
