extends Control

export (String, FILE, "*json") var scene_text_file

const CHAR_READ_RATE = 0.05

var scene_text = {}
var selected_text = []
var in_progress = false

var current_character = null
var next_text
var count = 0

var current_dialogue_character

onready var background = $MarginContainer
onready var text_label = $MarginContainer/Panel/MarginContainer/HBoxContainer/main

func _ready(): #Making the dialogue system invisible at first
	background.visible = false
	text_label.visible = false
	$Boss.visible = false
	$Ice.visible = false
	$Air.visible = false
	$Player.visible = false
	scene_text = load_scene_text()
	Signalbus.connect("display_dialog", self, "on_display_dialog")

func load_scene_text():#parsing through json file
	var file = File.new()
	if file.file_exists(scene_text_file):
		file.open(scene_text_file, File.READ)
		return parse_json(file.get_as_text())

func show_text(): #Show text according to character
	next_text = selected_text.pop_front()
	count += 1
	text_label.text = next_text
	text_label.percent_visible = 0.0
	$Tween.interpolate_property(text_label, "percent_visible", 0.0, 1.0, len(next_text) * CHAR_READ_RATE, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	alternate_sprites(count)

func alternate_sprites(count):
	if current_character != "KingLose":
		if count %2 == 0:
			current_dialogue_character.visible = false
			current_dialogue_character.play("default")
			$Player.visible = true
			$Player.play("default")
		if count %2 != 0:
			current_dialogue_character.visible = true
			current_dialogue_character.play("default")
			$Player.visible = false
			$Player.stop()
	if current_character == "KingLose":
		if count %2 != 0:
			current_dialogue_character.visible = false
			current_dialogue_character.play("default")
			$Player.visible = true
			$Player.play("default")
		if count %2 == 0:
			current_dialogue_character.visible = true
			current_dialogue_character.play("default")
			$Player.visible = false
			$Player.stop()

func next_line():  #Get next line in json upon ui_accept
	if selected_text.size() > 0:
		show_text()
	else:
		finish()

func finish():#finishes the dialogue scene
	count = 0
	text_label.text = ""
	$Boss.visible = false
	$Ice.visible = false
	$Air.visible = false
	$Player.visible = false
	$Player.stop()
	$Boss.stop()
	$Ice.stop()
	$Air.stop()
	background.visible = false
	in_progress = false
	get_tree().paused = false
	current_dialogue_character = null
	$"/root/Signalbus".emit_signal("free")
	
	
func on_display_dialog(text_key):  #When in display pause other things
	current_character = text_key
	set_character()
	if in_progress:
		next_line()
	elif not text_key in $"/root/SaveSystem".player["interacted"]:
		get_tree().paused = true
		background.visible = true
		text_label.visible = true
		in_progress = true
		selected_text = scene_text[text_key].duplicate()
		show_text()
		$"/root/SaveSystem".player["interacted"].append(text_key)

func set_character():
	match current_character:
		"King":
			current_dialogue_character = $Boss
		"KingWin":
			current_dialogue_character = $Boss
		"KingLose":
			current_dialogue_character = $Boss
		"Queen":
			current_dialogue_character = $Air
		"Ice":
			current_dialogue_character = $Ice
