extends Node2D

@onready var right_button := $RightButton
@onready var left_button := $LeftButton
@onready var full_screen_button := $FullScreenButton

# player_count gets overwritten by the buttons in the main menu
var player_count = 1
var snakes = []

func _ready():
	$Snake.position.x = 0
	$Snake.position.y = 0
	# Connect the apple's "eaten" signal to our local handler so we can forward
	# the event to the specific snake instance that ate the apple.
	$Apple.eaten.connect(_on_apple_eaten)
	$Apple.reposition()
	snakes = [$Snake]

	# Apply textures to the primary snake
	$Snake.load_skin("snake")
	
	if player_count == 2:
		var new_snake = $Snake.duplicate()
		add_child(new_snake)
		new_snake.hotkey = KEY_B
		# Assign caterpy textures to the duplicated second-player snake
		# Load the caterpy skin on the new snake (not the original)
		new_snake.load_skin("caterpy")
		snakes.append(new_snake)

		# disable fullscreen button
		full_screen_button.visible = false
		right_button.visible = true
		left_button.visible = true
	else:
		full_screen_button.visible = true
		right_button.visible = false
		left_button.visible = false


func _on_apple_eaten(snake, fruit: FruitData = null):
	# Forward the eaten event to the snake instance that ate the apple.
	# We call its handler so the proper snake grows.
	if snake and snake.has_method("_on_apple_eaten"):
		snake._on_apple_eaten(fruit)

# The top controls the first snake
# The bottom controls the last snake
# When there is only one snake that means it's just the 1
func _process(_delta) -> void:
	if snakes.size() == 2:
		snakes[0].is_button_down = left_button.is_pressed()
		snakes[1].is_button_down = right_button.is_pressed()
	else:
		snakes[0].is_button_down = full_screen_button.is_pressed()
