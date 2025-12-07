extends TextureButton
class_name MultiTouchTextureButton

const GREEN := Color8(0x75, 0xbe, 0x99)
const ORANGE := Color8(0xcd, 0x61, 0x3d)
const BRIGHT = Color(1.7, 1.7, 1.7, 1.0)

# active_index is which finger pressed the button
var active_index := -1
## Read-only exported property (visible but not editable)
var _is_down: bool = false
@export var base_color = GREEN
## If true, dragging back in re-presses the button
@export var reenter_repress: bool = true
# is_modulating decides if we change the colors of the button or not
@export var is_modulating = true

@export var is_down: bool:
	get:
		return _is_down
	set(value):
		_is_down = value
		# for TextureButton
		button_pressed = _is_down

func _ready() -> void:
	_initial_texture_normal = texture_normal
	# Aavoid default single-touch/Button behavior
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	if is_modulating:
		modulate = base_color

var _pressed_fingers: Dictionary = {} # index -> true
var _hover_fingers: Dictionary = {} # index -> true
var _initial_texture_normal: Texture2D

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)


func _handle_touch(event: InputEventScreenTouch) -> void:
	var inside := get_global_rect().has_point(event.position)
	var idx := event.index
	var was_pressed := _pressed_fingers.has(idx)

	if event.pressed:
		if inside:
			_hover_fingers[idx] = true
			_pressed_fingers[idx] = true
			_refresh_state()
	else:
		_pressed_fingers.erase(idx)
		_hover_fingers.erase(idx)
		if was_pressed and inside:
			_trigger_pressed()
		_refresh_state()


func _handle_drag(event: InputEventScreenDrag) -> void:
	var inside := get_global_rect().has_point(event.position)
	var idx := event.index
	var was_pressed := _pressed_fingers.has(idx)

	if inside:
		_hover_fingers[idx] = true
		if reenter_repress and not was_pressed:
			_pressed_fingers[idx] = true
			_refresh_state()
	else:
		_hover_fingers.erase(idx)
		if was_pressed:
			_pressed_fingers.erase(idx)
			_on_cancel()
			_refresh_state()


func _refresh_state() -> void:
	var new_state := not _pressed_fingers.is_empty()

	if new_state != _is_down:
		# Use setter to update visuals
		is_down = new_state

		if new_state:
			_on_button_down()
		else:
			_on_button_up()

func _trigger_pressed() -> void:
	_on_pressed()
	pressed.emit()


func _on_button_down() -> void:
	if is_modulating:
		create_tween().tween_property(self, "modulate", BRIGHT, 0.05)
	# Manually set the pressed texture
	if texture_pressed:
		texture_normal = texture_pressed

func _on_button_up() -> void:
	if is_modulating:
		create_tween().tween_property(self, "modulate", base_color, 0.12)
	# Restore the initial normal texture
	if _initial_texture_normal:
		texture_normal = _initial_texture_normal

func _on_pressed() -> void:
	pass

func _on_cancel() -> void:
	pass
