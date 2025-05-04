class_name SeparationBehavior
extends BaseBehavior

func calculate_steering(boid: BaseBoid) -> Vector3:
	var steering = Vector3.ZERO
	var total = 0
	
	for other_boid in boid.nearby_boids:
		var distance = boid.global_position.distance_to(other_boid.global_position)
		if distance > 0 and distance < boid.avoidance_radius:
			var repulsion = (boid.global_position - other_boid.global_position).normalized()
			repulsion /= distance  # Weight by distance
			steering += repulsion
			total += 1
	
	if total > 0:
		steering /= total
		steering = steering.normalized() * boid.max_speed
		steering -= boid.velocity
		steering = steering.limit_length(boid.max_force)
	
	return steering * weight
