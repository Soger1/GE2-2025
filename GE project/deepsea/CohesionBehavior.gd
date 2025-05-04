class_name CohesionBehavior
extends BaseBehavior

func calculate_steering(boid: BaseBoid) -> Vector3:
	var steering = Vector3.ZERO
	var center_of_mass = Vector3.ZERO
	var total = 0
	
	for other_boid in boid.nearby_boids:
		if other_boid.get_class() == boid.get_class():  # Only cohere with same type
			center_of_mass += other_boid.global_position
			total += 1
	
	if total > 0:
		center_of_mass /= total
		var desired_velocity = (center_of_mass - boid.global_position).normalized() * boid.max_speed
		steering = desired_velocity - boid.velocity
		steering = steering.limit_length(boid.max_force)
	
	return steering * weight
