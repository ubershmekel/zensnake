extends Node

var lines := [
	"A pattern emerges",
	"Patterns take shape",
	"What feels familiar to you?",
	"Have you seen this before?",
	"Order peeks through the noise",
	"Some things happen often",
	"There are patterns everywhere we look",
]

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	random_text()

func random_text() -> void:
	for node in get_tree().get_nodes_in_group("StoryText"):
		if node is Label:
			node.text = lines[rng.randi_range(0, lines.size() - 1)]
			break
#
