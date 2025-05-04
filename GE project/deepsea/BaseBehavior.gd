class_name BaseBehavior
extends RefCounted

# Weight of this behavior
var weight: float = 1.0
var active: bool = true

func _init(initial_weight: float = 1.0):
	weight = initial_weight

func calculate_steering(_boid: BaseBoid) -> Vector3:
	# Override in child classes
	return Vector3.ZERO

func is_active() -> bool:
	return active

func set_active(value: bool):
	active = value
