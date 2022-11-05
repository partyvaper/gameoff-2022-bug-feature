extends CharacterBody3D

class_name Entity3D

signal inventory_change
signal slots_change

@export var sprite_frames: SpriteFrames = null
@export var type: Entities.TYPES = Entities.TYPES.Friendly

# State
# TODO: Figre out how to get rid of these strings? Attach scripts to Node elements in tree?
var fsm: FSM = FSM.new({
	Entities.STATES.Standing: load('res://src/entities/states/Standing.gd').new(),
	Entities.STATES.Walking: load('res://src/entities/states/Walking.gd').new(),
	Entities.STATES.Wandering: load('res://src/entities/states/Wandering.gd').new(),
	Entities.STATES.Chasing: load('res://src/entities/states/Chasing.gd').new(),
	Entities.STATES.Attacking: load('res://src/entities/states/Attacking.gd').new(),
	Entities.STATES.Defending: load('res://src/entities/states/Defending.gd').new(),
	Entities.STATES.Death: load('res://src/entities/states/Death.gd').new(),
})

# Properties
var attack_restore_speed: float = 75.0 # units per second? not sure
var health_restore_speed: float = 10.0 # units per second? not sure
var movement_speed: int = 4 # m/s? # TODO: Somehow integrate with navigationagent max speed?
var magic_speed: int = 7 # m/s?
var magic_direction: Vector3 = Vector3.ZERO
var magic_direction2: Vector3 = Vector3.ZERO
var last_direction: Vector3 = Vector3.DOWN

var title: String = 'Entity':
	set(val): ($hud/title as Label).set_text(val)
	get: return ($hud/title as Label).get_text()

var max_health: float = 100.0:
	set(val): ($hud/health as ProgressBar).set_max(val)
	get: return ($hud/health as ProgressBar).get_max()

var health: float = 100.0:
	set(val): ($hud/health as ProgressBar).set_value(val)
	get: return ($hud/health as ProgressBar).get_value()

var max_attack: float = 100.0:
	set(val): ($hud/attack as ProgressBar).set_max(val)
	get: return ($hud/attack as ProgressBar).get_max()

var attack: float = 100.0:
	set(val): ($hud/attack as ProgressBar).set_value(val)
	get: return ($hud/attack as ProgressBar).get_value()

var target: Entity3D = null
var starting_position: Vector3 = Vector3.ZERO

# @onready var level: Level3D = $"../Level3D"
@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var cam: Camera3D = $Camera3D
@onready var canvas: Control = $Canvas
@onready var body: Node3D = $body
@onready var sprite_animated: AnimatedSprite3D = $body/spriteAnimated
@onready var sprite_ghost: Sprite3D = $body/spriteGhost
@onready var magic_area: Area3D = $magic_area
@onready var magic_sprite: AnimatedSprite3D = $magic_area/sprite
@onready var magic_audio: AudioStreamPlayer3D = $magic_area/audio
@onready var magic_area2: Area3D = $magic_area2
@onready var magic_sprite2: AnimatedSprite3D = $magic_area2/sprite
@onready var magic_audio2: AudioStreamPlayer3D = $magic_area2/audio
@onready var audio_death: AudioStreamPlayer3D = $audio_death
@onready var audio_save: AudioStreamPlayer3D = $audio_save
@onready var audio_attack: AudioStreamPlayer3D = $audio_attack
@onready var audio_takehit: AudioStreamPlayer3D = $audio_takehit

# Basically triggers all setters on initial load, to update UI and stuff
func _set_initial_params(_title: String, _max_health: float, _max_attack: float) -> void:
	title = _title
	max_health = _max_health
	health = max_health
	max_attack = _max_attack
	attack = _max_attack

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# print('entity3d _ready')
	_set_initial_params(title, max_health, max_attack)
	anim.seek(0, true) # reset animations
	if (sprite_frames):
		sprite_animated.frames = sprite_frames
		# ($body/spriteGhost as Sprite3D).texture = sprite_frames # TODO: !!!
	starting_position = global_transform.origin

	# Set default state
	fsm.ready(self)
	fsm.set_state(Entities.STATES.Standing)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fsm.process(delta)
	if (fsm.get_state() != Entities.STATES.Death): # Cant run away from death
		if (attack < max_attack):
			attack += attack_restore_speed * delta
		if (health < max_health):
			health += health_restore_speed * delta
	# we probably fell, time to respawn
	if (global_transform.origin.y < -1):
		respawn()
	_update_sprites()
	_show_hud()

func _physics_process(delta: float) -> void:
	if (fsm.get_state() == Entities.STATES.Death): # Cant run away from death
		return
	fsm.physics_process(delta) # Npc only?
	var velocity_normalized: Vector3 = velocity.normalized()
	if (!is_on_floor()):
		velocity_normalized += Vector3.DOWN
	if (velocity_normalized != Vector3.ZERO && velocity_normalized.y == 0):
		last_direction = velocity_normalized
	velocity = velocity_normalized * movement_speed
	# if Input.is_action_ just_pressed("jump") and is_on_floor():
	# 	velocity.y = 10
	# velocity.y -= 98 * delta
	var collided = move_and_slide()
	if (magic_direction != Vector3.ZERO):
		magic_area.transform.origin += magic_direction * magic_speed * delta
	if (magic_direction2 != Vector3.ZERO):
		magic_area2.transform.origin += magic_direction2 * magic_speed * delta

func _update_sprites() -> void:
	sprite_animated.flip_h = last_direction.x < 0
	var frames: SpriteFrames = sprite_animated.frames
	if (!frames):
		return
	var animation: String = "idle" if frames.has_animation("idle") else "default"
	if (last_direction.x != 0 and frames.has_animation("side")):
		animation = "side"
	if (last_direction.z < 0 and frames.has_animation("back")):
		animation = "back"
	var should_play = velocity.normalized().length() > 0 or animation == "idle"
	sprite_animated.play(animation)
	sprite_animated.playing = should_play
	# Ghost sprite (the one you see through walls and objects)
	sprite_ghost.texture = frames.get_frame(sprite_animated.animation, sprite_animated.frame)
	sprite_ghost.flip_h = sprite_animated.flip_h

#func _draw() -> void:
#	fsm.draw()

func _show_hud() -> void:
	# ($hud as Control).position = get_tree().get_root().world_3d
	var current_position = get_global_transform().origin
	var camera = get_viewport().get_camera_3d()
	var screen_pos = camera.unproject_position(current_position)
	# var offset = Vector2($hud.get_size().x/2, $hud.get_size().y/2)
	if (camera.is_position_behind(current_position)):
		$hud.hide()
	else:
		$hud.show()
	$hud.set_position(screen_pos) # - offset)
	if (health == max_health):
		$hud/health.hide()
	else:
		$hud/health.show()
	if (attack == max_attack):
		$hud/attack.hide()
	else:
		$hud/attack.show()

func on_state_change() -> void:
	var state = Entities.STATES.keys()[fsm.get_state()]
	($hud/status as Label).set_text(Entities.STATES.keys()[fsm.get_state()])

func is_player() -> bool:
	return type == Entities.TYPES.Player

func take_hit(from) -> void:
	print("take_hit: ", from)
	if (fsm.get_state() == Entities.STATES.Death): # YODO - you only die once
		return
	# TODO: STATE. DEFENDING?
	# auto set your enemy
	if (from and !target):
		target = from
	var damage = float(randi() % 25 + 50) # random between 25 and 50
	play_audio(audio_takehit)
	# $hitmark.show()
	$hitmark/title.text = str(damage)
	anim.play('hitmark')
	health -= damage

	if (health <= 0):
		if ("bugs_killed" in target):
			target.add_kill()
		fsm.set_state(Entities.STATES.Death)

func become_saved(from) -> void:
	print("become_saved: ", from)
	play_audio(audio_save)
	type = Entities.TYPES.Friendly
	$hud/health.hide()
	$hud/attack.hide()
	sprite_animated.modulate = Color.GREEN
	# body.transform = body.transform.scaled(Vector3(0.5, 0.5, 0.5)) # Need animation to do it nicely, too lazy
	var ritz: Entity3D = get_node("/root/Main/Level3D/Ritz")
	if (!ritz):
		print("Ritz not found!?")
	# Move closer to Ritz
	self.wander_distance = 3
	starting_position = ritz.starting_position
	fsm.set_state(Entities.STATES.Standing)
	if ("bugs_saved" in from):
		from.add_save()

func attack_melee(_target) -> void:
	# Whats the difference between target and _target here?
	if (attack < max_attack):
		return
	if (_target.has_method('take_hit')):
		attack = 0.0
		play_audio(audio_attack)
		# TODO: Play magic attack animation "default_attack_melee", "side_attack_melee", "top_attack_melee"
		_target.take_hit(self)

func play_audio(audio):
	audio_attack.playing = false
	audio_attack.stream.loop = false
	audio_attack.playing = true

func play_audio_death():
	play_audio(audio_death)

func attack_magic() -> void:
	if (attack < max_attack):
		return
	attack = 0.0
	magic_direction = last_direction
	_toggle_magic(magic_area2, magic_sprite2, magic_audio2, false)
	_toggle_magic(magic_area, magic_sprite, magic_audio, true)

func attack_magic2() -> void:
	if (attack < max_attack):
		return
	attack = 0.0
	magic_direction2 = last_direction
	_toggle_magic(magic_area, magic_sprite, magic_audio, false)
	_toggle_magic(magic_area2, magic_sprite2, magic_audio2, true)

# Please override this (player, npc etc. have different respawn mechanics)
func respawn() -> void:
	global_transform.origin = starting_position
	health = max_health
	anim.seek(0, true)
	anim.play("RESET")
	fsm.set_state(Entities.STATES.Standing)

func _on_detect_area_body_entered(body: Entity3D) -> void:
	pass

func _on_detect_area_body_exited(body: Entity3D) -> void:
	pass

func _on_attack_area_body_entered(body: Entity3D) -> void:
	pass

func _on_attack_area_body_exited(body: Entity3D) -> void:
	pass

func _on_magic_area_body_entered(body: Entity3D) -> void:
	if (body.type == Entities.TYPES.Enemy):
		print("magic found a body! ", body.title)
		body.take_hit(self)
		_toggle_magic(magic_area, magic_sprite, magic_audio, false)

func _on_magic_area_2_body_entered(body: Entity3D) -> void:
	if (body.type == Entities.TYPES.Enemy):
		print("magic2 found a body! ", body.title)
		body.become_saved(self)
		_toggle_magic(magic_area2, magic_sprite2, magic_audio2, false)

func _toggle_magic(area, sprite, audio, on: bool = false) -> void:
	print("_toggle_magic: ", on, ", ", area.name, " ", sprite.name, " ", audio.name)
	audio.stream.loop = false
	audio.playing = on
	area.top_level = true
	area.transform.origin = transform.origin
	area.monitorable = on
	area.monitoring = on
	area.visible = on
	area.process_mode = PROCESS_MODE_INHERIT if on else PROCESS_MODE_DISABLED
	sprite.frame = 0
	sprite.playing = on
