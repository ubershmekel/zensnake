extends Node

const CONFIG_PATH := "user://settings.cfg"
const SECTION_AUDIO := "audio"
const KEY_MUSIC_is_playing := "music_is_playing"
const KEY_SFX_is_playing := "sfx_is_playing"

var _music_is_playing := false
var _sfx_is_playing := false


func _ready() -> void:
	_load()

func _load() -> void:
	var config := ConfigFile.new()
	var err := config.load(CONFIG_PATH)
	if err == OK:
		_music_is_playing = config.get_value(SECTION_AUDIO, KEY_MUSIC_is_playing, false)
		_sfx_is_playing = config.get_value(SECTION_AUDIO, KEY_SFX_is_playing, false)
	else:
		_music_is_playing = false
		_sfx_is_playing = false

func _save() -> void:
	var config := ConfigFile.new()
	config.set_value(SECTION_AUDIO, KEY_MUSIC_is_playing, _music_is_playing)
	config.set_value(SECTION_AUDIO, KEY_SFX_is_playing, _sfx_is_playing)
	var err := config.save(CONFIG_PATH)
	if err != OK:
		push_warning("Failed to save settings: %s" % [err])

func set_music_is_playing(is_playing: bool) -> void:
	_music_is_playing = is_playing
	_save()

func set_sfx_is_playing(is_playing: bool) -> void:
	_sfx_is_playing = is_playing
	_save()

func is_music_is_playing() -> bool:
	return _music_is_playing

func is_sfx_is_playing() -> bool:
	return _sfx_is_playing
