package main

import (
	"fmt"

	rl "github.com/gen2brain/raylib-go/raylib"
)

func main() {	
	width := int32(1920)  
	height := int32(1080) 
	lineLength := int32(2)
	gridColor := rl.White

	rl.SetConfigFlags(rl.FlagMsaa4xHint)
	rl.SetConfigFlags(rl.FlagWindowHighdpi)
	rl.InitWindow(width, height, "Game of Life")

	grid := NewGrid(int(width), int(height), lineLength, gridColor)

	go grid.CreateStates()

	for !rl.WindowShouldClose() {
		grid.pullState()
		rl.BeginDrawing()
		rl.ClearBackground(rl.Black)
		grid.Draw()
		rl.DrawText(fmt.Sprintf("%v", rl.GetFPS()), 0, 0, 40, rl.Green)
		rl.EndDrawing()
	}
	rl.CloseWindow()
}
