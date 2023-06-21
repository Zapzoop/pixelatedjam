extends KinematicBody2D

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")

export var ACCELERATION = 500
export var MAX_SPEED = 70
export var ROLL_SPEED = 140
export var FRICTION = 500

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats
var current_attacking
var last_attacking
var is_end_bad :bool


onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var footstepEffect = $FootstepEffect

func _ready():
	randomize()
	stats.connect("no_health", self, "death_handler")
	Signalbus.connect("save",self,"upload")
	Signalbus.connect("realload",self,"set_load")
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		
		ROLL:
			roll_state()
		
		ATTACK:
			attack_state()

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		footstepEffect.is_active = true
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		footstepEffect.is_active = false		
	
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func move():
	velocity = move_and_slide(velocity)

func roll_animation_finished():
	velocity = velocity * 0.8
	state = MOVE

func attack_animation_finished():
	state = MOVE

func death_handler():
	if current_attacking == "Boss" or last_attacking == "Boss":
		$"/root/Signalbus".body = self
		$"/root/Signalbus".is_end_bad = true
		Signalbus.emit_signal("display_dialog", "KingWin")
	#queue_free()#change scene here
	get_tree().change_scene("res://Dead.tscn")
	#Body is queue_free in signalbus via dialogue when died by boss

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.6)
	hurtbox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)
	
func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")

func _on_Interaction_body_entered(body):
	current_attacking = body.name
	last_attacking= current_attacking
	
func _on_Interaction_body_exited(body):
	current_attacking = null
	
func upload():
	SaveSystem.player["health"] = stats.health
	var pos = get_global_position()
	SaveSystem.player["position"] = {"x":pos.x,"y":pos.y}

func set_load():
	stats.health = SaveSystem.player["health"]
	var loadpos = SaveSystem.player["position"]
	var pos = Vector2(loadpos["x"],loadpos["y"])
	set_global_position(pos)
