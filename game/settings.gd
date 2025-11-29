extends Node

const CONFIG_PATH := "user://settings.cfg"
const SECTION_AUDIO := "audio"
const KEY_MUSIC_VOLUME := "music_volume"
const KEY_SFX_VOLUME := "sfx_volume"

var _music_volume := 1.0
var _sfx_volume := 1.0


func _ready() -> void:
	_load()

func _load() -> void:
	var config := ConfigFile.new()
	var err := config.load(CONFIG_PATH)
	if err == OK:
		_music_volume = config.get_value(SECTION_AUDIO, KEY_MUSIC_VOLUME, 1.0)
		_sfx_volume = config.get_value(SECTION_AUDIO, KEY_SFX_VOLUME, 1.0)
	else:
		_music_volume = 1.0
		_sfx_volume = 1.0

func _save() -> void:
	var config := ConfigFile.new()
	config.set_value(SECTION_AUDIO, KEY_MUSIC_VOLUME, _music_volume)
	config.set_value(SECTION_AUDIO, KEY_SFX_VOLUME, _sfx_volume)
	var err := config.save(CONFIG_PATH)
	if err != OK:
		push_warning("Failed to save settings: %s" % [err])

func set_music_volume(volume: float) -> void:
	_music_volume = clamp(volume, 0.0, 1.0)
	_save()

func set_sfx_volume(volume: float) -> void:
	_sfx_volume = clamp(volume, 0.0, 1.0)
	_save()

func get_music_volume() -> float:
	return _music_volume

func get_sfx_volume() -> float:
	return _sfx_volume
