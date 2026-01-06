# MMBasicSuite

A suite of MMBasic programs for PicoMite, delivering an integrated experience with utilities, games, and visual programs.

## Setup

Install the proper firmware from the "firmwares" folder.
flash\_nuke.uf2 resets your pico.

Copy the rest of the files on your SD card.

Here are my initial default settings I set up once:
```
OPTION CPUSPEED 396000
OPTION MODBUFF ENABLE
OPTION AUTORUN 1
OPTION COLOURCODE ON
OPTION CONTINUATION LINES ON
OPTION DEFAULT COLOURS GREEN, BLACK

OPTION F5 "RUN " + chr$(34) + "/startscreen.bas" + chr$(34) + chr$(13) + chr$(10)
OPTION F6 "RUN " + chr$(34) + "/screensaver.bas" + chr$(34) + chr$(13) + chr$(10)
OPTION F7 "RUN " + chr$(34) + "/menu.bas" + chr$(34) + chr$(13) + chr$(10)

' Required for most programs
LOAD "/libraries.bas"
LIBRARY SAVE

' If I have added a RTC module
OPTION RTC AUTO ENABLE
TIME$ = "HH:MM:SS"
DATE$ = "DD-MM-YY\[YY]"

' Add a custom autorun that runs at every system startup
LOAD "/autorun.bas" 
FLASH SAVE 1
```

## Available programs

### Root

- Menu.bas, OpenAudio.bas, OpenImage.bas, OpenText.bas:
  - File Explorer with File Management Operations: Browse storage and manage files and directories (copy, delete, rename, create folders)
  - Integrated Audio Player: Play audio files directly from the explorer (Mp3, Wav, Flac, Mod)
  - Integrated Image Viewer: View common image formats without leaving the environment (BMP, PNG, JPG)
  - Integrated Text Editor: Open, view, and edit text files within the system
- Autorun.bas: Custom autorun program that plays a custom sound and displays a custom image during system startup
- Libraries.bas: Bundle of common/shared functions
- Shell.bas: Mimics a linux environment Unix commands: ls, cd, cp, mkdir, rm, rename, load, edit, run (precursor of menu.bas)
- Startscreen.bas: Startup screen displaying system information, including battery health, CPU temperature, CPU speed, available memory, and a customizable ASCII header
- Screensaver.bas: Cute screensaver showing date, time (digital clock), and basic system status information (uptime, battery health, CPU temperature)

### Games

- Asteroids.bas: Arcade shooter inspired by Asteroids
- CircleOne.bas: Eat apples, grow, and outpace an AI opponent to win
- HauntedHouse.bas: Text-based adventure game where you explore a mysterious house, solve puzzles, and navigate its rooms while avoiding supernatural dangers
- Life.bas: Simulation of John Conway’s Game of Life, illustrating cellular automata and emergent behavior
- PicoBlocks.bas: Breakout-style arcade game where you bounce a ball to break blocks
- Pong.bas: Terminal-based Pong game using text for all rendering
- Sudoku.bas: Interactive Sudoku puzzle game

### Program

- Clock.bas: Simple analog clock
- Colorbars.bas: Video mode test program to validate colors and ratio
- ColorPicker.bas: Utility providing a complete list of supported color constants along with an interactive custom color picker
- FontViewer.bas: Reference utility for inspecting the default font and quickly identifying the ASCII and hexadecimal codes of characters
- Gradient.bas: Full color spectrum generator used to evaluate available colors under default video modes and framebuffer limitations
- Picobench2.61.bas: Benchmark and CPU stress-testing tool for evaluating system performance
- Picogotchi.bas: Virtual pet application inspired by Tamagotchi.
- Xor.bas: Demonstrates practical XOR techniques and use cases (variable swapping, encryption/decryption, and duplicate finding)

### Visuals

- Alien.bas: Collection of alien-like fractal patterns with unique procedural shapes
- BinaryTree: Displays the bifurcation diagram of the logistic map (https://en.wikipedia.org/wiki/Bifurcation\_diagram)
- Blob.bas: Emulates dynamic blob-like shapes with smooth motion and deformation effects
- Boing.bas: (non optimised) 3D simulation of a rolling and bouncing ball
- ChristmasTree.bas: 3D spinning Christmas tree with animated snowfall effect
- Cube.bas: Rotating 3D cube visualized as points in space
- Cube2.bas: Rotating 3D rainbow-colored wireframe cube
- Dragon.bas: Fractal patterns forming a dragon-like shape
- DragonCurve.bas: Dragon curve fractal (https://en.wikipedia.org/wiki/Dragon\_curve)
- Fire.bas: Classic Doom fire effect with dynamic pixel simulation
- Fireworks.bas: Pixel-based fireworks animation with dynamic particle bursts
- FractalStar.bas: Random star-shaped fractal patterns
- Grid.bas: 3D grid projection demonstrating perspective rendering
- Knot.bas: Font-based graphics demonstration creating swirling, pipe-like visual effects
- Lissajous.bas: Lissajous curve fractal (https://en.wikipedia.org/wiki/Lissajous\_curve)
- Lorenz.bas: Lorenz attractor fractal (https://en.wikipedia.org/wiki/Lorenz\_system)
- Mandelbrot.bas: Mandelbrot set fractal (https://en.wikipedia.org/wiki/Mandelbrot\_set)
- Matrix.bas: Classic matrix effect with cascading green text
- Noise.bas: Procedural noise pattern generator
- Pcb.bas: Font-based graphics demonstration creating animated PCB circuit patterns
- Plasma.bas: (non optimised) Emulates dynamic plasma with smooth motion and deformation effects
- Polygons.bas: Fractal visualization based on recursive polygon generation
- Rain.bas: Rain effect simulating falling droplets across the screen
- RainbowLine.bas: Rainbow-colored line bouncing around the screen with a trailing effect
- Raytrace.bas: Raytracing demonstration rendering a shaded sphere
- Retrowave.bas: Animated retrowave scene featuring a real-time day and night lighting cycle
- Retrowave2.bas: Wireframe mountain landscape inspired by retrowave aesthetics
- Sirograph.bas: Generates Spirograph-style geometric patterns (https://en.wikipedia.org/wiki/Spirograph)
- Sphere.bas: Bouncing \& rotating 3D sphere visualized as points in space
- Starfield.bas: Enhanced starfield animation with depth-based motion
- Starfield2.bas: Starfield animation inspired by the classic Windows 95 screensaver
- Tunnel.bas: (non optimised) Wormhole tunnel effect
