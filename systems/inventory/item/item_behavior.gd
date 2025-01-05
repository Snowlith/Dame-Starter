extends Node3D
class_name ItemBehavior

var _user: Entity

func holster(user: Entity):
	_user = user

func unholster():
	_user = null
