# PICO-8 Snake Game
My first PICO-8 project, a simple snake game 6-day side-project to learn PICO-8 (and Lua language) from scratch on the fly.

## Features
* Adjustable grid from code
* Optimized drawing
* Partitioned collision detection
* Adjustable speed
* Input buffer

|Gif|Info|
|---|---|
|![](/gifs/snake_0.gif)|First working version, drawing is Rect based|
|![](/gifs/snake_4.gif)|First version using sprites to enhance clarity of movement|
|![](/gifs/snake_5.gif)|Simple more stylized sprites|
|![](/gifs/snake_15.gif)|Sprites improvement, all parts have correct orientation|
|![](/gifs/snake_16.gif)|Example of a smaller grid|

## Technical problems and solutions throughout development
* In order to allow adjustable grid sizes, a logic coordinate system seperate from the console drawing was used, and uses game logic to screen space convertion.
* Since the game is tick based without animations in-between, redrawing the gamestate every frame update hurt performance, so the game uses optimized drawing where only the changes are added to the draw buffer.
* Checking all possible collisions in the game every update tick also hurt performance, so collision segments were added, splitting the play area to smaller segments, using lookup tables to provide efficient collision detection.
* Visual clarity in anticipating the next moves means the snake must leave a visually clear trail, so sprites are used for the 4 possible different parts (head, body, corner, tail) in both orientations, using internal cell direction to decide how to handle the sprite drawing.
* In order for the controls to be responsive an input buffer was used, allowing the player to input more than one move before the next frame update.

## Changes I would like to add
* Better seperation of concerns, extracting more code to smaller functions (specifically the update functions).
* Adding a menu to select grid sizes instead of changing those values in code.
* Draw the final state when winning, the code order will need some refactoring to do it efficiently.
* Add some animations to make the game feel more fluid and visually appealing.
