 Trying to see how much I can push performance on game of life with my current level of programming skill. Started off getting around 10fps on a 1920 x 1080 grid (cell size = 2 px). Up to around 220-250fps (on the same machine). 

# What is Conway's Game Of Life?
It's a simple automata simulation that enacts 3 simple rules on a grid of 'cells'.
1. If a cell has 3 alive neighbours it comes alive.
2. If a cell has exactly 2 alive neighbours its status remains the same.
3. All other conditions mean the cell dies / remains dead.

Read more about it here: [Game Of Life](https://en.wikipedia.org/wiki/Conway's_Game_of_Life)

# Changes made since I started programming.
This was on of the first real program's I ever made (around Dec 2023). Since then it has seen the following changes:

- Just don't use oop and use (comparatively) sensible data structures instead and the program is suddenly > 20x faster.
