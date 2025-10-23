extends Node2D

const TILE_SIZE = 32

func _ready():
	$Snake.position.x = 0
	$Snake.position.y = 0
	randomize()
	var viewport_size = get_viewport().get_visible_rect().size
	var x_tiles = floor(viewport_size.x / TILE_SIZE)
	var y_tiles = floor(viewport_size.y / TILE_SIZE)
	var random_x = randi() % int(x_tiles)
	var random_y = randi() % int(y_tiles)
	$Apple.position = Vector2(random_x * TILE_SIZE, random_y * TILE_SIZE)
