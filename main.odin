package main

import "core:fmt"
import "core:thread"
import rl "vendor:raylib"

// ------------------------------------------------------------------------------------------------

main :: proc() {
	Title :: "Game Of Life"
	rl.InitWindow(WindowWidth, WindowHeight, Title)
	rl.SetConfigFlags({.WINDOW_HIGHDPI, .MSAA_4X_HINT})
	mainLoop()
}

// ------------------------------------------------------------------------------------------------
