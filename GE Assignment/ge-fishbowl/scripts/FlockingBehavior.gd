extends Node

@export var separation_weight: float = 2.0 
@export var cohesion_weight: float = 1.0    
@export var alignment_weight: float = 1.2   

@export var neighbor_radius: float = 5.0
@export var separation_radius: float = 2.0

var parent_fish = null

@export var debug_mode: bool = false

func initialize(fish):
	parent_fish = fish

func calculate_steering():
	if parent_fish == null:
		return Vector3.ZERO

	var all_fish = get_tree().get_nodes_in_group("fish")
	var neighbors = []
	for fish in all_fish:
		if fish != parent_fish:
			var distance = parent_fish.global_transform.origin.distance_to(fish.global_transform.origin)
			if distance < neighbor_radius:
				neighbors.append(fish)
	
	if neighbors.size() == 0:
		return Vector3.ZERO
	
	var separation = calculate_separation(neighbors)
	var cohesion = calculate_cohesion(neighbors)
	var alignment = calculate_alignment(neighbors)
	
	var flocking_force = separation * separation_weight
	flocking_force += cohesion * cohesion_weight
	flocking_force += alignment * alignment_weight
	
	if debug_mode:
		print("Flocking force: ", flocking_force)
	
	return flocking_force

func calculate_separation(neighbors: Array) -> Vector3:
	var separation_force = Vector3.ZERO
	
	for fish in neighbors:
		var to_neighbor = fish.global_transform.origin - parent_fish.global_transform.origin
		var distance = to_neighbor.length()
		if distance < separation_radius:
			var repulsion = -to_neighbor.normalized() * (separation_radius - distance) / separation_radius
			separation_force += repulsion
	
	return separation_force

func calculate_cohesion(neighbors: Array) -> Vector3:
	var center_of_mass = Vector3.ZERO
	for fish in neighbors:
		center_of_mass += fish.global_transform.origin
	center_of_mass /= neighbors.size()
	var to_center = center_of_mass - parent_fish.global_transform.origin
	return to_center.normalized() * (to_center.length() / neighbor_radius)

func calculate_alignment(neighbors: Array) -> Vector3:
	var avg_velocity = Vector3.ZERO
	for fish in neighbors:
		avg_velocity += fish.velocity
	avg_velocity /= neighbors.size()
	return (avg_velocity - parent_fish.velocity).normalized()
