extends MarginContainer

# Margin top when there is an iphone camera island

@export var extra_top_px := 64

func _ready() -> void:
	_apply_safe_area()
	get_viewport().size_changed.connect(_apply_safe_area)

func _apply_safe_area() -> void:
	var safe: Rect2i = DisplayServer.get_display_safe_area()
	var win: Vector2i = DisplayServer.window_get_size()
	var win_pos: Vector2i = DisplayServer.window_get_position()

	# Translate the safe area (screen space) into window-local margins
	var left: int   = max(0, safe.position.x - win_pos.x)
	var top: int    = max(0, safe.position.y - win_pos.y) + extra_top_px
	var right: int  = max(0, (win_pos.x + win.x) - (safe.position.x + safe.size.x))
	var bottom: int = max(0, (win_pos.y + win.y) - (safe.position.y + safe.size.y))

	add_theme_constant_override("margin_left", left)
	add_theme_constant_override("margin_top", top)
	add_theme_constant_override("margin_right", right)
	add_theme_constant_override("margin_bottom", bottom)
