extends Node

const FRUIT_COUNT := 20

@onready var _fruit_scene: PackedScene = preload("res://game/fruit.tscn")
@onready var _grape_data: FruitData = preload("res://resources/fruit/grapes.tres")

var fruit_spawned_count := 0;
var fruit_eaten_count := 0;

func _spawn_fruit():
	var fruit: FruitClass = _fruit_scene.instantiate()
	fruit.fruit_data = _grape_data
	fruit.fall_speed = 40
	# Parent may still be configuring its children, so defer attaching the fruit.
	add_child(fruit)
	return fruit

func _ready() -> void:
	randomize()

	for i in range(FRUIT_COUNT):
		fruit_spawned_count += 1
		var fruit: FruitClass = _spawn_fruit()
		fruit.random_position()
