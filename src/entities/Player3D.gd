extends Entity3D

class_name Player3D

var bugs_to_kill = 30
var bugs_killed = 0

var bugs_to_save = 15
var bugs_saved = 0

# global
@onready var ui_bugs: Label = $"/root/Main/UI/bugs"
@onready var ui_bugs2: Label = $"/root/Main/UI/bugs2"
# onready var level = $"/root/game/level"

#func _init() -> void:
	# super()
	# set_max_health(100) # TODO: Will calculate based on skill level
	# set_health(max_health) # TODO: ??
	# movement_speed = 80 # TODO: Will calculate based on inventory weight, skill levels, effects?
	# set_title('Player')
	# pass

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	super()
	title = "Player"
	cam.make_current()
	# ($camera as Camera2D).zoom /= Game.game_scale
	# print("player _ready, title: ", title)
	Dialogic.connect("signal_event", _dialogic_event)

func _dialogic_event(event):
	if (event == "quest_started"):
		bugs_killed = 0
		Dialogic.VAR.set_variable("bugs_killed", str(bugs_killed))
		Dialogic.VAR.set_variable("quest1", "inprogress")
		ui_bugs.text = str(bugs_killed,"/",bugs_to_kill," Bugs Killed")
		ui_bugs.show()
	if (event == "secret_entered"):
		var secret = Dialogic.VAR.get_variable("secret")
		print(secret)
		# We have to double check Dialogic variables, because it weirdly handles numbers?
		if (secret == "FOURTWENTY420SIXTYNINE69"):
			print("correct!")
		else:
			Dialogic.VAR.set_variable("secret", "wrong")
	if (event == "quest_started2"):
		bugs_saved = 0
		Dialogic.VAR.set_variable("bugs_saved", str(bugs_saved))
		Dialogic.VAR.set_variable("quest2", "inprogress")
		ui_bugs2.text = str(bugs_saved,"/",bugs_to_save," Bugs Saved")
		ui_bugs2.show()

func add_kill():
		bugs_killed += 1
		if (bugs_killed >= bugs_to_kill):
			Dialogic.VAR.set_variable("quest1", "finished")
		Dialogic.VAR.set_variable("bugs_killed", str(bugs_killed))
		ui_bugs.text = str(bugs_killed,"/",bugs_to_kill," Bugs Killed")

func add_save():
		bugs_saved += 1
		if (bugs_saved >= bugs_to_save):
			Dialogic.VAR.set_variable("quest2", "finished")
		Dialogic.VAR.set_variable("bugs_saved", str(bugs_saved))
		ui_bugs2.text = str(bugs_saved,"/",bugs_to_save," Bugs Saved")

# Called every frame. 'delta' is the elapsed time since the previous frame
#func _process(delta: float) -> void:
	#super()
	# var pos = get_position()
	# var posinchunk = (pos/16/32).floor()

	# var pos_in_map = level.pos_in_map(pos)
	# var pos_in_chunk = level.pos_in_chunk(pos)

	# ui.set_debug_text('pos', str(pos))
	# ui.set_debug_text('pos_in_map', str(pos_in_map))
	# ui.set_debug_text('pos_in_chunk', str(pos_in_chunk))

	# $hud/title.set_text(title)


func _physics_process(delta: float) -> void:
	# Parse movement motion
	var motion = Vector3.ZERO
	if (Input.is_action_pressed("player_up")):
		motion += Vector3.FORWARD
	if (Input.is_action_pressed("player_down")):
		motion += Vector3.BACK
	if (Input.is_action_pressed("player_left")):
		motion += Vector3.LEFT
	if (Input.is_action_pressed("player_right")):
		motion += Vector3.RIGHT
	if (Input.is_action_just_pressed("player_jump") and is_on_floor()):
		motion += Vector3.UP
	if (Dialogic.current_state != Dialogic.states.IDLE or Dialogic.current_timeline):
		motion = Vector3.ZERO
	if (motion == Vector3.ZERO):
		if (fsm.get_state() == Entities.STATES.Walking):
			fsm.set_state(Entities.STATES.Standing)
	else:
		fsm.set_state(Entities.STATES.Walking)
	velocity = motion
	super(delta)

func _input(event: InputEvent) -> void:
	if (Dialogic.current_state != Dialogic.states.IDLE or Dialogic.current_timeline):
		return
	if event is InputEventKey and event.pressed:
		#if event.is_action_pressed("ui_plus"):
		#	($camera as Camera2D).zoom.x -= 0.1
		#	($camera as Camera2D).zoom.y -= 0.1
		#if event.is_action_pressed("ui_minus"):
		#	($camera as Camera2D).zoom.x += 0.1
		#	($camera as Camera2D).zoom.y += 0.1
		if event.is_action_pressed("player_attack"):
			attack_magic()
			#if (target and can_attack):
			#	attack(target)
			#else:
			#	pass
			fsm.set_state(Entities.STATES.Attacking)
		if event.is_action_pressed("player_attack2"):
			if (Dialogic.VAR.get_variable("quest2") == "inprogress"):
				attack_magic2()
				fsm.set_state(Entities.STATES.Attacking)
		if event.is_action_pressed("player_action"):
			if (target and "start_timeline" in target):
				target.start_timeline()
			# pick_item()

func respawn() -> void:
	super()
	print('Player respawn')
	# _init()
