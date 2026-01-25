extends Node

enum SfxId {EAT1, EAT2, EAT3, BURP1, BURP2, BURP3, BURP4, BURP5}


var sfx: Dictionary = {
	SfxId.EAT1: preload("res://assets/audio/sfx/b4b.mp3"),
	SfxId.EAT2: preload("res://assets/audio/sfx/gs3b.mp3"),
	SfxId.EAT3: preload("res://assets/audio/sfx/e3b.mp3"),
	SfxId.BURP1: preload("res://assets/audio/burps/burp1.mp3"),
	SfxId.BURP2: preload("res://assets/audio/burps/burp2.mp3"),
	SfxId.BURP3: preload("res://assets/audio/burps/burp3.mp3"),
	SfxId.BURP4: preload("res://assets/audio/burps/burp4.mp3"),
	SfxId.BURP5: preload("res://assets/audio/burps/burp5.mp3"),
}

const BUS_MUSIC := "Music"
const BUS_SFX := "Sfx"

var music_player: AudioStreamPlayer
var song = preload("res://assets/audio/music/yoga-music-456102.mp3")
var play_head = 0
var _music_volume := 1.0
var _sfx_volume := 1.0
@onready var piano := preload("res://game/piano.gd").new()

const PIANO_EAT_NOTES = ["G2", "D2", "G3", "D3", "G4", "D4"]
var piano_eat_i = 0;
const PIANO_EAT_DURATION_MS := 920


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player = AudioStreamPlayer.new()
	music_player.stream = song
	music_player.bus = BUS_MUSIC
	add_child(music_player)
	add_child(piano)
	set_music_volume(Settings.get_music_volume())
	set_sfx_volume(Settings.get_sfx_volume())
	music_player.play(play_head)
	music_player.stream.loop = true


func set_music_volume(volume: float) -> void:
	_music_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_MUSIC), linear_to_db(_music_volume))
	Settings.set_music_volume(_music_volume)

func set_sfx_volume(volume: float) -> void:
	_sfx_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_SFX), linear_to_db(_sfx_volume))
	Settings.set_sfx_volume(_sfx_volume)

func get_music_volume() -> float:
	return _music_volume

func get_sfx_volume() -> float:
	return _sfx_volume

func play_eat():
	if piano == null:
		return

	var note = PIANO_EAT_NOTES[randi() % PIANO_EAT_NOTES.size()]
	#var note = PIANO_EAT_NOTES[piano_eat_i]
	#piano_eat_i = (piano_eat_i + 1) % PIANO_EAT_NOTES.size()
	piano.play(note, PIANO_EAT_DURATION_MS)

func play_burp():
	const options = [SfxId.BURP1, SfxId.BURP2, SfxId.BURP3, SfxId.BURP4, SfxId.BURP5]
	var choice = options[randi() % options.size()]
	play(choice)

func play(id: SfxId) -> float:
	if not sfx.has(id):
		push_warning("Unknown SFX id: %s" % [id])
		return 0.0

	var player := AudioStreamPlayer.new()
	add_child(player)
	player.bus = BUS_SFX
	player.volume_db = linear_to_db(0.3)
	player.stream = sfx[id]
	player.finished.connect(func(): player.queue_free())
	player.play()
	return sfx[id].get_length()
