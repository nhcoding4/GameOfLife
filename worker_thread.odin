package main

import "core:fmt"
import "core:math/rand"
import "core:sync/chan"

// ------------------------------------------------------------------------------------------------
// Worker threads. Each one of these updates a section of the grid.
// ------------------------------------------------------------------------------------------------

updateRow :: proc(toThread: chan.Chan(b8), idx: byte) {
	start := startStop[idx].x
	stop := startStop[idx].y

	for running {
		_, _ = chan.recv(toThread)

		for i in start ..< stop {
			alive: byte = 0

			for offset in offsets[i] {
				alive += gridAptr[offset]
			}

			switch alive {
			case 3:
				gridBptr[i] = 1
			case 2:
				gridBptr[i] = gridAptr[i]
			case:
				gridBptr[i] = 0
			}
		}

		_ = chan.send(toThread, true)
	}
}

// ------------------------------------------------------------------------------------------------
