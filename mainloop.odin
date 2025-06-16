package main

import "core:math"
import "core:sync/chan"
import rl "vendor:raylib"

// ------------------------------------------------------------------------------------------------

mainLoop :: proc(mainChan: chan.Chan([]u8)) {
	scaleFactorX := 1.0
	scaleFactorY := 1.0
	drawSizeX := i32(math.round_f64(CELLSIZE * scaleFactorX))
	drawSizeY := i32(math.round_f64(CELLSIZE * scaleFactorY))

	for !rl.WindowShouldClose() {
		start := rl.GetTime()

		data, _ := chan.recv(mainChan)

		if rl.IsWindowResized() {
			scaleFactorX, scaleFactorY, drawSizeX, drawSizeY = setScaling()
		}

		draw(data, drawSizeX, drawSizeY, scaleFactorX, scaleFactorY)

		hitFrameTime(start)
	}
}

// ------------------------------------------------------------------------------------------------

draw :: #force_inline proc(
	data: []u8,
	drawSizeX, drawSizeY: i32,
	scaleFactorX, scaleFactorY: f64,
) {
	rl.BeginDrawing()

	rl.ClearBackground(rl.BLACK)

	for i in 0 ..< GridSizeI32 {
		if data[i] == 1 {
			rl.DrawRectangle(
				i32(math.round_f64(f64((i % ColumnsI32) * CELLSIZE + 1.0) * scaleFactorX)),
				i32(math.round_f64((f64(i) / ColumnsF64) * CELLSIZE + 1.0) * scaleFactorY),
				drawSizeX,
				drawSizeY,
				rl.WHITE,
			)
		}
	}

	rl.DrawFPS(0, 0)

	rl.EndDrawing()
}

// ------------------------------------------------------------------------------------------------

hitFrameTime :: #force_inline proc(start: f64) {
	end := rl.GetTime()
	for end - start < targetFrameTime {
		end = rl.GetTime()
	}
}

// ------------------------------------------------------------------------------------------------

setScaling :: #force_inline proc() -> (f64, f64, i32, i32) {
	scaleFactorX := f64(rl.GetScreenWidth()) / WidthF64
	if scaleFactorX < 1.0 {
		scaleFactorX = 1.0
	}

	scaleFactorY := f64(rl.GetScreenHeight()) / HeightF64
	if scaleFactorY < 1.0 {
		scaleFactorY = 1.0
	}

	drawSizeX := i32(math.round_f64(CELLSIZE * scaleFactorX))
	drawSizeY := i32(math.round_f64(CELLSIZE * scaleFactorY))

	return scaleFactorX, scaleFactorY, drawSizeX, drawSizeY
}

// ------------------------------------------------------------------------------------------------
