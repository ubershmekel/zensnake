extends Node2D

var player_count = 1

func _ready():
	$Snake.position.x = 0
	$Snake.position.y = 0
	# Connect the apple's "eaten" signal to the snake's "_on_apple_eaten" function.
	$Apple.eaten.connect($Snake._on_apple_eaten)
	$Apple.reposition()
	
	if player_count == 2:
		var new_snake = $Snake.duplicate()
		add_child(new_snake)
		new_snake.hotkey = KEY_B
		
