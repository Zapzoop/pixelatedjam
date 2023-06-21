extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

const RAGE_DASH_THRESH = 0.35
const RAGE_SPAM_THRESH = 5.0
const RAGE_TRACKING_ATTACK_THRESH = 1.0
const RAGE_AOE_THRESH = 0.1

export var ACCELERATION = 70
export var MAX_SPEED = 40
export var FRICTION = 170
export var WANDER_TARGET_RANGE = 5

export var SHOW_HEALTHBAR := false

export var NEAR_DISTANCE = 90.0
export var DASH_COOLDOWN = 5.5
export var DASH_FORCE = 43.0
export var CAST_COOLDOWN = 6.0
export var SPAWN_COOLDOWN = 20.0
export var SHOOT_COOLDOWN = 12.0
export var SHOOT_CHANCE = 0.35

export var SHOOTS_PROJECTILES = true

export var pkg_mine: PackedScene
export var pkg_projectile: PackedScene
export var pkg_aoe_attack: PackedScene
export var pkg_minion: PackedScene
export var pkg_spawn_effect: PackedScene

enum {
	IDLE,
	WANDER,
	CHASE,
	SUMMON,
	CAST
}

var force := Vector2.ZERO
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var spawn_cooldown = SPAWN_COOLDOWN
var dash_cooldown = DASH_COOLDOWN
var cast_cooldown = CAST_COOLDOWN
var shoot_cooldown = SHOOT_COOLDOWN

var rage = 0.0
var state = CHASE

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var hitbox = $Hitbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer
onready var footstep_fx = $FootstepEffect
onready var projectile_origin = $projectile_spawn_point
onready var spawn_parent = get_parent()

onready var healthbar = get_node("%BossHealthBar")

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _process(delta: float) -> void:
	var is_idle = state == IDLE || state == SUMMON || state == CAST
	
	footstep_fx.is_active = !is_idle
	sprite.playing = !is_idle
	
	rage = max(0.0, rage - (0.035 * delta))
	
	if !playerDetectionZone.can_see_player():
		healthbar.visible = false
		return
	
	if SHOW_HEALTHBAR:
		healthbar.visible = true

	if rage > RAGE_DASH_THRESH:
		dash_cooldown = max(0.0, dash_cooldown - delta)	
	
	if rage > RAGE_AOE_THRESH:
		cast_cooldown = max(0.0, cast_cooldown - delta)

	spawn_cooldown = max(0.0, spawn_cooldown - delta)
	shoot_cooldown = max(0.0, shoot_cooldown - delta)
	
	if SHOOTS_PROJECTILES && shoot_cooldown < 0.1:
		_shoot_tracking_projectiles()
		
	if spawn_cooldown < 0.1:
		_set_lock_state(false)
		sprite.play("summon")
		state = SUMMON
	
	if cast_cooldown < 0.1:
		_set_lock_state(false)
		sprite.play("special")
		state = CAST

func _physics_process(delta):
	force = force.move_toward(Vector2.ZERO, FRICTION * delta)
	
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback + force)
	
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
		
			accelerate_towards_point(player_position, delta)
			
			if rage > RAGE_DASH_THRESH && is_near && dash_cooldown < 0.1:
				var tree = get_tree()
				
				if rage < RAGE_SPAM_THRESH:
					dash_cooldown = DASH_COOLDOWN
				else:
					# Chance to chain into other attacks
					if rand_range(0.0, 1.0) < 0.15:
						if rand_range(0.0, 1.0) <= 0.5:
							dash_cooldown = 0.5
						else:
							cast_cooldown = 0.5
					else:
						dash_cooldown = DASH_COOLDOWN * 0.5
				
				var dash_dir = global_position.direction_to(player_position)
				force += dash_dir * -25.0
				
				for _frame in range(150):
					yield(tree, "idle_frame")
				
				# Chance to spawn a trail of AOE blasts
				if rage > RAGE_SPAM_THRESH && rand_range(0.0, 1.0) < 0.35:
					_start_aoe_attack(1)
				
				var dash_bias = dash_dir.rotated(PI * rand_range(-0.5, 0.5))
				
				dash_dir = dash_dir.linear_interpolate(dash_bias, rand_range(0.1, 0.35))
				force += dash_dir * DASH_FORCE
				
				_spawn_mine()

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 150
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
	knockback = area.knockback_vector * 95
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)

	# Force rage in low health
	if (float(stats.health) / float(stats.max_health)) <= 0.4:
		rage = 10.0
	else:
		rage = min(10.0, rage + area.damage * 0.15)	

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

func _on_Hurtbox_invincibility_started():
	animationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("Stop")

func _on_animation_frame_changed() -> void:
	if state != CAST && state != SUMMON:
		return
	
	if state == SUMMON && sprite.frame == 3:
		spawn_cooldown = SPAWN_COOLDOWN
		_spawn_minions()

	if state == CAST && sprite.frame == 5:
		_start_aoe_attack(randi() % 4)
		
		if rage < RAGE_SPAM_THRESH:
			cast_cooldown = CAST_COOLDOWN
		else:
			cast_cooldown = CAST_COOLDOWN * 0.5

func _on_animation_finished() -> void:
	if state != CAST && state != SUMMON:
		return
	
	force = Vector2.ZERO
	velocity = Vector2.ZERO
	knockback = Vector2.ZERO
	
	state = IDLE
	_set_lock_state(true)

func _set_lock_state(is_unlocked: bool) -> void:
	set_process(is_unlocked)
	set_physics_process(is_unlocked)

func _start_aoe_attack(type: int) -> void:
	"""
	AOE Attack type
	0: expanding
	1: linear (towards the player)
	2: targetted (spawns on the player's position)
	3: random
	"""
	if !is_instance_valid(playerDetectionZone.player):
		return
	
	var tree = get_tree()
	
	match type:
		0:
			var dirs = [
				Vector2.RIGHT,
				Vector2.UP,
				(0.5 * Vector2.RIGHT) + (0.5 * Vector2.UP),
				(0.5 * Vector2.RIGHT) + (0.5 * Vector2.DOWN)
			]
			
			var distance = 1.0
			var cycles = 12 if rage > RAGE_SPAM_THRESH else 3
			var caster_pos = global_position
			
			for _cycle in range(cycles):
				for dir in dirs:
					for i in [-1.0, 1.0]:
						_spawn_aoe_blast(caster_pos + (dir * i) * 16.0 * distance)
				
				distance += 1.5
				
				for _frame in range(30):
					yield(tree, "idle_frame")
		
		1:
			var distance = 1.0
			var cycles = 16 if rage > RAGE_SPAM_THRESH else 32
			
			var caster_pos = global_position			
			var target_dir = caster_pos.direction_to(playerDetectionZone.player.global_position)
			var rage_mode = rage > RAGE_SPAM_THRESH
			
			for cycle in range(cycles):
				if !rage_mode:
					var spawn_bias = Vector2(
						rand_range(-1.0, 1.0),
						rand_range(-1.0, 1.0)
					).normalized()
					
					_spawn_aoe_blast(caster_pos + (target_dir + spawn_bias * rand_range(0.05, 0.25)) * 8.0 * cycle)
				else:
					for _x in range(5):
						var spawn_bias = Vector2(
							rand_range(-1.5, 1.5),
							rand_range(-1.5, 1.5)
						).normalized()
						
						_spawn_aoe_blast(caster_pos + (target_dir + spawn_bias * rand_range(0.05, 0.25)) * 32.0 * cycle)
				
				for _frame in range(24):
					yield(tree, "idle_frame")
		
		2:
			var cycles = 3 if rage < RAGE_SPAM_THRESH else 5
			_spawn_mine()
			
			for cycle in range(cycles):
				if !is_instance_valid(playerDetectionZone.player):
					return
				
				_spawn_aoe_blast(playerDetectionZone.player.global_position)
				
				for _frame in range(150):
					yield(tree, "idle_frame")
		
		3:
			var caster_pos = global_position
			
			var cycles = 32 if rage < RAGE_SPAM_THRESH else 50
			var cycle_speed = 32 if rage < RAGE_SPAM_THRESH else 16
			
			for _cycle in range(cycles):
				var aoe_attack = pkg_aoe_attack.instance()
				spawn_parent.add_child(aoe_attack)
				
				var spawn_bias = Vector2(
					rand_range(-128.0, 128.0),
					rand_range(-128.0, 128.0)
				)
				
				aoe_attack.global_position = caster_pos + spawn_bias
				
				for _frame in range(cycle_speed):
					yield(tree, "idle_frame")

func _spawn_aoe_blast(position: Vector2) -> void:
	var aoe_attack = pkg_aoe_attack.instance()
	spawn_parent.add_child(aoe_attack)
	
	aoe_attack.global_position = position

func _shoot_tracking_projectiles() -> void:
	if rage < RAGE_SPAM_THRESH:
		shoot_cooldown = SHOOT_COOLDOWN
	else:
		shoot_cooldown = SHOOT_COOLDOWN * 0.7
	
	if rand_range(0.0, 1.0) < SHOOT_CHANCE:
		return
	
	var count: int
	
	if rage < RAGE_SPAM_THRESH:
		count = 2 + randi() % 2
	else:
		count = 3 + randi() % 5
	
	var tree = get_tree()
	var spawn_pos = projectile_origin.global_position
	var player = playerDetectionZone.player
	
	for _cycle in range(count):
		if !is_instance_valid(player):
			return
		
		var projectile = pkg_projectile.instance()
		spawn_parent.add_child(projectile)
		
		projectile.set_projectile_target(player, spawn_pos)
		
		if count > 1:
			for _frame in range(32):
				yield(tree, "idle_frame")

func _spawn_mine() -> void:
	var mine = pkg_mine.instance()
	owner.get_parent().add_child(mine)
	
	mine.global_position = global_position

func _spawn_minions() -> void:
	var minion_count: int
	
	if rage < RAGE_SPAM_THRESH:
		minion_count = 1 + randi() % 2
	else:
		minion_count = 2 + randi() % 4
		
		if rand_range(0.0, 1.0) < 0.4:
			_teleport_near_player()
	
	var current_position = global_position
	var tree = get_tree()
	
	for _count in range(minion_count):
		var minion = pkg_minion.instance()
		spawn_parent.add_child(minion)
		
		var spawn_offset = Vector2(
			rand_range(-45.0, 45.0),
			rand_range(-45.0, 45.0)
		)
		
		var spawn_position = current_position + spawn_offset
		var effect = pkg_spawn_effect.instance()
	
		spawn_parent.add_child(effect)
		
		effect.global_position = spawn_position
		minion.global_position = spawn_position
		
		for _frame in range(24):
			yield(tree, "idle_frame")

func _teleport_near_player() -> void:		
	var tree = get_tree()
	
	visible = false
	hitbox.monitorable = false
	hitbox.monitoring = false
	
	for _frame in range(200 + randi() % 250):
		yield(tree, "idle_frame")
	
	var offset = Vector2(
		rand_range(-16.0, 16.0),
		rand_range(-16.0, 16.0)
	)
	
	if !is_instance_valid(playerDetectionZone.player):
		visible = true
		return

	var spawn_pos = playerDetectionZone.player.global_position + offset
	
	var effect = pkg_spawn_effect.instance()
	spawn_parent.add_child(effect)
	
	visible = true
	
	effect.global_position = spawn_pos
	global_position = spawn_pos
	
	hitbox.monitorable = true
	hitbox.monitoring = true
	
