extends Camera3D

var smooth_speed: float = 10.0 # The bigger the value, the faster it will get into position
var offset: Vector3 = Vector3.ZERO # Camera offset from player
var target: CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	offset = transform.origin
	target = get_parent()
	set_as_top_level(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if (target):
		transform.origin = lerp(transform.origin, target.transform.origin + offset, smooth_speed * delta)
