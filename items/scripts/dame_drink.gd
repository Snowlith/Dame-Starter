extends Item

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _unhandled_input(event):
	if event is InputEventMouseMotion or event.is_echo():
		return
	if in_animation():
		return
	if event.is_action_pressed("primary attack"):
		allow_unequip = false
		await primary_attack()
		allow_unequip = true
	elif event.is_action_pressed("inspect"):
		play_inspect()

func primary_attack():
	anim_player.play("consume")
	await anim_player.animation_finished
	
	var inv: Inventory = _user.get_component("Inventory")
	
	if inv:
		inv.remove_from(inv.hand_slot)
