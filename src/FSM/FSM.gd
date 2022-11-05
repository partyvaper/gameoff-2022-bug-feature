extends Object

class_name FSM

const STATE_HISTORY_COUNT: int = 4 # Has to be at least 2

var states: Dictionary = {}
var state_history: Array = []
var owner = null

func _init (_states: Dictionary) -> void:
	if (_states):
		add_states(_states)

func ready (_owner) -> void:
	owner = _owner

# Calls state->process
func process (delta: float) -> void:
	var state = get_state()
	if states.has(state) and states[state].has_method('process'):
		states[state].process(self, owner, delta)

# Calls state->physics_process
func physics_process (delta: float) -> void:
	var state = get_state()
	if states.has(state) and states[state].has_method('physics_process'):
		states[state].physics_process(self, owner, delta)

# Calls state->draw
func draw() -> void:
	var state = get_state()
	if states.has(state) and states[state].has_method('draw'):
		states[state].draw(self, owner)

func add_states (_states: Dictionary) -> void:
	for k in _states.keys():
		add_state(k, _states[k])

func add_state (_id: int, _state) -> void: # _state: FSMState
	states[_id] = _state

func remove_state (_id: int) -> void:
	var erased = states.erase(_id)
	if (!erased):
		print("Could not remove_state: ", _id)

# Calls state->exit, state->enter
func set_state (_id: int) -> void:
	var state = get_state()
	# print("set_state: ", _id, ", current: ", state, ", history: ", state_history)
	if (state == _id):
		# print("set_state: same state! ", state, " == ", _id)
		return
	if !states.has(_id):
		# print("set_state: invalid state! ", _id)
		return
	# Exit existing state
	if states.has(state) and states[state].has_method('exit'):
		# print("set_state: exit previous! ", state)
		states[state].exit(self, owner)
		# print('state ', Entities.STATES.keys()[state], ' exit')
	# print("state_history 1: ", state_history)
	state_history.push_back(_id)
	# print("state_history 2: ", state_history)
	# Limit to max state history count
	# var state_history_size = state_history.size()
	# if (state_history_size > STATE_HISTORY_COUNT):
	#	state_history = state_history.slice(state_history_size-STATE_HISTORY_COUNT)
	state_history = state_history.slice(-STATE_HISTORY_COUNT)
	# print("state_history 3: ", state_history)
	state = get_state() # get the new just pushed state (same as _id i guess)
	# print("set_state: new state! ", _id, ", current: ", state, ", history: ", state_history)
	# if owner.get('npc'):
	#	print('state: ', _state_name(state), ', previous_state: ', _state_name(get_previous_state()), ', state_history: ', _state_names(state_history))
	# Enter the new state
	if states.has(state) and states[state].has_method('enter'):
		# print("set_state: enter new! ", state)
		states[state].enter(self, owner)
		# print('state ', Entities.STATES.keys()[state], ' enter')
	# Notify the state changed
	if (owner.has_method('on_state_change')):
		owner.call('on_state_change') # , self, state)

#static func _state_names(_states) -> String:
#	var s = ''
#	for state in _states:
#		s += _state_name(state) + ', '
#	return s

# static func _state_name(state) -> String:
#	return str(Entities.STATES.keys()[state])

func set_previous_state() -> void:
	var state = get_previous_state()
	state_history = state_history.slice(0, -3) # Remove last 2, will re-insert last again
	set_state(state)

func get_state() -> int:
	var state = -1
	if (state_history.size() > 0):
		state = state_history[-1]
	# print("get_state: ", state, ", history: ", state_history.size(), " ", state_history)
	return state

func get_previous_state() -> int:
	var state = -1
	if (state_history.size() > 1):
		state = state_history[-2]
	# print("get_previous_state: ", state, ", history: ", state_history.size(), " ", state_history)
	return state
