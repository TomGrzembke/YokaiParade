[![Yokai Parade](./thumbnail_yokai_parade.jpg)](https://s4g.itch.io/yokai-parade)


# Yokai Parade

**Yokai Parade is a 2D speedrun platformer, where you can steal the powers of other Yokai to get to the great parade faster. Use a double-jump to get over wide gaps or the fire-dash to break through bamboo walls and find the quickest path to the goal.**

This [Godot](https://godotengine.org/) game, was written in GDScript as part of the first semester project at [S4G School for Games](https://www.school4games.net/) in 10 weeks, from December 2024 to March 2025.

[Play directly on, or download from itch.io!](https://s4g.itch.io/yokai-parade)


## Contributions

Engineering consisted of two people and while my colleague Tommy focused on player abilities and movement, including loads of adjacent creature comforts and shaders, I took care of the overall game framework, technical UI and menu foundations,
level tileset and level object setup and enemies. Some sound effects were also created by me, but the really good ones and the fantastic music are from Laziri.


## Noteworthy Aspects

### [Game Framework](./game)
The game runs two nested state machines, one for the overall [game states](./game/game_state.gd) like startup or main menu, and another one within the in-game state that manages the [level states](/levels/level_state.gd) like loading, playing, paused and many more helper states.

The code is split so that purely state- and transition-related logic is contained in scripts inside the states/ folders, while the scene-related functionality lives inside scripts of the same name in the scenes/ folder (tscn and script files).

The game scene and script are responsible for playing the music and being remote-controlled by the game states to ensure smooth fading between menu and in-game music as well as continuous playback across all level states.
Everything is wired up by invoking methods from encapsulating to contained states and scenes, and signals in the other direction, in accordance with best practices of Godot.

Oh and also mind the little animation that runs stutter-free during the level load screen by using ResourceLoader.load_threaded_request... unless you play the game in the browser, where I had to hide it because the HTML5
exports of Godot don't support multi-threading.

### [Enemies](./enemies)
Enemies are also basically state machines, implementing the same split as described above. There are two 'elemental' types of enemies, fire and air, and each has a walking and flying variant. Both variants function very differently,
ground-based movement uses physics and a cliff-detection while the flying variants use a `PathFollow2D`. Since PathFollow2D must be a **direct** child of a `Path` node with nothing in between, and I wanted to let the Level Designers easily draw paths in the levels,
class inheritance could not be used to have common code in a parent class. Instead I made heavy use of 'components', that bundled functionality in Nodes with attached scripts, which could be attached to both variants of the enemies.

The [EnemyGrounded](./enemies/enemy_grounded.gd) script and scenes show how the top `CharacterBody2D` node and its script are oblivious to the logic in the components, only the state nodes reference exactly those components whose services they need.

The different elemental types got their sprites and animations through `Resources`, which was another way to avoid code-duplicaton, and would make it easier to create more elemental types that drop specific abilities on being hit.
