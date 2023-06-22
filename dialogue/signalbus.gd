extends Node

var is_end_bad:bool
var is_end_good: bool
var body = null
var boss_enabled = false

signal display_dialog(text_key)
signal loading_world
signal free
signal save
signal load_scene
signal realload
signal finished(text)
signal bossencounter
signal myid(id)
signal clearid

var queen
var world
var player
var count = 0
var label

func _input(event):
	if event.is_action_pressed("action") and is_end_bad == true:
		self.emit_signal("display_dialog", "KingWin")
	elif event.is_action_pressed("action") and is_end_good == true:
		self.emit_signal("display_dialog", "KingLose")
	elif event.is_action_pressed("action") and boss_enabled == true:
		self.emit_signal("display_dialog", "King")
		count += 1
		if count == 2:
			boss_enabled = false
	elif event.is_action_pressed("action") and queen == true:
		label.visible = false
		self.emit_signal("display_dialog", "Queen")

func _ready():
	self.set_pause_mode(2) # Set pause mode to Process
	set_process(true)
	self.connect("free",self,"on_free")
	self.connect("load_scene",self,"loadit")
	self.connect("bossencounter",self,"on_boss")

func on_free():#Freeing Boss and Player here for dialogue system
	if body != null:
		if body.name == "Player":
			get_tree().change_scene("res://Dead.tscn")
			body = null
		elif body.name == "Boss":
			body.queue_free()
			body = null

func loadit():
	yield(get_tree().create_timer(.1), "timeout")
	emit_signal("realload")

func on_boss():
	boss_enabled = true
	pass
