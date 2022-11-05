extends FSMState

var callable = Callable(self, '_on_animation_finished')

func _on_animation_finished (anim_name, owner) -> void:
	print('die: finished animation', ', ', anim_name, ', ', owner)
	owner.anim.disconnect('animation_finished', callable)
	if anim_name == 'die' and owner.has_method('respawn'):
		owner.respawn()

func enter (fsm, owner) -> void:
	owner.anim.connect('animation_finished', callable.bind(owner))
	owner.anim.play('die')

# func process (fsm, owner, delta) -> void:
#	pass

# func physics_process (fsm, owner, delta) -> void:
#	pass

# func exit (fsm, owner) -> void:
#	pass
