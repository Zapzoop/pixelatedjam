extends Control

export (String, FILE, "*json") var scene_text_file

const CHAR_READ_RATE = 0.05

var interacted = []

var scene_text = {}
var selected_text = []
var in_progress = false

var ice = preload("res://temp/download (3).jpg") #changre spites
var queen = preload("res://temp/download.jpg")
var king = preload("res://temp/download (1).jpg")
var sage = preload("res://temp/download (2).jpg")

var current_character = null
var next_text
var count = 0

onready var background = $MarginContainer
onready var text_label = $MarginContainer/Panel/MarginContainer/HBoxContainer/main

func _ready(): #Making the dialogue system invisible at first
	background.visible = false
	text_label.visible = false
	$Sprite.visible = false
	$AnimatedSprite.visible = false
	scene_text = load_scene_text()
	Signalbus.connect("display_dialog", self, "on_display_dialog")

func load_scene_text():#parsing through json file
	var file = File.new()
	if file.file_exists(scene_text_file):
		file.open(scene_text_file, File.READ)
		return parse_json(file.get_as_text())




func show_text(): #Show text according to character\
	next_text = selected_text.pop_front()
	count += 1
	text_label.text = next_text
	text_label.percent_visible = 0.0
	$Tween.interpolate_property(text_label, "percent_visible", 0.0, 1.0, len(next_text) * CHAR_READ_RATE, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	alternate_sprites(count)
	#if next_text[-1] == ";":
#		print("good")
#		reply(next_text)

func alternate_sprites(count):
	print(count)
	if current_character != "kinglose":
		if count %2 == 0:
			print("1")
			$Sprite.visible = false
			$AnimatedSprite.visible = true
			$AnimatedSprite.play("default")
		if count %2 != 0:
			print("2")
			$Sprite.visible = true
			$AnimatedSprite.visible = false
			$AnimatedSprite.stop()
	if current_character == "kinglose":
		if count %2 != 0:
			$Sprite.visible = false
			$AnimatedSprite.visible = true
			$AnimatedSprite.play("default")
		if count %2 == 0:
			$Sprite.visible = true
			$AnimatedSprite.visible = false
			$AnimatedSprite.stop()
#func reply():
#	if next_text[-1] == ";":
#		var replies = {"Uh, what do you need? Why have you come here?;":" I have come here because I need your help. I need to go to the Earth Kingdom.",
#						"Why I should tell you about it?":"You have to you have no other choice",}
#		var replytext = replies[next_text]
#		text_label.text = replytext
#		text_label.percent_visible = 0.0
#		$Tween.interpolate_property(text_label, "percent_visible", 0.0, 1.0, len(replytext) * CHAR_READ_RATE, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#		$Tween.start()



func next_line():  #Get next line in json upon ui_accept
	if selected_text.size() > 0:
		show_text()
	else:
		finish()

func finish():#finishes the dialogue scene
	count = 0
	text_label.text = ""
	$Sprite.visible = false
	$AnimatedSprite.visible = false
	$AnimatedSprite.stop()
	background.visible = false
	in_progress = false
	get_tree().paused = false
	
func on_display_dialog(text_key):  #When in display pause other things
	current_character = text_key
	set_character()
	if in_progress:
		next_line()
	elif not text_key in interacted:
		get_tree().paused = true
		background.visible = true
		text_label.visible = true
		in_progress = true
		selected_text = scene_text[text_key].duplicate()
		show_text()
		interacted.append(text_key)

func set_character():
	match current_character:
		"king":
			$Sprite.set_texture(king)
		"kingwin":
			$Sprite.set_texture(king)
		"kinglose":
			$Sprite.set_texture(king)
		"queen":
			$Sprite.set_texture(queen)
		"ice":
			$Sprite.set_texture(ice)
		"sage":
			$Sprite.set_texture(sage)
