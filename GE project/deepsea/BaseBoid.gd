class_name BaseBoid
extends CharacterBody3D

# Boid parameters
@export var max_speed: float = 5.0
@export var min_speed: float = 2.0
@export var max_force: float = 0.5
@export var perception_radius: float = 10.0
@export var avoidance_radius: float = 5.0
@export var alignment_weight: float = 1.0
@export var cohesion_weight: float = 1.0
@export var separation_weight: float = 1.5
@export var wander_weight: float = 0.5
@export var obstacle_avoidance_weight: float = 2.0
@export var luminescence_intensity: float = 0.0
@export var max_luminescence: float = 1.0

# Current boid velocity
var velo: Vector3 = Vector3.ZERO
var acceleration: Vector3 = Vector3.ZERO
var current_speed: float = 0.0
var nearby_boids: Array = []
var nearby_predators: Array = []

# References to components
@onready var perception_area: Area3D = $PerceptionArea
@onready var avoidance_area: Area3D = $AvoidanceArea
@onready var luminescence: OmniLight3D = $Luminescence

# Behaviors
var behaviors: Array = []

# Signals
signal luminescence_changed(intensity)
signal damaged(position, amount)
signal detected_predator(predator)

func _ready():
	# Setup perception area
	perception_area.monitoring = true
	perception_area.connect("body_entered", _on_perception_body_entered)
	perception_area.connect("body_exited", _on_perception_body_exited)
	
	# Setup avoidance area
	avoidance_area.monitoring = true
	avoidance_area.connect("body_entered", _on_avoidance_body_entered)
	
	# Setup initial speed
	current_speed = (max_speed + min_speed) / 2
	velocity = Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5).normalized() * current_speed
	
	# Initialize behaviors
	_initialize_behaviors()
	
	# Setup luminescence
	set_luminescence(luminescence_intensity)

func _initialize_behaviors():
	# Override in child classes to add specific behaviors
	pass

func _physics_process(delta):
	# Reset acceleration
	acceleration = Vector3.ZERO
	
	# Apply all active behaviors
	for behavior in behaviors:
		if behavior.is_active():
			var steering_force = behavior.calculate_steering(self)
			acceleration += steering_force
	
	# Apply physics
	acceleration = acceleration.limit_length(max_force)
	velocity += acceleration * delta
	velocity = velocity.limit_length(max_speed)
	
	if velocity.length() > 0:
		# Face in the direction of movement
		look_at(global_position + velocity.normalized(), Vector3.UP)
	
	# Set final velocity
	set_velocity(velocity)
	move_and_slide()
	velocity = get_velocity()

func set_luminescence(intensity: float):
	luminescence_intensity = clamp(intensity, 0.0, max_luminescence)
	luminescence.light_energy = luminescence_intensity
	emit_signal("luminescence_changed", luminescence_intensity)

func take_damage(amount: float, source_position: Vector3 = Vector3.ZERO):
	# Base implementation - override in subclasses
	emit_signal("damaged", global_position, amount)

func _on_perception_body_entered(body):
	if body != self and body is BaseBoid:
		nearby_boids.append(body)
		
		# Check if this is a predator
		if is_predator(body):
			nearby_predators.append(body)
			emit_signal("detected_predator", body)

func _on_perception_body_exited(body):
	if nearby_boids.has(body):
		nearby_boids.erase(body)
	
	if nearby_predators.has(body):
		nearby_predators.erase(body)

func _on_avoidance_body_entered(body):
	# Handle immediate avoidance if needed
	pass

func is_predator(boid) -> bool:
	# Override in subclasses to define what is considered a predator
	return false

func get_nearby_boids_of_type(boid_type) -> Array:
	var result = []
	for boid in nearby_boids:
		if boid == boid_type:
			result.append(boid)
	return result

func apply_force(force: Vector3):
	acceleration += force
