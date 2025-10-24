extends Node2D

# --- Movement Settings ---
const TILE_SIZE := 32
const SNAKE_MOVE_SIZE := 20
const MOVE_INTERVAL := 0.08  # seconds between moves
const ROTATE_RATE := 15.0
const ROTATION_INTERVAL := MOVE_INTERVAL

@export var hotkey = KEY_A
@export var headTexture: Texture2D
@export var bodyTexture: Texture2D

var is_hotkey_pressed := false
var direction := Vector2.UP
var time_passed := 0.0
var snake_size := 14
var rotation_time_passed := 0.0

@export var body_element: Node2D

# --- Internal State ---
# This will hold ALL snake nodes (head + body)
@onready var snake_nodes: Array[Node2D] = [$SnakeHead, $SnakeBody]
# This will store the grid positions for each node
var snake_positions: Array[Vector2] = []


func _ready():
	# Keep
	$SnakeHead.z_index = 1
	$SnakeHead/Sprite2D.texture = headTexture
	$SnakeBody/Sprite2D.texture = bodyTexture
	$SnakeBody.z_index = -1
	
	# 2. Store the STARTING positions of all nodes
	#    (Make sure to line them up in the editor behind the head!)
	var start = Vector2(randi() % 300 + 100, randi() % 300 + 100)
	for segment in snake_nodes:
		snake_positions.push_back(start)


func _process(delta: float) -> void:
	time_passed += delta
	rotation_time_passed += delta
	
	if rotation_time_passed >= ROTATION_INTERVAL:
		rotation_time_passed = 0.0
		var rotation_amount_deg = -ROTATE_RATE if is_hotkey_pressed else ROTATE_RATE
		direction = direction.rotated(deg_to_rad(rotation_amount_deg))
		$SnakeHead.rotation = direction.angle() + PI / 2
	
	# Check if it's time to move
	if time_passed >= MOVE_INTERVAL:
		time_passed = 0.0 # Reset timer
		move()

func move() -> void:
	# --- 1. Update Direction ---
	# Check if the buffered direction is a 180-degree turn
	## (e.g., current is RIGHT (1,0), new is LEFT (-1,0). Sum is (0,0))
	#if direction + new_direction != Vector2.ZERO:
		#direction = new_direction
	#else:
		## The attempted move was invalid (into itself),
		## so reset the buffer to the current, valid direction
		#new_direction = direction

	# --- 2. Update Position DATA ---
	# Calculate the new position for the head
	var new_head_pos = snake_positions[0] + direction * SNAKE_MOVE_SIZE

	# Wrap around the viewport edges so the snake reappears on the opposite side
	var view_size: Vector2 = get_viewport().get_visible_rect().size
	# X wrap
	if new_head_pos.x < 0:
		new_head_pos.x = view_size.x - TILE_SIZE
	elif new_head_pos.x >= view_size.x:
		new_head_pos.x = 0
	# Y wrap
	if new_head_pos.y < 0:
		new_head_pos.y = view_size.y - TILE_SIZE
	elif new_head_pos.y >= view_size.y:
		new_head_pos.y = 0

	# Add the new head position to the FRONT of the list
	snake_positions.insert(0, new_head_pos)
	
	if len(snake_nodes) < snake_size:
		# grow!
		# birth another body part
		var new_body: Node2D = $SnakeBody.duplicate()
		new_body.name = "SnakeBody_" + str(snake_nodes.size())
		new_body.z_index = 0
		#new_body.get_node("Sprite2D").texture = skin
		add_child(new_body)
		snake_nodes.push_back(new_body)
	else:
		# Remove the very last position (the tail)
		snake_positions.pop_back()
	
	# --- 3. Update Visuals ---
	# Loop through all nodes and set their position
	# from our master position list.
	for i in range(snake_nodes.size()):
		snake_nodes[i].position = snake_positions[i]


func _on_apple_eaten():
	# Grow!
	snake_size += 20

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == hotkey:
		is_hotkey_pressed = event.is_pressed()
