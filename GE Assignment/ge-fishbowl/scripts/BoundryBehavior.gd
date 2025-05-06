extends Node

# Boundary parameters
@export var detection_distance: float = 3.0  # How far to check for boundaries
@export var boundary_force: float = 5.0  # How strongly to avoid boundaries
@export var tank_size: Vector3 = Vector3(10, 6, 6)  # Size of tank (adjust as needed)

# Internal variables
var parent_fish = null
var tank_center = Vector3.ZERO

func initialize(fish):
	parent_fish = fish
	# Get the center of the tank (assuming tank is centered at world origin)
	tank_center = Vector3.ZERO

func calculate_steering():
	if parent_fish == null:
		return Vector3.ZERO
		
	var steering = Vector3.ZERO
	var fish_position = parent_fish.global_transform.origin
	
	# Check distance to each wall and apply avoidance force
	var half_size = tank_size / 2
	
	# Check X boundaries (left/right walls)
	var distance_to_right = half_size.x - fish_position.x
	var distance_to_left = fish_position.x + half_size.x
	
	if distance_to_right < detection_distance:
		steering.x -= boundary_force * (1.0 - distance_to_right / detection_distance)
	if distance_to_left < detection_distance:
		steering.x += boundary_force * (1.0 - distance_to_left / detection_distance)
	
	# Check Y boundaries (top/bottom walls)
	var distance_to_top = half_size.y - fish_position.y
	var distance_to_bottom = fish_position.y + half_size.y
	
	if distance_to_top < detection_distance:
		steering.y -= boundary_force * (1.0 - distance_to_top / detection_distance)
	if distance_to_bottom < detection_distance:
		steering.y += boundary_force * (1.0 - distance_to_bottom / detection_distance)
	
	# Check Z boundaries (front/back walls)
	var distance_to_front = half_size.z - fish_position.z
	var distance_to_back = fish_position.z + half_size.z
	
	if distance_to_front < detection_distance:
		steering.z -= boundary_force * (1.0 - distance_to_front / detection_distance)
	if distance_to_back < detection_distance:
		steering.z += boundary_force * (1.0 - distance_to_back / detection_distance)
		
	return steering
