extends Node2D

@onready var right_button := $RightButton
@onready var left_button := $LeftButton

# player_count gets overwritten by the buttons in the main menu
var player_count = 1
var snakes = []

func _ready():
	$Snake.position.x = 0
	$Snake.position.y = 0
	# Connect the apple's "eaten" signal to the snake's "_on_apple_eaten" function.
	$Apple.eaten.connect($Snake._on_apple_eaten)
	$Apple.reposition()
	snakes = [$Snake]
	
	if player_count == 2:
		var new_snake = $Snake.duplicate()
		add_child(new_snake)
		new_snake.hotkey = KEY_B
		snakes.append(new_snake)

# The top controls the first snake
# The bottom controls the last snake
# When there is only one snake that means it's just the 1
func _process(delta) -> void:
	snakes[0].is_button_down = left_button.is_pressed()
	snakes[-1].is_button_down = right_button.is_pressed()
