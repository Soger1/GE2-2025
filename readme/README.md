# Le Fish

Name: Ethan Holohan

Student Number: C20322553

# Description

This project is designed to simulate fish in a fish tank. i quite like fish and used to have a fishtank when i was younger
i want to simulate that fishtank using boids to simulate the fish. the user will have to feed the fish if they want the fish to reproduce.

## Video:

[![YouTube](![image](https://github.com/user-attachments/assets/a3a00d38-4d2f-480d-aa67-6a5d5611a268))](https://youtu.be/SjS7tecjipg)

## Screenshots

in order to create the fish model refence was used mainly from this video 
https://www.youtube.com/watch?v=KLMhVJlOb3E
and this image for the fish shapes
![images](https://github.com/user-attachments/assets/609f5ea1-a751-4157-8594-3393f90fdfac)

# Instructions
wasd and mouse are used to control the camera. to feed the fish click on the top of the tank to place food within the tank

# How it works
the fish are boids using various behaviours to simulate real fish movement
the behaviours used to simulate the fish where resting, wandering, seeking food, wall avoidance and finally flocking. 
the behaviors calculate the total force applied to the fish and then this makes the fish move in a beliveable manner.

the behaviours are controlled using weights which adjust the effect each behaviour has on the fish.
these weights are slightly random for each fish to introduce variance between the fish.
the boid goes through each behaviour attached in the fish scene and setup in the script and calls the calculate steering function on
each of them and this results in the final direction and velocity of the fish in a vector3 result.

the boundary behaviour works 

the food is the main method of player interaction, fish priortise eating food and will repoduce when given enough food.
the food is created using a food instnace scene and a foodspawner script which spawns the food along the top of the tank using a ray cast to detect
the watersurface object. then the food will float down into the water until either 60 secs pass or the food is eaten.

the fish tank uses a shader to simualte the water and has refraction applied from both the water and the glass.

the fishes animation is done using procedural animation using the spine_animator script which causes the body and the tail of the fish to naturaly follow the
head of the fish using lerp to make it look smooth.

# List of classes/assets

| Class/asset | Source |
|-----------|-----------|
| BoundryBehavior.gd | Modified from Claude.AI |
| Camera.gd | From [2] |
| EnergyConservationBehavior.gd | Modifed from Claude.AI |
| Fish.gd | Modifed from Claude.AI |
| FlockingBehaviour.gd | Modifed from Claude.AI |
| FoodItem.gd | Modifed from Claude.AI |
| FoodseekingBehaviour.gd | Modifed from Claude.AI |
| FoodSpawner.gd | Modifed from Claude.AI |
| spine_animator.gd | Modifed from [1] |
| WanderBehaviour.gd | Modifed from Claude.AI |

Models made in Godot using CSG Combiners
Textures obtained from Opengameart.org
song made by me

- What im most proud of

i am most proud of how the fish swim around the tank and the smoothness and almost natural way they do it, they are quite
relaxing to look at roam.
  
- What I learned

i learned alot about how boids work and how to combine and use vector3s to create natural looking motion.

# References
* [1](https://github.com/skooter500/miniature-rotary-phone/blob/main/minature-rotary-phone/behaviors/spine_animator.gd)
* [2] https://godotengine.org/asset-library/asset/701


