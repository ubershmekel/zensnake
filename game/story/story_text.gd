@tool
extends Resource
class_name StoryText

@export_file("*.txt") var text_file: String
@export var id: String = "":
	set(value):
		id = value
		resource_name = ("StoryText: %s" % id) if id != "" else "StoryText: (unnamed)"

var _cached_lines: PackedStringArray


func get_lines() -> PackedStringArray:
	if _cached_lines.size() > 0:
		return _cached_lines
	if text_file.is_empty():
		return PackedStringArray()
	var file := FileAccess.open(text_file, FileAccess.READ)
	if file == null:
		return PackedStringArray()
	var content := file.get_as_text().replace("\r", "")
	var raw_lines := content.split("\n", false)
	var parsed := PackedStringArray()
	for line in raw_lines:
		var trimmed := line.strip_edges()
		if trimmed != "":
			parsed.append(trimmed)
	_cached_lines = parsed
	return _cached_lines
