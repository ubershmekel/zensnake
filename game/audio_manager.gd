extends Node

enum SfxId {EAT1, EAT2, EAT3}


var sfx: Dictionary = {
	SfxId.EAT1: preload("res://assets/audio/sfx/b4b.mp3"),
	SfxId.EAT2: preload("res://assets/audio/sfx/gs3b.mp3"),
	SfxId.EAT3: preload("res://assets/audio/sfx/e3b.mp3"),
}

const BUS_MUSIC := "Music"
const BUS_SFX := "Sfx"

var music_player: AudioStreamPlayer
var song = preload("res://assets/audio/Wholesome2.mp3")
var play_head = 0
# _music_is_playing is defaulted to false because when the app starts
# we want the music to start up (go from false to true)
var _music_is_playing := false
var _sfx_is_playing := true


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.stream = song
	music_player.bus = BUS_MUSIC
	add_child(music_player)
	set_sfx_is_playing(Settings.is_sfx_is_playing())
	set_music_is_playing(Settings.is_music_is_playing())


func set_sfx_is_playing(is_playing: bool) -> void:
	if is_playing == _sfx_is_playing:
		return

	_sfx_is_playing = is_playing
	AudioServer.set_bus_mute(AudioServer.get_bus_index(BUS_SFX), !is_playing)
	Settings.set_sfx_is_playing(is_playing)

func set_music_is_playing(is_playing: bool) -> void:
	if is_playing == _music_is_playing:
		return

	_music_is_playing = is_playing
	if is_playing:
		music_player.play(play_head)
		music_player.stream.loop = true
	else:
		play_head = music_player.get_playback_position()
		music_player.stop()
	Settings.set_music_is_playing(is_playing)

func is_music_enabled() -> bool:
	return _music_is_playing

func is_sfx_enabled() -> bool:
	return _sfx_is_playing

func play_eat():
	const options = [SfxId.EAT1, SfxId.EAT2, SfxId.EAT3]
	var choice = options[randi() % options.size()]
	play(choice)

func play(id: SfxId) -> void:
	if !_sfx_is_playing:
		return

	if not sfx.has(id):
		push_warning("Unknown SFX id: %s" % [id])
		return

	var player := AudioStreamPlayer.new()
	add_child(player)
	player.bus = BUS_SFX
	player.volume_db = linear_to_db(0.3)
	player.stream = sfx[id]
	player.finished.connect(func(): player.queue_free())
	player.play()
