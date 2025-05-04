class_name AlignmentBehavior
extends BaseBehavior

func calculate_steering(boid: BaseBoid) -> Vector3:
	var steering = Vector3.ZERO
	var total = 0
	
	for other_boid in boid.nearby_boids:
		if other_boid.get_class() == boid.get_class():  # Only align with same type
			steering += other_boid.velocity.normalized()
			total += 1
	
	if total > 0:
		steering /= total
		steering = steering.normalized() * boid.max_speed
		steering -= boid.velocity
		steering = steering.limit_length(boid.max_force)
	
	return steering * weight
