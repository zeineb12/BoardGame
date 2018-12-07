# BoardGame

The Processing sketch named Game.pde displays a 3D board at the center of the screen, with a ball (3D sphere) on it:

- Mouse drag tilts the board around the X and Z axes.

- Mouse wheel increases/decreases the tilt motion speed.

- When the board is tilted, the ball moves according to the gravity and friction (gravity points toward +Y).

- By pressing the Shift key, a top view of the board is displayed (object placement mode). In this mode, a click on the board surface adds a new cylinder at click?s location.

- These cylinders remain on the board when the Shift key is released, and move with the board when it is tilted with the mouse.

- The ball collides with the cylinders and board?s edges. The correct collision distance is computed.

- When colliding with a cylinder or hitting the edges of the board, the ball makes a realistic bounce.