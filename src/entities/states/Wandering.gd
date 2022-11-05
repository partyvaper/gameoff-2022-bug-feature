extends FSMState

var walk_target: Vector3 = Vector3.ZERO
var walk_target_path: PackedVector3Array = PackedVector3Array()
const eps: float = 1.0 # at which distance to stop moving (setting too low might result in jerky movement near destination)
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func enter (fsm, owner) -> void:
	if (owner.is_player() or !("wander_distance" in owner) or owner.wander_distance < 1):
		fsm.set_state(Entities.STATES.Standing)
		return
	var nav: NavigationAgent3D = (owner.nav as NavigationAgent3D)
	nav.set_target_location(_random_wander_position(owner))
	# print("nav reachable: ", nav.is_target_reachable(), ", distance to target: ", nav.distance_to_target())
	if (!nav.is_target_reachable()):
		_draw(fsm, owner, true)
		fsm.set_state(Entities.STATES.Standing)
		return
	# walk_target_path = (owner.game as Game).navigation_path(owner.position, walk_target)

func process (fsm, owner, delta) -> void:
	pass

func physics_process (fsm, owner, delta) -> void:
	var nav: NavigationAgent3D = (owner.nav as NavigationAgent3D)
	var reached: bool = nav.is_navigation_finished() # we finished nav how far we got, use is_target_reached() to actually check if arrived at target
	if reached:
		_draw(fsm, owner, true)
		owner.velocity = Vector3.ZERO
		fsm.set_state(Entities.STATES.Standing)
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
				canvas.add_point(v2, Color.GREEN)
		var next_v3 = nav.get_next_location()
		var next_v2 = camera.unproject_position(next_v3)
		if (!camera.is_position_behind(next_v3)):
			canvas.add_point(next_v2, Color.CYAN)
	var target_v3 = nav.get_target_location()
	var target_v2 = camera.unproject_position(target_v3)
	if (!camera.is_position_behind(target_v3)):
		canvas.add_point(target_v2, Color.BLUE)

func exit (fsm, owner) -> void:
	_draw(fsm, owner, true)

func _random_wander_position(owner) -> Vector3:
	rng.randomize()
	var x = rng.randi_range(-owner.wander_distance, owner.wander_distance)
	var z = rng.randi_range(-owner.wander_distance, owner.wander_distance)
	var target_vector = Vector3(x, 0, z)
	# From starting position (can use owner.trasnform.origin for - From current position)
	var target_position = owner.starting_position + target_vector
	target_position.y = 0 # to stick to ground?
	# print('_random_wander_position, target_position: ', target_position)
	return target_position

