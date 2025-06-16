package main

import "core:sync/chan"
import "core:thread"
import rl "vendor:raylib"

// -----------------------------------------------------------------------------------------------
// Constants
// -----------------------------------------------------------------------------------------------

// Window
WIDTH := 1920
HEIGHT := 1080
TITLE :: "Game Of Life"

// Grid - min cellsize should be 1 or you get a blank screen (cant draw smaller than 1px)
CELLSIZE :: 1

/* 
Threading - on a 6 core cpu, 3 seems to be the magic number. Note this is worker threads processing the grid.
1 -> Main/Draw
2 -> Update manger/input
3, 4, 5 -> Worker threads 

Not giving the os a thread seems to pull performance down
*/
THREADS :: 3

// How far ahead the update thread is allowed to get of the draw/main thread.
MAIN_CHAN_SIZE :: 1000

// Raylib time converted to real time in ms
FPS_MAX :: (1.0 / 1000.0) / 1000.0
FPS_144 :: (1000.0 / 144.0) / 1000.0
FPS_60 :: (1000.0 / 60.0) / 1000.0
FPS_30 :: (1000.0 / 30.0) / 1000.0
FPS_15 :: (1000.0 / 15.0) / 1000.0

// User input 
TOTALKEYS :: 6


// -----------------------------------------------------------------------------------------------
// Globals - Mainly Stuff needed across threads
// -----------------------------------------------------------------------------------------------

// These 2 are not constant but should act as they are
Rows := HEIGHT / CELLSIZE
Columns := WIDTH / CELLSIZE
GridSize := Rows * Columns

ColumnsI32 := i32(Columns)
ColumnsF64 := f64(Columns)

WidthF64 := f64(WIDTH)
HeightF64 := f64(HEIGHT)

GridSizeI32 := i32(GridSize)

// Frametime
targetFrameTime: f64 = FPS_MAX

// Grid state
gridA: []u8
gridB: []u8
gridAptr: ^[]u8
gridBptr: ^[]u8

// Threads and channels
threads: [THREADS]^thread.Thread
channels: [THREADS]chan.Chan(b8)

// Needed by threads to calculate next state
offsets: [][8]int
startStop: [THREADS]Vector2int

// Flags
running := true

// User input 
keys := []rl.KeyboardKey {
	rl.KeyboardKey.ONE,
	rl.KeyboardKey.TWO,
	rl.KeyboardKey.THREE,
	rl.KeyboardKey.FOUR,
	rl.KeyboardKey.FIVE,
	rl.KeyboardKey.R,
}

keyActions := []UserInput {
	.FifteenFps,
	.ThirtyFps,
	.SixtyFps,
	.OneHundredFourtyFourFps,
	.MaxFps,
	.Randomise,
}


// -----------------------------------------------------------------------------------------------
