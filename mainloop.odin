package main

import "core:fmt"
import "core:sync/chan"
import "core:thread"
import rl "vendor:raylib"

RUNNING: b8 = true

// ------------------------------------------------------------------------------------------------

mainLoop :: #force_inline proc() {
	positionalData := createPositionalData()

	channel, err := chan.create_buffered(chan.Chan([][]b8), ChannelSize, context.allocator)
	assert(err == nil, fmt.tprintf("Error: chan.create_buffered() failed: %v", err))

	updateThread := thread.create_and_start_with_poly_data(chan.as_send(channel), update)

	defer delete(positionalData)
	defer chan.destroy(channel)
	defer thread.destroy(updateThread)
	defer thread.join(updateThread)
	defer rl.CloseWindow()

	for !rl.WindowShouldClose() {
		data, ok := chan.recv(channel)
		if !ok {
			break
		}
		draw(&data, &positionalData)
	}

	RUNNING = false
}

// ------------------------------------------------------------------------------------------------

draw :: #force_inline proc(grid: ^[][]b8, positionalData: ^[][]Vector2(i32)) {
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(rl.BLACK)

	for row, y in positionalData {
		for cell, x in row {
			if grid[y][x] {
				rl.DrawRectangle(cell.x, cell.y, DrawSize, DrawSize, rl.WHITE)
			}
		}
	}

	rl.DrawFPS(0, 0)
}

// ------------------------------------------------------------------------------------------------

update :: proc(channel: chan.Chan([][]b8, .Send)) {
	swapPtr := proc(prtA, prtB: ^[][]b8) -> (^[][]b8, ^[][]b8) {
		return prtB, prtA
	}

	gridA := createGrid(true)
	gridB := createGrid(false)
	offsets := createOffsetData()

	defer delete(gridA)
	defer delete(gridB)
	defer delete(offsets)

	gridAPtr := &gridA
	gridBPtr := &gridB

	for RUNNING {
		for y in 0 ..< Rows {
			for x in 0 ..< Columns {
				alive: byte
				for offset in offsets[y][x] {
					if gridAPtr[offset.y][offset.x] {
						alive += 1
					}
				}

				switch alive {
				case 3:
					gridBPtr[y][x] = true
				case 2:
					gridBPtr[y][x] = gridAPtr[y][x]
				case:
					gridBPtr[y][x] = false
				}
			}
		}

		gridAPtr, gridBPtr = swapPtr(gridAPtr, gridBPtr)

		ok := chan.send(channel, gridAPtr^)
		if !ok {
			break
		}
	}
}

// ------------------------------------------------------------------------------------------------
