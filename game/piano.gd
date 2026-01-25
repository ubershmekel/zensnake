extends Node

class NoteEntry:
	var note: String
	var midi: int
	var stream: AudioStream

const BUS_SFX := "Sfx"
const FADE_SECONDS := 5.5
const SILENCE_DB := -80.0
const NOTE_EXTENSION := ".ogg"
const GENERATED_SAMPLES_SCRIPT := "res://game/piano_samples.gd"

var _note_entries: Array[NoteEntry] = []
var _nearest_by_midi: Dictionary[int, NoteEntry] = {}

func _ready() -> void:
	_load_samples()

func play(note_name: String, duration_ms: int) -> void:
	if _note_entries.is_empty():
		_load_samples()
	if _note_entries.is_empty():
		push_warning("No piano samples loaded.")
		return

	var target_midi := _note_to_midi(note_name)
	if target_midi < 0:
		push_warning("Invalid piano note: %s" % [note_name])
		return

	var entry := _find_nearest_entry(target_midi)
	if entry == null:
		push_warning("No piano samples available for note: %s" % [note_name])
		return

	var semitone_diff: int = target_midi - entry.midi

	var player := AudioStreamPlayer.new()
	player.bus = BUS_SFX
	player.stream = entry.stream
	player.pitch_scale = pow(2.0, float(semitone_diff) / 12.0)
	player.volume_db = 0.0
	add_child(player)
	player.play()

	var duration_sec: float = max(duration_ms, 0) / 1000.0
	var tween := create_tween()
	if duration_sec > 0.0:
		tween.tween_interval(duration_sec)
	tween.tween_property(player, "volume_db", SILENCE_DB, FADE_SECONDS)
	tween.finished.connect(func():
		player.stop()
		player.queue_free()
	)

func _load_samples() -> void:
	_note_entries.clear()
	_nearest_by_midi.clear()
	var note_index: Dictionary[String, AudioStream] = {}

	var generated_entries := _get_generated_entries()
	if not generated_entries.is_empty():
		_build_entries_from_generated(generated_entries, note_index)
		_finalize_entries(note_index)
		return

	var dir := DirAccess.open("res://assets/audio/piano")
	if dir == null:
		push_warning("Missing piano samples directory.")
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
	  # Skip directories
			file_name = dir.get_next()
			continue
		if not file_name.to_lower().ends_with(NOTE_EXTENSION):
	  # Only load eg .mp3 files
			file_name = dir.get_next()
			continue

		var note_name := _note_from_filename(file_name)
		if note_name == "":
			file_name = dir.get_next()
			continue

		var path := "res://assets/audio/piano/%s" % file_name
		var stream = load(path)
		if stream == null:
			file_name = dir.get_next()
			continue

		# Group same note variations by note_name.
		if note_index.has(note_name):
			file_name = dir.get_next()
			continue
		note_index[note_name] = stream
		file_name = dir.get_next()
	dir.list_dir_end()

	_finalize_entries(note_index)

func _get_generated_entries() -> Array:
	if not ResourceLoader.exists(GENERATED_SAMPLES_SCRIPT):
		return []
	var script = load(GENERATED_SAMPLES_SCRIPT)
	if script == null:
		return []
	var instance = script.new()
	if instance == null:
		return []
	var entries = instance.get("ENTRIES")
	if entries is Array:
		return entries
	return []

func _build_entries_from_generated(entries: Array, note_index: Dictionary) -> void:
	for entry in entries:
		var note_name := ""
		if typeof(entry) == TYPE_DICTIONARY:
			if entry.has("note"):
				note_name = str(entry["note"])
			if note_name == "" and entry.has("file"):
				note_name = _note_from_filename(str(entry["file"]))
		else:
			if entry.has_method("get"):
				var note_val = entry.get("note")
				if note_val != null:
					note_name = str(note_val)
				if note_name == "":
					var file_val = entry.get("file")
					if file_val != null:
						note_name = _note_from_filename(str(file_val))
		if note_name == "" or note_index.has(note_name):
			continue
		var stream = null
		if typeof(entry) == TYPE_DICTIONARY:
			if not entry.has("stream"):
				continue
			stream = entry["stream"]
		else:
			if entry.has_method("get"):
				stream = entry.get("stream")
		if stream == null:
			continue
		note_index[note_name] = stream

func _finalize_entries(note_index: Dictionary) -> void:
	for note_name in note_index.keys():
		var midi := _note_to_midi(note_name)
		if midi >= 0:
			var entry := NoteEntry.new()
			entry.note = note_name
			entry.midi = midi
			entry.stream = note_index[note_name]
			_note_entries.append(entry)

	_note_entries.sort_custom(func(a: NoteEntry, b: NoteEntry): return a.midi < b.midi)

	if _note_entries.is_empty():
		return

	var min_midi := _note_entries[0].midi
	var max_midi := _note_entries[_note_entries.size() - 1].midi
	var entry_index := 0
	for midi in range(min_midi, max_midi + 1):
		while entry_index + 1 < _note_entries.size() and _note_entries[entry_index + 1].midi <= midi:
			entry_index += 1
		var best_entry: NoteEntry = _note_entries[entry_index]
		if entry_index + 1 >= _note_entries.size():
			_nearest_by_midi[midi] = best_entry
			continue

		var next_entry := _note_entries[entry_index + 1]
		var current_distance: int = abs(midi - best_entry.midi)
		var next_distance: int = abs(midi - next_entry.midi)
		if next_distance < current_distance:
			best_entry = next_entry
		_nearest_by_midi[midi] = best_entry

func _find_nearest_entry(target_midi: int) -> NoteEntry:
	if _nearest_by_midi.has(target_midi):
		return _nearest_by_midi[target_midi]
	return null

func _note_from_filename(file_name: String) -> String:
	var regex := RegEx.new()
	regex.compile("_([A-G](?:#|b)?-?\\d+)\\" + NOTE_EXTENSION + "$")
	var result := regex.search(file_name)
	if result == null:
		return ""
	return result.get_string(1)

func _note_to_midi(note_name: String) -> int:
	var regex := RegEx.new()
	regex.compile("^([A-Ga-g])([#b]?)(-?\\d+)$")
	var result := regex.search(note_name.strip_edges())
	if result == null:
		return -1

	var letter := result.get_string(1).to_upper()
	var accidental := result.get_string(2)
	var octave := int(result.get_string(3))

	var semitone := 0
	match letter:
		"C": semitone = 0
		"D": semitone = 2
		"E": semitone = 4
		"F": semitone = 5
		"G": semitone = 7
		"A": semitone = 9
		"B": semitone = 11
		_: return -1

	if accidental == "#":
		semitone += 1
	elif accidental == "b":
		semitone -= 1

	return (octave + 1) * 12 + semitone
