extends TextureButton

const GREEN := Color8(0x75, 0xbe, 0x99)
const ORANGE := Color8(0xcd, 0x61, 0x3d)

var _base_color: Color = Color(1, 1, 1, 1)

func _ready() -> void:
	match name:
		"TopButton":
			_base_color = GREEN
		"BottomButton":
			_base_color = ORANGE
	modulate = _base_color

func _on_button_down() -> void:
	create_tween().tween_property(self, "modulate", Color(1.7, 1.7, 1.7, 1.0), 0.05)


func _on_button_up() -> void:
	create_tween().tween_property(self, "modulate", _base_color, 0.12)
