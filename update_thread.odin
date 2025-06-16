package main

import "core:fmt"
import "core:math/rand"
import "core:sync/chan"
import "core:thread"
import rl "vendor:raylib"

// ------------------------------------------------------------------------------------------------
// Thread responsible for syncing workers and dealing with user input
// ------------------------------------------------------------------------------------------------

update :: proc(channel: chan.Chan([]u8), inputChannel: chan.Chan(KeysPressed)) {
	defer cleanupWorkerThreads()

	for running {
		flushThreads := userInput()

		syncThreads()

		if flushThreads {
			flushRandomNoiseIntoState()
		}

		chan.send(channel, gridAptr^)
		gridAptr, gridBptr = swapPtr(gridAptr, gridBptr)
	}
}


// ------------------------------------------------------------------------------------------------

cleanupWorkerThreads :: proc() {
	for i in 0 ..< THREADS {
		chan.close(channels[i])
	}

	thread.join_multiple(..threads[:])
	for i in 0 ..< THREADS {
		thread.destroy(threads[i])
	}

	for i in 0 ..< THREADS {
		chan.destroy(channels[i])
	}
}

// ------------------------------------------------------------------------------------------------

flushRandomNoiseIntoState :: #force_inline proc() {
	for i in 0 ..< GridSize {
		if rand.int_max(100) < 10 {
			gridBptr[i] = 1
		} else {
			gridBptr[i] = 0
		}
	}
}

// ------------------------------------------------------------------------------------------------

syncThreads :: #force_inline proc() {
	for i in 0 ..< THREADS {
		chan.send(channels[i], true)
	}
	for i in 0 ..< THREADS {
		_, _ = chan.recv(channels[i])
	}
}

// ------------------------------------------------------------------------------------------------

swapPtr :: #force_inline proc(prtA, prtB: ^[]u8) -> (^[]u8, ^[]u8) {
	return prtB, prtA
}

// ------------------------------------------------------------------------------------------------

userInput :: #force_inline proc() -> bool {
	keysDown: [TOTALKEYS]b8
	flushThreads := false

	keysPressed: KeysPressed

	for i in 0 ..< TOTALKEYS {
		keysPressed, keysDown[i] = getKeysPressed(keys[i], keysDown[i], keysPressed, keyActions[i])
	}

	// Game speed
	if UserInput.FifteenFps in keysPressed {
		targetFrameTime = FPS_15
	}
	if UserInput.ThirtyFps in keysPressed {
		targetFrameTime = FPS_30
	}
	if UserInput.SixtyFps in keysPressed {
		targetFrameTime = FPS_60
	}
	if UserInput.OneHundredFourtyFourFps in keysPressed {
		targetFrameTime = FPS_144
	}
	if UserInput.MaxFps in keysPressed {
		targetFrameTime = FPS_MAX
	}

	// Signals threads to flush some random noise into the gridA and to clear grid B.
	if UserInput.Randomise in keysPressed {
		flushThreads = true
	}

	return flushThreads
}

// ------------------------------------------------------------------------------------------------

getKeysPressed :: #force_inline proc(
	key: rl.KeyboardKey,
	status: b8,
	curKeyset: KeysPressed,
	keyAction: UserInput,
) -> (
	KeysPressed,
	b8,
) {
	if rl.IsKeyDown(key) && !status {
		return curKeyset | {keyAction}, true
	} else if rl.IsKeyReleased(key) {
		return curKeyset, false
	}

	return curKeyset, status
}

// ------------------------------------------------------------------------------------------------
