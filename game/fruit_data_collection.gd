extends Node

# Shared dictionary of fruit data, exposed as a static so it can be accessed without instancing.
static var FRUIT_DEFINITIONS: Dictionary = {
	"apple": FruitData.new(
		"apple",
		preload("res://assets/eat/apple.png"),
		false,
		false
	),
	"banana": FruitData.new(
		"banana",
		preload("res://assets/eat/banana.png"),
		false,
		true
	),
	"cherries": FruitData.new(
		"cherries",
		preload("res://assets/eat/cherries.png"),
		true,
		false
	),
	"chili": FruitData.new(
		"chili",
		preload("res://assets/eat/chili.png"),
		true,
		true
	),
	"grapes": FruitData.new(
		"grapes",
		preload("res://assets/eat/grapes.png"),
		false,
		false
	),
	"orange": FruitData.new(
		"orange",
		preload("res://assets/eat/orange.png"),
		false,
		true
	),
	"watermelon": FruitData.new(
		"watermelon",
		preload("res://assets/eat/waterm.png"),
		true,
		false
	),
}
