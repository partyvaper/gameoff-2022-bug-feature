extends FSMState

var walk_target: Vector2 = Vector2.ZERO
var walk_target_path: Array = []
const eps: float = 1.0 # at which distance to stop moving (setting too low might result in jerky movement near destination)

func enter (fsm, owner) -> void:
	if (!owner.target): # TODO: Might change?
		fsm.set_state(Entities.STATES.Standing)
		return

func process (fsm, owner, delta) -> void:
	pass

func physics_process (fsm, owner, delta) -> void:
	# We lost target
	if (!owner.target):
		fsm.set_state(Entities.STATES.Standing)
		return
	var nav: NavigationAgent3D = (owner.nav as NavigationAgent3D)
	var target_position: Vector3 = owner.target.transform.origin
	nav.set_target_location(target_position)
	if (!nav.is_target_reachable()):
		print("NOT REACHABLE! ", target_position)
		# fsm.set_state(Npcs.STATES.Standing)
		# return
	var reached: bool = nav.is_navigation_finished() # we finished nav how far we got, use is_target_reached() to actually check if arrived at target
	print("nav finished ", nav.is_navigation_finished(), " target reached ", nav.is_target_reached())
	if reached:
		_draw(fsm, owner, true)
		owner.velocity = Vector3.ZERO
		fsm.set_state(Entities.STATES.Attacking)
	else:
		var current: Vector3 = (owner as Node3D).transform.origin
		var target: Vector3 = nav.get_next_location()
		var distance = target - current
		var direction = distance.normalized() # direction of movement
		# print("current: ", current,", target:", target, ", distance: ", distance, ", direction: ", direction)
		# if (direction == Vector3.ZERO):
			# print("no navigation target!")
		owner.velocity = direction
	# Debug draw:
	_draw(fsm, owner)

func _draw(fsm, owner: Node3D, clear_only = false) -> void:
	if !owner.get_tree().debug_navigation_hint:
		return
	var nav: NavigationAgent3D = (owner.nav as NavigationAgent3D)
	var nav_path: PackedVector3Array = nav.get_nav_path()
	var camera = owner.get_viewport().get_camera_3d()
	var canvas: Control = owner.canvas
	canvas.clear_points()
	if (clear_only):
		return
	# if there are points to draw
	if nav_path.size() > 1:
		# draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
		# var inv = owner.get_global_transform().affine_inverse()
		# owner.draw_set_transform(inv.get_origin(), inv.get_rotation(), inv.get_scale())
		for v3 in nav_path:
			var v2 = camera.unproject_position(v3)
			if (!camera.is_position_behind(v3)):
				canvas.add_point(v2, Color.YELLOW)
		var next_v3 = nav.get_next_location()
		var next_v2 = camera.unproject_position(next_v3)
		if (!camera.is_position_behind(next_v3)):
			canvas.add_point(next_v2, Color.ORANGE)
	var target_v3 = nav.get_target_location()
	var target_v2 = camera.unproject_position(target_v3)
	if (!camera.is_position_behind(target_v3)):
		canvas.add_point(target_v2, Color.RED)

func exit (fsm, owner) -> void:
	_draw(fsm, owner, true)
