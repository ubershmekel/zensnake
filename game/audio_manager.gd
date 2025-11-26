extends Node

var music_player: AudioStreamPlayer
var song = preload("res://assets/audio/Wholesome2.mp3")
var play_head = 0;

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.stream = song
	music_player.bus = "Music"
	add_child(music_player)

func play_music():
	music_player.play(play_head)
	play(SfxId.EAT3)
	

func stop_music():
	play_head = music_player.get_playback_position()
	music_player.stop()

enum SfxId {EAT1, EAT2, EAT3}

const BUS_SFX := "Sfx"

var sfx: Dictionary = {
	SfxId.EAT1: preload("res://assets/audio/sfx/b4b.mp3"),
	SfxId.EAT2: preload("res://assets/audio/sfx/gs3b.mp3"),
	SfxId.EAT3: preload("res://assets/audio/sfx/e3b.mp3"),
}

func play(id: SfxId) -> void:
	if not sfx.has(id):
		push_warning("Unknown SFX id: %s" % [id])
		return

	var player := AudioStreamPlayer.new()
	add_child(player)
	player.bus = BUS_SFX
	player.stream = sfx[id]
	player.finished.connect(func(): player.queue_free())
	player.play()
