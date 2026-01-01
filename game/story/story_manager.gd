extends Node
class_name StoryManager

@export var library: StoryLibrary
@export var fruits_per_line := 2

@onready var story_ui := get_tree().get_nodes_in_group("StoryText")[0]

var _rng := RandomNumberGenerator.new()
var _active: StoryText
var _line_index := 0
var _fruit_count := 0

func _ready() -> void:
	_rng.randomize()
	if library:
		_active = library.pick_random(_rng)

	var fruits = get_tree().get_nodes_in_group("fruits")
	for fruit in fruits:
		fruit.eaten_animation_done.connect(on_fruit_eaten)

func on_fruit_eaten(_fruit) -> void:
	if _active == null:
		return
	_fruit_count += 1
	if _fruit_count % fruits_per_line != 0:
		return
	var lines := _active.get_lines()
	if _line_index >= lines.size():
		return
	if story_ui is Label:
		story_ui.text = lines[_line_index]
		story_ui.reset()
	_line_index += 1
