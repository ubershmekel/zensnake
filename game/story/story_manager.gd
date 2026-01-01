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

	# remove placeholder text
	story_ui.text = ""

	var fruits = get_tree().get_nodes_in_group("fruits")
	for fruit in fruits:
		fruit.eaten_animation_done.connect(on_fruit_eaten)
	

func on_fruit_eaten(_fruit) -> void:
	if _active == null:
		return
	_fruit_count += 1
	var phase := _fruit_count % 4
	match phase:
		0:
			_clear_story_text() # no text
		1:
			_show_next_line() # text
		2:
			pass # text
		3:
			story_ui.fade_out(1.0) # no text


func _clear_story_text() -> void:
	story_ui.text = ""
	story_ui.reset()


func _show_next_line() -> void:
	var lines := _active.get_lines()
	if _line_index >= lines.size():
		return

	story_ui.text = lines[_line_index]
	story_ui.reveal()
	_line_index += 1
