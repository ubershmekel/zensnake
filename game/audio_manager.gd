extends Node

var music_player: AudioStreamPlayer
var song = preload("res://assets/audio/Wholesome2.mp3")
var play_head = 0;

const BUS_MUSIC := "Music"
const BUS_SFX := "Sfx"


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.stream = song
	music_player.bus = BUS_MUSIC
	#music_player.volume_db = linear_to_db(0.1)
	add_child(music_player)
	music_yes()

func sfx_no():
	# stop the SFX bus
	AudioServer.set_bus_mute(AudioServer.get_bus_index(BUS_SFX), true)

func sfx_yes():
	AudioServer.set_bus_mute(AudioServer.get_bus_index(BUS_SFX), false)

func music_yes():
	music_player.play(play_head)
	# play(SfxId.EAT3)

func music_no():
	play_head = music_player.get_playback_position()
	music_player.stop()

enum SfxId {EAT1, EAT2, EAT3}


var sfx: Dictionary = {
	SfxId.EAT1: preload("res://assets/audio/sfx/b4b.mp3"),
	SfxId.EAT2: preload("res://assets/audio/sfx/gs3b.mp3"),
	SfxId.EAT3: preload("res://assets/audio/sfx/e3b.mp3"),
}

func play_eat():
	const options = [SfxId.EAT1, SfxId.EAT2, SfxId.EAT3]
	var choice = options[randi() % options.size()]
	play(choice)

func play(id: SfxId) -> void:
	if not sfx.has(id):
		push_warning("Unknown SFX id: %s" % [id])
		return

	var player := AudioStreamPlayer.new()
	add_child(player)
	player.bus = BUS_SFX
	player.volume_db = linear_to_db(0.5)
	player.stream = sfx[id]
	player.finished.connect(func(): player.queue_free())
	player.play()
