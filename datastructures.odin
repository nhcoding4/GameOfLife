package main

import "core:fmt"
import "core:math/rand"
import "core:sync/chan"
import "core:thread"

import rl "vendor:raylib"

Vector2int :: [2]int
Vector2i32 :: [2]i32
Vector2u16 :: [2]u16

UserInput :: enum u8 {
	FifteenFps,
	ThirtyFps,
	SixtyFps,
	OneHundredFourtyFourFps,
	MaxFps,
	Randomise,
}

KeysPressed :: bit_set[UserInput]

// ------------------------------------------------------------------------------------------------

initDatastructures :: #force_inline proc(
) -> (
	chan.Chan([]u8),
	chan.Chan(KeysPressed),
	^thread.Thread,
) {
	createStartStopIdx()
	createOffsetData()

	gridA = createGrid(true)
	gridB = createGrid(false)
	gridAptr = &gridA
	gridBptr = &gridB

	mainChan, inputChan := createChannels()

	createWorkerThreads()
	updateThread := thread.create_and_start_with_poly_data2(mainChan, inputChan, update)

	return mainChan, inputChan, updateThread
}

// ------------------------------------------------------------------------------------------------

createGrid :: #force_inline proc(randomise: b8) -> []u8 {
	grid := make([]u8, GridSize)

	if randomise {
		for i in 0 ..< GridSize {
			if rand.int_max(100) < 10 {
				grid[i] = 1
			}
		}
	}

	return grid
}


// ------------------------------------------------------------------------------------------------

createOffsetData :: #force_inline proc() {
	deltaOffsets := [3]int{-1, 0, 1}
	offsets = make([][8]int, GridSize)
	idx := 0

	for i in 0 ..< GridSize {
		row := i / Columns
		column := i % Columns

		for dy in deltaOffsets {
			for dx in deltaOffsets {
				if dy == 0 && dx == 0 {
					continue
				}

				rowOffset := (row + dy + Rows) % Rows
				columnOffset := (column + dx + Columns) % Columns
				offsets[i][idx] = rowOffset * Columns + columnOffset

				idx += 1
			}
		}

		idx = 0
	}
}

// ------------------------------------------------------------------------------------------------

createStartStopIdx :: #force_inline proc() {
	idx := -1
	jump := GridSize / THREADS
	start := 0
	stop := 0

	for stop < GridSize {
		idx += 1
		start = stop
		stop += jump

		if idx == THREADS - 1 {
			stop = GridSize
		}

		startStop[idx].x = start
		startStop[idx].y = stop
	}
}

// ------------------------------------------------------------------------------------------------

createChannels :: #force_inline proc() -> (chan.Chan([]u8), chan.Chan(KeysPressed)) {
	for i in 0 ..< THREADS {
		workerChan, err := chan.create_unbuffered(chan.Chan(b8), context.allocator)
		assert(err == nil, fmt.tprintf("Error: failed to create worker thread: %v.\n", i, err))
		channels[i] = workerChan
	}

	mainChan, mainErr := chan.create_buffered(chan.Chan([]u8), MAIN_CHAN_SIZE, context.allocator)
	assert(
		mainErr == nil,
		fmt.tprintf("Error: failed to create main thread channel to update thread:\n%v", mainErr),
	)

	inputChan, inputErr := chan.create_buffered(
		chan.Chan(KeysPressed),
		MAIN_CHAN_SIZE,
		context.allocator,
	)
	assert(
		inputErr == nil,
		fmt.tprintf(
			"Error: failed to create channel used for transmitting user input:\n%v",
			inputErr,
		),
	)

	return mainChan, inputChan
}

// ------------------------------------------------------------------------------------------------

createWorkerThreads :: #force_inline proc() {
	for i in 0 ..< THREADS {
		threads[i] = thread.create_and_start_with_poly_data2(
			channels[i],
			byte(i),
			updateRow,
			nil,
			thread.Thread_Priority.High,
		)
	}

}

// ------------------------------------------------------------------------------------------------
