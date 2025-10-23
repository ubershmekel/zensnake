extends Node2D

# --- Movement Settings ---
const TILE_SIZE := 32
const MOVE_INTERVAL := 0.3  # seconds between tile moves

# --- Node References ---
@onready var head: Node2D = $Head
# This array will hold your 4 body parts.
# You must drag-and-drop your 4 body nodes into this array
# in the Godot Inspector.
@export var body_element: Node2D

# --- Internal State ---
# This will hold ALL snake nodes (head + body)
@onready var snake_nodes: Array[Node2D] = [$SnakeHead, $SnakeBody]
# This will store the grid positions for each node
var snake_positions: Array[Vector2] = []

var direction := Vector2.UP
var time_passed := 0.0
var snake_size := 4

func _ready():
	# 1. Create one unified list of all snake parts, starting with the head
	#snake_nodes.push_back(head)
	#snake_nodes.push_back(body_element)
	
	# 2. Store the STARTING positions of all nodes
	#    (Make sure to line them up in the editor behind the head!)
	for segment in snake_nodes:
		snake_positions.push_back(Vector2(300, 600))


func _process(delta: float) -> void:
	time_passed += delta
	
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
	var new_head_pos = snake_positions[0] + direction * TILE_SIZE
	
	# Add the new head position to the FRONT of the list
	snake_positions.insert(0, new_head_pos)
	
	if len(snake_nodes) < snake_size:
		# birth another body part
		var new_body: Node2D = $SnakeBody.duplicate()
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

func _unhandled_input(event: InputEvent) -> void:
	# This is your original logic, but with one key change:
	# We set 'new_direction' (the buffer) instead of 'direction' directly.
	# This prevents changing direction multiple times between moves.
	if (event is InputEventScreenTouch and event.pressed) or \
	   (event is InputEventMouseButton and event.pressed):
		direction = -direction
