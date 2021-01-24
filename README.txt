0. General.
This application was created to create your own maps for
Mini Militia game. This editor is unstable, but with the correct
use everything will be fine :)
Wrote by x64BitWorm in PascalABC.

1. Launching the application.
After launching the application, you will see the map manager window.
Each map has a unique name and texture file.
Here you can save your card in the card library so that you do not lose it in the future.
To save a map, give it a name (only Latin letters without spaces) and write "export [map_name]".
You can load the previously saved map with the command "import [map_name]" (map list is shown below).
You can also delete maps from the library with the "delete [map_name]" command.
To edit the map in the workspace, press ENTER without entering any command.

2. Main functions.
After a quick loading, you will see a list of main functions,
to hide it press one of the buttons: WASD.
Below we will look at each of the functions.

3. Moving the camera.
Using the WASD keys you can navigate the map.

4. The sprite palette.
After pressing the P key, you will see a palette of blocks that
you can place on the map.
To select a block, left-click on it in the palette,
then press P to hide the palette. Now you can draw with this block on the map
holding and moving the mouse.
To use the pipette, click on any block on the map while the palette is open.

5. Layers.
The editor has 2 sprite layers: foreground and background.
Press L to switch between them.
The background will be behind when drawing the sprites.

6. Inserting objects.
Press I to activate the object editor.
Objects are needed to create spawn points for weapons, players, flags, pictures.
Left-click on an empty space to create a new object.
After creating an object, click on it to change its properties.
The object property editor has a wealth of help.
There are 7 types of objects in total:
picture in the background, picture in the foreground, weapon spawn point, player spawn point, CTF spawn point,
flag receiving platform, flag spawner.
Read the names for each object and their properties in the editor itself.
Here is an example of commands for creating a weapon spawner:
name wp_p_00
addprop weapon ak47,m16,uzi
Enter an empty command to close the property editor.
You can move objects on the screen by holding shift and dragging the mouse across the screen.

7. Collisions.
A collision is a polygon that behaves like a wall.
After you draw the map using the palette, you must create
colliders (so that you can't go through your buildings).
Press C to open the collision editor.
Detailed instructions for creating a collider are on the top left.

8. Change the size of the map.
Sometimes you may need to resize the map as you create it.
To do this, press R. Enter the number of blocks in width, then the number of blocks in height,
and then the mode of aligning the old map with the new one.

9. Image manager.
While inserting pictures on the map using the objects "spritebg" and "spritefg"
you need to know the names of the pictures. They can be recognized by pressing the M button.
After opening the library of pictures, you can navigate through the pages by entering their number.
The names of the pictures are written in the center of each picture.
To search for a picture by substring, use the "find [name]" command.
Enter an empty line to close the Image manager.
Warning: unfortunately the "insert" and "remove" commands do not work due to different
density of different displays, maybe I'll fix this in the future.

10. Saving the result and exporting it.
Press T to save the edited map.
To export to apk file, rename map.tmx to one of the original names
maps, and replace with one of the game maps (apk/assets/maps).
Next, re-sign the apk file and install it. Have a nice game :)
