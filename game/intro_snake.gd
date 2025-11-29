extends Node2D

const STEP_DISTANCE := 42.0
const DIR_STEP_DEG := 15.0
const BASE_TAIL_DEG := -90.0 # pointing up
const NOISE_JITTER_DEG := 0.5
const SIGN_LERP_SPEED := 2.0

@export var body_count := 5 # pieces between tail and head

var _target_sign := 1.0
var _current_sign := 1.0
var _turning_left := false

@onready var _segments: Array[Node2D] = []

func _ready():
	randomize()
	_build_segments()
	_update_segments()

func set_turning_left(is_pressed: bool) -> void:
	_turning_left = is_pressed
	_target_sign = -1.0 if _turning_left else 1.0


func _process(delta: float) -> void:
	_current_sign = lerp(_current_sign, _target_sign, SIGN_LERP_SPEED * delta)
	var jitter = deg_to_rad(randf_range(-NOISE_JITTER_DEG, NOISE_JITTER_DEG))
	_update_segments(jitter)


func _pin_tail_to_center() -> void:
	var view_size: Vector2 = get_viewport().get_visible_rect().size
	global_position = view_size * 0.5
	$Tail.position = Vector2.ZERO

func _build_segments() -> void:
	_segments.clear()
	_segments.append($Tail)

	# remove old extra bodies if any
	for child in get_children():
		if child.name.begins_with("Body") and child != $Body1:
			child.queue_free()

	var bodies_to_make = max(body_count, 1)
	for i in range(bodies_to_make):
		var body: Node2D
		if i == 0:
			body = $Body1
		else:
			body = $Body1.duplicate()
			body.name = "Body%s" % (i + 1)
			add_child(body)
		_segments.append(body)

	_segments.append($Head)


func _update_segments(jitter: float = 0.0) -> void:
	var base_angle := deg_to_rad(BASE_TAIL_DEG) + jitter
	var step_angle := deg_to_rad(DIR_STEP_DEG) * _current_sign

	for i in range(_segments.size()):
		var dir_angle := base_angle + step_angle * i

		if i == 0:
			_segments[i].position = Vector2.ZERO
		else:
			var offset := Vector2.ZERO
			for k in range(i):
				var seg_angle := base_angle + step_angle * k
				offset += Vector2.RIGHT.rotated(seg_angle) * STEP_DISTANCE
			_segments[i].position = _segments[0].position + offset

		_segments[i].rotation = dir_angle + PI / 2
