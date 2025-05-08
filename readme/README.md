# Le Fish

Name: Ethan Holohan

Student Number: C20322553

# Description

This project is designed to simulate fish in a fish tank. i quite like fish and used to have a fishtank when i was younger
i want to simulate that fishtank using boids to simulate the fish. the user will have to feed the fish if they want the fish to reproduce

## Video:

[![YouTube](https://github.com/user-attachments/assets/a1482916-3a5c-46ae-a294-c729616bf161)](https://youtu.be/SjS7tecjipg)



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

the fish tank uses a shader to simualte the water and has refraction applied from both the water and the glass

# List of classes/assets

| Class/asset | Source |
|-----------|-----------|
| BoundryBehavior.gd | Modified from Claude.AI |
| Camera.gd | From https://godotengine.org/asset-library/asset/701 |
| EnergyConservationBehavior.gd | Modifed from Claude.AI |
| Fish.gd | Modifed from Claude.AI |
| FlockingBehaviour.gd | Modifed from Claude.AI |
| FoodItem.gd | Modifed from Claude.AI |
| FoodseekingBehaviour.gd | Modifed from Claude.AI |
| FoodSpawner.gd | Modifed from Claude.AI |
| spine_animator.gd | Modifed from MinatureRotaryPhone |
| WanderBehaviour.gd | Modifed from Claude.AI |

Models made in Godot using CSG Combiners
Textures obtained from Opengameart.org
song made by me

Each team member or individual needs to write a paragraph or two explaining what they contributed to the project



- What they did
- What they are most proud of
- What they learned

# References
* Item 1
* Item 2



