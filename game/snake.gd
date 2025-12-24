extends Node2D

# --- Movement Settings ---
const TILE_SIZE := 32
const SNAKE_MOVE_SIZE := 40
const MOVE_INTERVAL := 0.12 # seconds between moves
const ROTATE_RATE := 15.0
const ROTATION_INTERVAL := MOVE_INTERVAL

@export var hotkey = KEY_A
@export var static_body = false
@export var smooth_tween = false

var is_hotkey_pressed := false
var is_button_down := false
var direction := Vector2.UP
var time_passed := 0.0
var snake_size := 3
var rotation_time_passed := 0.0
var pause_processing := false

@export var body_element: Node2D

# --- Internal State ---
# This will hold ALL snake nodes (head + body)
@onready var snake_nodes: Array[Node2D] = [$SnakeHead, $SnakeBody]
@onready var _head_sprite: Sprite2D = $SnakeHead/Sprite2D
var body_textures: Array[Texture2D] = []
var node_move_tweens: Dictionary = {}
var _head_pop_tween: Tween = null
var _head_base_scale: Vector2

func _ready():
	# Keep
	$SnakeHead.z_index = 11
	$SnakeBody.z_index = 10

	_head_base_scale = _head_sprite.scale
	
	# 2. Store the STARTING positions of all nodes
	#    (Make sure to line them up in the editor behind the head!)
	var start = Vector2(randi() % 300 + 100, randi() % 300 + 100)
	for segment in snake_nodes:
		segment.position = start
	
	load_skin("snake")

func load_skin(skin_name: String) -> void:
	var base_path = "res://assets/%s/" % skin_name

	$SnakeHead/Sprite2D.texture = load(base_path + "head.png")
	
	body_textures = []
	for i in range(1, 6):
		var tex_path = base_path + "body%d.png" % (i + 1)
		body_textures.append(load(tex_path))
	
	$SnakeBody/Sprite2D.texture = body_textures[0]

func _process(delta: float) -> void:
	if pause_processing:
		return

	time_passed += delta
	rotation_time_passed += delta
	var is_reversing := is_hotkey_pressed or is_button_down
	
	if rotation_time_passed >= ROTATION_INTERVAL:
		rotation_time_passed = 0.0
		var rotation_amount_deg = - ROTATE_RATE if is_reversing else ROTATE_RATE
		direction = direction.rotated(deg_to_rad(rotation_amount_deg))
		$SnakeHead.rotation = direction.angle() + PI / 2
	
	# Check if it's time to move
	if time_passed >= MOVE_INTERVAL:
		time_passed = 0.0 # Reset timer
		move()

func grow(custom_position: Vector2) -> void:
	var new_body: Node2D = snake_nodes[-1].duplicate()
	new_body.name = "SnakeBody_" + str(snake_nodes.size())
	new_body.z_index = 10
	new_body.get_node("Sprite2D").texture = body_textures[randi() % body_textures.size()]
	var new_segment_position := Vector2.ZERO
	new_segment_position = custom_position
	new_body.position = new_segment_position
	add_child(new_body)
	snake_nodes.push_back(new_body)


func move() -> void:
	var previous_head_pos = snake_nodes[0].position
	var new_head_pos = previous_head_pos + direction * SNAKE_MOVE_SIZE

	# Wrap around the viewport edges so the snake reappears on the opposite side
	var view_size: Vector2 = get_viewport().get_visible_rect().size
	# X wrap
	if new_head_pos.x < -TILE_SIZE:
		new_head_pos.x = view_size.x
	elif new_head_pos.x >= view_size.x + TILE_SIZE:
		new_head_pos.x = 0
	# Y wrap
	if new_head_pos.y < -TILE_SIZE:
		new_head_pos.y = view_size.y
	elif new_head_pos.y >= view_size.y + TILE_SIZE:
		new_head_pos.y = 0

	var last_body_pos = snake_nodes[-1].position
	var grow_pos = last_body_pos
	if static_body:
		grow_pos = previous_head_pos
	if snake_nodes.size() < snake_size:
		# grow!
		# birth another body part
		grow(grow_pos)
	_animate_segment_to(snake_nodes[0], new_head_pos)
	if static_body:
		if snake_nodes.size() > 1:
			# Move the last body segment directly behind the head instead of
			# shifting every segment's position.
			var tail = snake_nodes.pop_back()
			_animate_segment_to(tail, previous_head_pos, true)
			snake_nodes.insert(1, tail)
	else:
		# Move all the body parts just like the head moved
		var previous_position: Vector2 = previous_head_pos
		for i in range(1, snake_nodes.size()):
			var current_position = snake_nodes[i].position
			_animate_segment_to(snake_nodes[i], previous_position)
			previous_position = current_position

func _on_fruit_eaten(_eater: Node, fruit_data: FruitData = null, growth_amount: int = 10):
	# Deprecated: Use _on_snake_effect instead
	# This method is kept for backward compatibility
	var effect = SnakeEffect.new(growth_amount, fruit_data.static_body if fruit_data else false, fruit_data.smooth_tween if fruit_data else false)
	_on_snake_effect(effect)

func _on_snake_effect(effect: SnakeEffect):
	# Apply all effects from the SnakeEffect
	snake_size += effect.growth_amount
	static_body = effect.static_body
	smooth_tween = effect.smooth_tween
	AudioManager.play_eat()
	_play_head_pop()

func reset_for_new_level(target_position: Vector2, target_size: int = 2, duration: float = 0.35) -> void:
	target_size = max(target_size, 2)
	snake_size = target_size
	pause_processing = true
	direction = Vector2.UP
	time_passed = 0.0
	rotation_time_passed = 0.0
	is_hotkey_pressed = false
	is_button_down = false

	for tween in node_move_tweens.values():
		if tween:
			tween.kill()
	node_move_tweens.clear()

	if _head_pop_tween:
		_head_pop_tween.kill()
		_head_pop_tween = null
	_head_sprite.scale = _head_base_scale
	$SnakeHead.rotation = direction.angle() + PI / 2
	await _burp_pulse_segments()
	await _shrink_tail_segments(target_size)
	await _animate_remaining_to_position(target_position, duration)
	pause_processing = false

func pause_and_burp() -> void:
	pause_processing = true
	await _burp_pulse_segments()
	pause_processing = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == hotkey:
		var key := event as InputEventKey
		is_hotkey_pressed = key.is_pressed()
		if key.echo:
			return

		# if is_hotkey_pressed:
		# 	pause_and_burp()

func _animate_segment_to(node: Node2D, target_position: Vector2, cancel_tween = false) -> void:
	if smooth_tween:
		var view_size: Vector2 = get_viewport().get_visible_rect().size
		if abs(node.position.x - target_position.x) > view_size.x * 0.5:
			cancel_tween = true
		if abs(node.position.y - target_position.y) > view_size.y * 0.5:
			cancel_tween = true
	
	if node_move_tweens.has(node) and node_move_tweens[node]:
		node_move_tweens[node].kill()
		node_move_tweens.erase(node)
	
	if not smooth_tween or cancel_tween:
		node.position = target_position
		return
	
	var tween := create_tween()
	tween.tween_property(node, "position", target_position, MOVE_INTERVAL).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	node_move_tweens[node] = tween

func _play_head_pop() -> void:
	if _head_pop_tween:
		_head_pop_tween.kill()
	_head_sprite.scale = _head_base_scale

	var pop_scale := _head_base_scale * 1.25
	_head_pop_tween = create_tween()
	_head_pop_tween.tween_property(_head_sprite, "scale", pop_scale, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_head_pop_tween.tween_property(_head_sprite, "scale", _head_base_scale, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

func _trim_segments_to_size(target_size: int) -> void:
	while snake_nodes.size() > target_size:
		var tail: Node2D = snake_nodes.pop_back()
		if is_instance_valid(tail):
			tail.queue_free()

	while snake_nodes.size() < target_size:
		grow(snake_nodes[-1].position)

func _burp_pulse_segments() -> void:
	const total_burp_duration_seconds := 1.0
	var burp_part_duration_seconds := total_burp_duration_seconds / snake_nodes.size()
	for i in range(snake_nodes.size() - 1, -1, -1):
		var node := snake_nodes[i]
		if not is_instance_valid(node):
			continue
		var base_scale: Vector2 = node.scale
		var pulse_scale := base_scale * 1.38
		var seconds_delay := total_burp_duration_seconds - i * burp_part_duration_seconds
		var tween := create_tween()
		tween.tween_interval(seconds_delay)
		tween.tween_property(node, "scale", pulse_scale, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(node, "scale", base_scale, seconds_delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	const burp_sound_duration := 0.2
	await get_tree().create_timer(total_burp_duration_seconds - burp_sound_duration).timeout
	print("burp")
	AudioManager.play_burp()
	await get_tree().create_timer(burp_sound_duration).timeout
	#for tween in tweens:
		#print("awaiting tween", tween)
		#await tween.finished
		#print("done tween", tween)
	print("done burp seg")

	
func _shrink_tail_segments(target_size: int) -> void:
	const shrink_body_cell_duration_seconds := 0.03
	while snake_nodes.size() > target_size:
		var tail: Node2D = snake_nodes.pop_back()
		if not is_instance_valid(tail):
			continue
		var tween := create_tween()
		tween.tween_property(tail, "scale", Vector2.ZERO, shrink_body_cell_duration_seconds).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		await tween.finished
		tail.queue_free()

func _animate_remaining_to_position(target_position: Vector2, duration: float) -> void:
	_trim_segments_to_size(2)
	if snake_nodes.size() < 2:
		grow(target_position + Vector2(0, SNAKE_MOVE_SIZE))

	var tween := create_tween()
	tween.set_parallel(true)
	for i in range(snake_nodes.size()):
		var destination := target_position + Vector2(0, SNAKE_MOVE_SIZE * i)
		tween.tween_property(snake_nodes[i], "position", destination, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
