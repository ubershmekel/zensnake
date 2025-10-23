extends Node2D

func _ready():
	$Snake.position.x = 0
	$Snake.position.y = 0
	# Connect the apple's "eaten" signal to the snake's "_on_apple_eaten" function.
	$Apple.eaten.connect($Snake._on_apple_eaten)
	$Apple.reposition()
