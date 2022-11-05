extends FSMState

func enter (fsm, owner) -> void:
	pass

func process (fsm, owner, delta) -> void:
	# if our target is in colliding obj array, attack, else stop attack state
	if (owner.target and owner.target.type == Entities.TYPES.Player):
		owner.attack_melee(owner.target)
	else:
		fsm.set_previous_state() # Hmm?

func physics_process (fsm, owner, delta) -> void:
	pass

func exit (fsm, owner) -> void:
	pass
