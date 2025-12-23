extends Label

@export var animation_duration: float = 0.5
@export var start_delay: float = 0.0
@export var start_scale: float = 0.5

var _reveal_tween: Tween = null

func _ready() -> void:
	# Start invisible
	modulate.a = 0.0
	scale = Vector2(start_scale, start_scale)
	
	# Trigger reveal animation after the configured delay
	if start_delay > 0:
		await get_tree().create_timer(start_delay).timeout
	reveal()

func reveal() -> void:
	# Cancel any existing tween
	if _reveal_tween:
		_reveal_tween.kill()
	
	_reveal_tween = create_tween()
	
	# Nice reveal: fade in and scale up with elastic effect
	_reveal_tween.parallel().tween_property(self, "modulate:a", 1.0, animation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_reveal_tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), animation_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
