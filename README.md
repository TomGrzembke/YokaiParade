# Yokai Parade
Take over abilities of your enemies tojump and run faster than every other yokai!

- Created in `Godot Engine`.
- Programmers: 2. Other one is [FuzzyHerbivore](https://github.com/FuzzyHerbivore/yokai-parade) (He did the overall game framework, technical UI and menu foundations).
- Task: Create a 2D Jump and Run in Godot.
<div align="center">

![DoubleJump](https://github.com/user-attachments/assets/6fd3c85f-5c52-46aa-9cc5-a96b75c386e7)

</div>

## How To Run
WebGL embed at itch.io: [here](https://tom-grzembke.itch.io/qinu)

# My Responsibilities
<div align="center">

System | Script | Purpose | 
  --- | --- | --- | 
PlayerMovement | [View](https://github.com/TomGrzembke/YokaiParade/blob/main/player/player.gd) | An Adaptation to our needs to Godot with this [Unity Tutorial](https://www.youtube.com/watch?v=3sWTzMsmdx8) as reference. |
PatternOverlay | [View](https://github.com/TomGrzembke/YokaiParade/blob/main/shader/pattern_overlay.gdshader) | Allows for an overlay texture with blending options like a world scale to "move the pattern" along with the movement.|
PlayerCamera | [View](https://github.com/TomGrzembke/YokaiParade/blob/main/levels/scenes/player_camera.gd) | With an `offset_value` for looking ahead when you traveled `minimum_change_distance`. |

</div>

## Additional Info
This Project was displayed at [Talk and Play 53](https://www.flickr.com/photos/12601747@N00/54931210627/in/album-72177720330395625) and [Indietreff 45](https://www.indietreff.de/game/yokai-parade/)
- Work Time: December 2024 to March 2025 (10 weeks)
- Godot Version: 4.4.

### Edge Correction Example:
![EdgeCorrection](https://github.com/user-attachments/assets/bb06d32e-3a2f-47d9-bbfe-7e086c59f4e2)

## Packages: 
- [Better Terrain](https://github.com/Portponky/better-terrain)
