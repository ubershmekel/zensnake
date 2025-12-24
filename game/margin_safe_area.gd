extends MarginContainer

# Margin top when there is an iphone camera island

@export var extra_top_px := 64

func _ready() -> void:
	_apply_safe_area()
	get_viewport().size_changed.connect(_apply_safe_area)

func _apply_safe_area() -> void:
	var safe: Rect2i = DisplayServer.get_display_safe_area()
	var win: Vector2i = DisplayServer.window_get_size()

	var left   := safe.position.x
	var top    := safe.position.y + extra_top_px
	var right  := win.x - (safe.position.x + safe.size.x)
	var bottom := win.y - (safe.position.y + safe.size.y)

	add_theme_constant_override("margin_left", left)
	add_theme_constant_override("margin_top", top)
	add_theme_constant_override("margin_right", right)
	add_theme_constant_override("margin_bottom", bottom)
