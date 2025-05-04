class_name WanderBehavior
extends BaseBehavior

var wander_angle: float = 0.0
var wander_radius: float = 1.2
var angle_change: float = 0.3

func calculate_steering(boid: BaseBoid) -> Vector3:
	wander_angle += randf_range(-angle_change, angle_change)
	
	var circle_center = boid.velocity.normalized() * wander_radius
	var displacement = Vector3(cos(wander_angle), sin(wander_angle), 0) * wander_radius
	
	var steering = circle_center + displacement
	steering = steering.normalized() * boid.max_speed
	steering -= boid.velocity
	steering = steering.limit_length(boid.max_force)
	
	return steering * weight
