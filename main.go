package main

import (
	rl "github.com/gen2brain/raylib-go/raylib"
)

// --------------------------------------------------------------------------------------------------------------------

const width = 1920
const height = 1080
const cellSize = 2
const drawingCellSize = cellSize - 1

// --------------------------------------------------------------------------------------------------------------------

func main() {
	stateChan := make(chan [][]bool, 1000)
	defer close(stateChan)

	rl.InitWindow(width, height, "Game of Life")
	defer rl.CloseWindow()

	grid := newGrid(width, height, cellSize, stateChan)
	go func() {
		for {
			grid.update()
		}
	}()

	var state [][]bool

	for !rl.WindowShouldClose() {
		state = <-stateChan

		rl.BeginDrawing()
		rl.ClearBackground(rl.Black)
		drawState(&state)
		rl.DrawFPS(0, 0)
		rl.EndDrawing()
	}
}

// --------------------------------------------------------------------------------------------------------------------

func drawState(state *[][]bool) {
	for y, row := range *state {
		yVal := int32(y)
		for x, active := range row {
			if active {
				rl.DrawRectangle(int32(x)*cellSize+1, yVal*cellSize+1, drawingCellSize, drawingCellSize, rl.White)
			}
		}
	}
}

// --------------------------------------------------------------------------------------------------------------------
