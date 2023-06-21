extends Node2D

export var tint := Color.white
export var frames: SpriteFrames
export var emit_tick_threshold = 0.185

export var path_sorting_ref: NodePath
var sorting_ref: Node

var is_active := false
var last_tick: float = 0.0

var scene_ref: Node
var sprite_refs: Array = []

func _ready() -> void:
	sorting_ref = get_node_or_null(path_sorting_ref)
	
	# If a sorting reference is provided, use that to determine
	# where to place the particle nodes
	if sorting_ref == null:
		scene_ref = get_tree().current_scene
	else:
		scene_ref = sorting_ref.get_parent()

func _process(delta: float) -> void:
	if !is_active:
		return
	
	last_tick += delta
	
	if last_tick <= emit_tick_threshold:
		return

	last_tick = 0.0
	_play()

func _notification(what: int) -> void:
	# When this object is deleted,
	# free all of its associated particle nodes
	if what != NOTIFICATION_PREDELETE:
		return
	
	for sprite_ref in sprite_refs:
		if !is_instance_valid(sprite_ref):
			continue
		
		sprite_ref.queue_free()

func _play() -> void:
	var sprite = _get_sprite()
	
	sprite.global_position = global_position
	sprite.visible = true
	
	sprite.play()

func _get_sprite() -> AnimatedSprite:
	# Reuse existing nodes, if possible
	for sprite in sprite_refs:
		if sprite.playing:
			continue
		
		return sprite
	
	var new_sprite = AnimatedSprite.new()
	new_sprite.connect("animation_finished", self, "_on_death", [new_sprite])
	
	new_sprite.scale = scale
	new_sprite.modulate = tint
	new_sprite.frames = frames
	
	sprite_refs.append(new_sprite)
	scene_ref.add_child(new_sprite)
	
	if is_instance_valid(sorting_ref):
		scene_ref.move_child(new_sprite, 0)
	
	return new_sprite

func _on_death(sprite_ref: AnimatedSprite) -> void:
	sprite_ref.visible = false
	sprite_ref.playing = false
