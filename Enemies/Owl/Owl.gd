extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 70
export var MAX_SPEED = 40
export var FRICTION = 233
export var WANDER_TARGET_RANGE = 5
export var NEAR_DISTANCE = 90.0
export var DASH_COOLDOWN = 2.5
export var DASH_FORCE = 40.0

export var pkg_mine: PackedScene

enum {
	IDLE,
	WANDER,
	CHASE
}

var force := Vector2.ZERO
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var dash_cooldown = DASH_COOLDOWN
var state = CHASE

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer
onready var footstep_fx = $FootstepEffect

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	force = force.move_toward(Vector2.ZERO, FRICTION * delta)
	
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback + force)
	
	footstep_fx.is_active = state != IDLE
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
				
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
			accelerate_towards_point(wanderController.target_position, delta)
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				update_wander()
			
		CHASE:
			var player = playerDetectionZone.player
			
			if player == null:
				state = IDLE
				return
			
			var player_position = player.global_position
			var is_near = global_position.distance_squared_to(player_position) < (NEAR_DISTANCE * NEAR_DISTANCE)
		
			dash_cooldown = max(0.0, dash_cooldown - delta)	
			accelerate_towards_point(player_position, delta)
			
			if is_near && dash_cooldown < 0.1:		
				force += global_position.direction_to(player_position) * DASH_FORCE
				dash_cooldown = DASH_COOLDOWN
				
				var mine = pkg_mine.instance()
				owner.get_parent().add_child(mine)
				
				mine.global_position = global_position

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0
	
	var orientation = direction.dot(Vector2.UP)
	
	if orientation >= 0.75:
		sprite.animation = "up"
	elif orientation <= -0.75:
		sprite.animation = "down"
	else:
		sprite.animation = "right"

func move_around_point(point: Vector2, delta: float) -> void:
	pass

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 110
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

func _on_Hurtbox_invincibility_started():
	animationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("Stop")
