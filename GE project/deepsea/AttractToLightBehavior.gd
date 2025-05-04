class_name AttractToLightBehavior
extends BaseBehavior

func calculate_steering(boid: BaseBoid) -> Vector3:
	var steering = Vector3.ZERO
	var brightest_light = null
	var max_intensity = 0.0
	
	for other_boid in boid.nearby_boids:
		if other_boid.luminescence_intensity > max_intensity:
			max_intensity = other_boid.luminescence_intensity
			brightest_light = other_boid
	
	if brightest_light != null:
		var desired_velocity = (brightest_light.global_position - boid.global_position).normalized() * boid.max_speed
		steering = desired_velocity - boid.velocity
		steering = steering.limit_length(boid.max_force)
	
	return steering * weight
