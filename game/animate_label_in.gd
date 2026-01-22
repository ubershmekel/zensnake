extends Label

@export var animation_duration: float = 0.0
@export var start_delay: float = 0.0
@export var start_scale: float = 1.0
@export var character_interval: float = 0.04
@export var fade_duration: float = 0.2

var _reveal_tween: Tween = null
var _reveal_token: int = 0

func _ready() -> void:
	reset()
	wait_and_reveal()

func wait_and_reveal() -> void:
	# Trigger reveal animation after the configured delay
	if start_delay > 0:
		await get_tree().create_timer(start_delay).timeout
	reveal()

func reset() -> void:
	# Start invisible
	modulate.a = 0.0
	scale = Vector2(start_scale, start_scale)
	visible_characters = 0

func reveal() -> void:
	# Cancel any existing tween
	if _reveal_tween:
		_reveal_tween.kill()
	
	_reveal_token += 1
	_reveal_tween = create_tween()
	
	# Nice reveal: fade in and scale up with elastic effect
	_reveal_tween.parallel().tween_property(self, "modulate:a", 1.0, animation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_reveal_tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), animation_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_reveal_characters(_reveal_token)

func _reveal_characters(token: int) -> void:
	if character_interval <= 0.0:
		# Show all characters
		visible_characters = -1
		return

	while visible_characters < text.length():
		if token != _reveal_token:
			return
		visible_characters = visible_characters + 1
		await get_tree().create_timer(character_interval).timeout
	
	# Show all characters after done animating
	visible_characters = -1

func fade_out(duration: float = -1.0) -> void:
	# Cancel any existing tween to avoid fighting animations.
	if _reveal_tween:
		_reveal_tween.kill()
	var tween := create_tween()
	var final_duration := fade_duration if duration < 0.0 else duration
	tween.tween_property(self, "modulate:a", 0.0, final_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
