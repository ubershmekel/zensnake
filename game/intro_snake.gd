extends Node2D

const STEP_DISTANCE := 42.0
const JITTER_DEG := 2.5
const LEAN_RIGHT_DEG := -45.0
const LEAN_LEFT_DEG := -135.0
const TURN_LERP_SPEED := 6.0

var _target_angle := deg_to_rad(LEAN_RIGHT_DEG)
var _current_angle := deg_to_rad(LEAN_RIGHT_DEG)
var _turning_left := false

@onready var _segments: Array[Node2D] = [$Tail, $Body1, $Body2, $Head]

func _ready():
	randomize()
	_pin_tail_to_center()
	get_viewport().size_changed.connect(_pin_tail_to_center)
	call_deferred("_pin_tail_to_center")
	_update_segments()


func set_turning_left(is_pressed: bool) -> void:
	_turning_left = is_pressed
	_target_angle = deg_to_rad(LEAN_LEFT_DEG if _turning_left else LEAN_RIGHT_DEG)


func _process(delta: float) -> void:
	var jitter = deg_to_rad(randf_range(-JITTER_DEG, JITTER_DEG))
	_current_angle = lerp_angle(_current_angle, _target_angle + jitter, TURN_LERP_SPEED * delta)
	_update_segments()


func _pin_tail_to_center() -> void:
	var view_size: Vector2 = get_viewport().get_visible_rect().size
	global_position = view_size * 0.5
	$Tail.position = Vector2.ZERO


func _update_segments() -> void:
	var dir := Vector2.RIGHT.rotated(_current_angle)
	# var offsets := [
	# 	dir * STEP_DISTANCE * 3, # head
	# 	dir * STEP_DISTANCE * 2,
	# 	,
	# 	Vector2.ZERO # tail
	# ]

	for i in range(_segments.size()):
		_segments[i].position = $Tail.position + dir * STEP_DISTANCE * i
		_segments[i].rotation = _current_angle + PI / 2
