extends Control

const file1 = "user://dialogues.json"
var dialogues = {
	"Ice":[
		"Uh, what do you need? Why have you come here?",
		"I need your help. I need to go to the Earth Kingdom.",
		"Why I should tell you about it?",
		"You have to you have no other choice",
		"I see, ok then, my lord.",
		"Help me",
		"I will open a portal and teleport you there..."
	],
	"Queen":[
		"Thank you,I have never expected this from you! ",
		"....Why?",
		"I never considered you that strong",
		"Ah.... Let's go"
	],
	"King":[
		"You are a fool to think you can destroy me",
		"We will see that"
	],
	"KingWin": [
		"HAHA, told you now die"
	],
	"KingLose": [
		"I don't understand why you did this",
		"Because you killed my trees and small plants....",
		"when",
		"during your very so-called “Intense Training”",
		"There were other ways by which you can handle this"

	],
	"Save":[
		"Do you want to save?\nYes         No"
	]
}

export (String, FILE, "*json") var scene_text_file

const CHAR_READ_RATE = 0.05

var scene_text = {}
var selected_text = []
var in_progress = false

var current_character = null
var next_text
var count = 0
var is_save_mode:bool = false


var current_dialogue_character

onready var background = $MarginContainer
onready var text_label = $MarginContainer/Panel/MarginContainer/HBoxContainer/main

func _ready(): #Making the dialogue system invisible at first
	save_file()
	background.visible = false
	text_label.visible = false
	$Boss.visible = false
	$Ice.visible = false
	$Air.visible = false
	$Player.visible = false
	$Sprite.visible = false
	scene_text = load_scene_text()
	Signalbus.connect("display_dialog", self, "on_display_dialog")

func save_file():
	var file = File.new()
	file.open(file1, File.WRITE)
	file.store_string(to_json(dialogues))
	file.close()

func load_scene_text():#parsing through json file
	var file = File.new()
	if file.file_exists(file1):
		file.open(file1, File.READ)
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
	$Sprite.visible = false
	$Player.stop()
	$Sprite.stop()
	$Boss.stop()
	$Ice.stop()
	$Air.stop()
	is_save_mode = false
	background.visible = false
	in_progress = false
	get_tree().paused = false
	current_dialogue_character = null
	$"/root/Signalbus".emit_signal("free")
	Signalbus.emit_signal("finished")
	
	
func on_display_dialog(text_key):  #When in display pause other things
	current_character = text_key
	set_character()
	if in_progress:
		next_line()
	elif current_dialogue_character == $Sprite:
		savehandler()
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
		"Save":
			current_dialogue_character = $Sprite

func savehandler():
	is_save_mode =true
	get_tree().paused = true
	in_progress = true
	background.visible = true
	text_label.visible = true
	selected_text = scene_text[current_character].duplicate()
	show_text()

func _input(event):
	if (event.is_action("ui_accept")) and is_save_mode== true:
		if $MarginContainer/Panel/MarginContainer/yes.visible == true:
			save()
			finish()
		elif $MarginContainer/Panel/MarginContainer/no.visible == true:
			finish()
	elif (event.is_action_pressed("ui_left")) and $MarginContainer/Panel/MarginContainer/yes.visible == true:
		$MarginContainer/Panel/MarginContainer/yes.visible = false
		$MarginContainer/Panel/MarginContainer/no.visible = true
		$MarginContainer/Panel/MarginContainer/no.play("default")
	elif event.is_action_pressed("ui_left") and $MarginContainer/Panel/MarginContainer/no.visible == true:
		$MarginContainer/Panel/MarginContainer/no.visible = false
		$MarginContainer/Panel/MarginContainer/yes.visible = true
		$MarginContainer/Panel/MarginContainer/yes.play("default")
	elif event.is_action_pressed("ui_right") and $MarginContainer/Panel/MarginContainer/yes.visible == true:
		$MarginContainer/Panel/MarginContainer/yes.visible = false
		$MarginContainer/Panel/MarginContainer/no.visible = true
		$MarginContainer/Panel/MarginContainer/no.play("default")
	elif event.is_action_pressed("ui_right") and $MarginContainer/Panel/MarginContainer/no.visible == true:
		$MarginContainer/Panel/MarginContainer/no.visible = false
		$MarginContainer/Panel/MarginContainer/yes.visible = true
		$MarginContainer/Panel/MarginContainer/yes.play("default")

func save():
	Signalbus.emit_signal("save")
	SaveSystem.save_file()

func _on_Tween_tween_completed(object, key):
	if current_dialogue_character == $Sprite:
		$MarginContainer/Panel/MarginContainer/yes.visible = true
		$MarginContainer/Panel/MarginContainer/yes.play("default")
