extends Node

# Flocking parameters
@export var separation_weight: float = 2.0   # How strongly fish avoid each other
@export var cohesion_weight: float = 1.0     # How strongly fish are drawn to center of group
@export var alignment_weight: float = 1.2    # How strongly fish align their direction with neighbors

# Neighbor detection
@export var neighbor_radius: float = 5.0     # How far to look for neighbors
@export var separation_radius: float = 2.0   # Minimum distance between fish

# Internal variables
var parent_fish = null

# Debug
@export var debug_mode: bool = false

func initialize(fish):
	parent_fish = fish

func calculate_steering():
	if parent_fish == null:
		return Vector3.ZERO
	
	# Get all fish in the scene
	var all_fish = get_tree().get_nodes_in_group("fish")
	
	# Filter out self and fish that are too far away
	var neighbors = []
	for fish in all_fish:
		if fish != parent_fish:
			var distance = parent_fish.global_transform.origin.distance_to(fish.global_transform.origin)
			if distance < neighbor_radius:
				neighbors.append(fish)
	
	# If no neighbors found, return zero steering
	if neighbors.size() == 0:
		return Vector3.ZERO
	
	# Calculate the three flocking behaviors
	var separation = calculate_separation(neighbors)
	var cohesion = calculate_cohesion(neighbors)
	var alignment = calculate_alignment(neighbors)
	
	# Combine the behaviors with their weights
	var flocking_force = separation * separation_weight
	flocking_force += cohesion * cohesion_weight
	flocking_force += alignment * alignment_weight
	
	if debug_mode:
		print("Flocking force: ", flocking_force)
	
	return flocking_force

func calculate_separation(neighbors: Array) -> Vector3:
	# Initialize separation force
	var separation_force = Vector3.ZERO
	
	# For each neighbor, calculate repulsion force
	for fish in neighbors:
		var to_neighbor = fish.global_transform.origin - parent_fish.global_transform.origin
		var distance = to_neighbor.length()
		
		# Only apply separation if too close
		if distance < separation_radius:
			# Calculate repulsion - stronger when closer
			var repulsion = -to_neighbor.normalized() * (separation_radius - distance) / separation_radius
			separation_force += repulsion
	
	return separation_force

func calculate_cohesion(neighbors: Array) -> Vector3:
	# Calculate center of mass of the group (excluding self)
	var center_of_mass = Vector3.ZERO
	
	for fish in neighbors:
		center_of_mass += fish.global_transform.origin
	
	center_of_mass /= neighbors.size()
	
	# Direction towards center of mass
	var to_center = center_of_mass - parent_fish.global_transform.origin
	
	# Return direction toward center of mass
	return to_center.normalized() * (to_center.length() / neighbor_radius)

func calculate_alignment(neighbors: Array) -> Vector3:
	# Calculate average velocity of neighbors
	var avg_velocity = Vector3.ZERO
	
	for fish in neighbors:
		# Assuming all fish have a velocity property
		avg_velocity += fish.velocity
	
	avg_velocity /= neighbors.size()
	
	# Return alignment force (difference between average velocity and own velocity)
	return (avg_velocity - parent_fish.velocity).normalized()
