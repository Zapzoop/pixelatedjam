extends Control

export (String, FILE, "*json") var scene_text_file

var scene_text = {}
var selected_text = []
var in_progress = false

onready var background = $TextureRect
onready var text_label = $Label

func _ready(): #Making the dialogue system invisible at first
	background.visible = false
	text_label.visible = false
	scene_text = load_scene_text()
	Signalbus.connect("display_dialog", self, "on_display_dialog")

func load_scene_text():#parsing through json file
	var file = File.new()
	if file.file_exists(scene_text_file):
		file.open(scene_text_file, File.READ)
		return parse_json(file.get_as_text())

func show_text(): #Show text according to character
	text_label.text = selected_text.pop_front()

func next_line():  #Get next line in json upon ui_accept
	if selected_text.size() > 0:
		show_text()
	else:
		finish()

func finish():#finishes the dialogue scene
	text_label.text = ""
	background.visible = false
	in_progress = false
	get_tree().paused = false
	
func on_display_dialog(text_key): #When in display pause other things
	if in_progress:
		next_line()
	else:
		get_tree().paused = true
		background.visible = true
		text_label.visible = true
		in_progress = true
		selected_text = scene_text[text_key].duplicate()
		show_text()

