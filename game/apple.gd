extends Area2D

signal eaten

const TILE_SIZE = 32

func _ready():
	# Connect the area_entered signal to our function
	self.area_entered.connect(_on_area_entered)
	reposition()

func _on_area_entered(area):
	# We only care if the area that entered is the snake's head
	if area.name == 'SnakeHead':
		emit_signal("eaten")
		reposition()

func reposition():
	randomize()
	var viewport_size = get_viewport().get_visible_rect().size
	var x_tiles = floor(viewport_size.x / TILE_SIZE)
	var y_tiles = floor(viewport_size.y / TILE_SIZE)
	var random_x = randi() % int(x_tiles)
	var random_y = randi() % int(y_tiles)
	position = Vector2(random_x * TILE_SIZE, random_y * TILE_SIZE)
