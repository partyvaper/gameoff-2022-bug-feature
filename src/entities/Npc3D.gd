extends Entity3D

class_name Npc3D

@export var npc_title: String = "Npc"
@export var wander_distance: int = 0

var preloaded_timeline: DialogicTimeline = null

func _ready() -> void:
	super()
	title = npc_title
	# npcs move and perform a bit slower than other entities (e.g. player)
	movement_speed = movement_speed * 0.5
	attack_restore_speed = attack_restore_speed * 0.75
	health_restore_speed = health_restore_speed * 0.25
	fsm.set_state(Entities.STATES.Wandering)
	if (type == Entities.TYPES.Friendly):
		$hud/health.hide()
		$hud/attack.hide()

func _on_detect_area_body_entered(body: Entity3D) -> void:
	# TODO: EvE or multi-combat areas can be handled here?
	if (body and body.is_player() and !target):
		print('%s(%s) detected %s(%s)' % [title, name, body.title, body.name])
		target = body
		body.target = self
		if (type == Entities.TYPES.Enemy):
			fsm.set_state(Entities.STATES.Chasing)
		# if have chat story, show option to start chat!
		_show_dialog()

func _on_detect_area_body_exited(body: Entity3D) -> void:
	# TODO: EvE or multi-combat areas can be handled here?
	if (body and body.is_player() and target):
		print('%s(%s) lost %s(%s)' % [title, name, body.title, body.name])
		body.target = null
		target = null
		fsm.set_state(Entities.STATES.Standing)
		# fsm.set_state(fsm.get_previous_state())
		_hide_dialog()
		end_timeline()

func _show_dialog() -> void:
	if (!preloaded_timeline):
		var timeline = Dialogic.find_timeline(title + "Timeline")
		if (timeline):
			preloaded_timeline = Dialogic.preload_timeline(timeline)
	if (preloaded_timeline):
		$hud/chat.show()

func _hide_dialog() -> void:
	$hud/chat.hide()

func start_timeline() -> void:
	if (preloaded_timeline):
		# Dialogic.start_timeline(preloaded_timeline) # This gives missing portrait scene errors?
		Dialogic.start(title + "Timeline")

func end_timeline() -> void:
	if (preloaded_timeline):
		Dialogic.end_timeline()
