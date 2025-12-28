@tool
extends Resource
class_name LevelResource

@export var name: String = "" : set = _set_level_name
@export var scene: PackedScene

func _set_level_name(val: String) -> void:
	name = val

	# This is what the Inspector list label *can* use for inline subresources.
	resource_name = ("Level: %s" % val) if val != "" else "Level: (unnamed)"
