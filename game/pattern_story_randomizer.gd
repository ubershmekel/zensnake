extends Node

@export_file("*.txt") var text_file: String

var rng := RandomNumberGenerator.new()
var lines: Array[String]

func _ready() -> void:
	rng.randomize()
	var packed := FileAccess.open(text_file, FileAccess.READ).get_as_text().split("\n")
	lines = []
	for s in packed:
		lines.append(s)
	random_text()

func random_text() -> void:
	for node in get_tree().get_nodes_in_group("StoryText"):
		if node is Label:
			node.text = lines[rng.randi_range(0, lines.size() - 1)]
			break
