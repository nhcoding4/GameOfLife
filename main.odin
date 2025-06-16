package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:sync/chan"
import "core:thread"
import rl "vendor:raylib"

// ------------------------------------------------------------------------------------------------

main :: proc() {
	initMain()
	defer rl.CloseWindow()

	mainChan, inputChan, updateThread := initDatastructures()
	defer cleanUpMain(mainChan, inputChan, updateThread)

	mainLoop(mainChan)

	running = false
}

// ------------------------------------------------------------------------------------------------

cleanUpMain :: proc(
	mainChan: chan.Chan([]u8),
	inputChan: chan.Chan(KeysPressed),
	updateThread: ^thread.Thread,
) {
	chan.close(mainChan)
	chan.close(inputChan)

	thread.join(updateThread)
	thread.destroy(updateThread)

	chan.destroy(mainChan)
	chan.destroy(inputChan)
}

// ------------------------------------------------------------------------------------------------

initMain :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .MSAA_4X_HINT, .WINDOW_HIGHDPI})
	rl.InitWindow(i32(WIDTH), i32(HEIGHT), TITLE)
}

// ------------------------------------------------------------------------------------------------
