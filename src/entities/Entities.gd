class_name Entities

enum TYPES {
	Player,
	Friendly,
	Enemy,
}

enum STATES {
	# Movement
	Standing, # = 10,
	Walking,
	Wandering,
	Chasing,
	# Combat / Action
	Idle,
	Attacking,
	Defending,
	Death,
}
