extends StaticBody2D

enum NamedEnum {SAVE, REGEN, Null}
export(NamedEnum) var State
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var envo = preload("res://save/save.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	get_state()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func get_state():
	match State:
		0:
			make_save()
		1:
			make_regen()
func make_save():
	$Particles2D.visible = false
	$Sprite2.visible = false

func make_regen():
	$Particles2D.visible = true
	$WorldEnvironment.set_environment(envo)
	$Sprite2.visible = true
	
func disable():
	$Particles2D.visible = false
	$Sprite2.visible = false
	State = NamedEnum.Null
	
func _input(event):
	if event.is_action_pressed("action") and State == 1:
		if PlayerStats.health != 4:
			PlayerStats.health += 1
			disable()
