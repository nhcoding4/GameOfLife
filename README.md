 Trying to see how much I can push performance on game of life with my current level of programming skill. This sees a ~-600%-~ ~-900%-~ ~>1000%~ 2400% performance uplift compared to my old version. 

# What is Conway's Game Of Life?
It's a simple automata simulation that enacts 3 simple rules on a grid of 'cells'.
1. If a cell has 3 alive neighbours it comes alive.
2. If a cell has exactly 2 alive neighbours its status remains the same.
3. All other conditions mean the cell dies / remains dead.

Read more about it here: [Game Of Life](https://en.wikipedia.org/wiki/Conway's_Game_of_Life)

# Changes made since I started programming.
This was on of the first real program's I ever made (around Dec 2023). Since then it has seen the following changes.

1.  Use a grid of bools and update in place instead of creating an entire new grid every update tick.
2.  Calculate neighbour cells before any drawing is done and store neighbours inside a struct.
3.  Separate state calculation and drawing into their own go routines.
4.  Only perform calculation on cells that are currently alive and their neighbours.
