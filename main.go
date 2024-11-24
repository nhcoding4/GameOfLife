package main

import (
	"fmt"

	rl "github.com/gen2brain/raylib-go/raylib"
)

func main() {
	const width = 1920
	const height = 1080
	const cellSize = 2

	rl.InitWindow(width, height, "Game of Life")
	defer rl.CloseWindow()

	grid := newGrid(int32(width), int32(height), cellSize, rl.White)
	go grid.createNewStates()

	for !rl.WindowShouldClose() {
		grid.pullState()
		fps := fmt.Sprintf("%v", rl.GetFPS())

		rl.BeginDrawing()
		rl.ClearBackground(rl.Black)
		grid.draw()
		rl.DrawText(fps, 0, 0, 40, rl.Green)
		rl.EndDrawing()
	}
}
