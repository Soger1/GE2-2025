class_name ObstacleAvoidanceBehavior
extends BaseBehavior

var ray_length: float = 5.0

func calculate_steering(boid: BaseBoid) -> Vector3:
	var steering = Vector3.ZERO
	
	# Cast rays in a few directions to detect obstacles
	var space_state = boid.get_world_3d().direct_space_state
	var front_ray = PhysicsRayQueryParameters3D.create(boid.global_position, 
													 boid.global_position + boid.velocity.normalized() * ray_length)
	front_ray.exclude = [boid]
	
	var result = space_state.intersect_ray(front_ray)
	
	if result:
		# We hit something, steer away
		var collision_normal = result["normal"]
		steering = collision_normal * boid.max_speed
		steering -= boid.velocity
		steering = steering.limit_length(boid.max_force)
	
	return steering * weight
