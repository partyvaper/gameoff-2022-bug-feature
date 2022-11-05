extends FSMState

var timer: float = 0

func enter (fsm, owner) -> void:
	if (!owner.is_player() and "wander_distance" in owner and owner.wander_distance > 0):
		timer = float(randi() % 2 + 1) # random seconds between 1 and 2

func process (fsm, owner, delta: float) -> void:
	if (timer > 0):
		timer -= delta
		if (int(timer) == 0):
			timer = 0
			fsm.set_state(Entities.STATES.Wandering)

func physics_process(fsm, owner, delta: float) -> void:
	pass
	# draw(fsm, owner)

func draw(fsm, owner: Node3D) -> void:
	pass

func exit (fsm, owner) -> void:
	timer = 0
