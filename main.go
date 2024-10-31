package main

import (
	"fmt"

	rl "github.com/gen2brain/raylib-go/raylib"
)

func main() {
	//scaleFactor := int32(110)
	width := int32(1920)  //scaleFactor * 16
	height := int32(1080) //scaleFactor * 9
	lineLength := int32(2)
	gridColor := rl.White

	rl.SetConfigFlags(rl.FlagMsaa4xHint)
	rl.SetConfigFlags(rl.FlagWindowHighdpi)
	rl.SetConfigFlags(rl.FlagVsyncHint)
	rl.InitWindow(width, height, "Game of Life")

	grid := NewGrid(int(width), int(height), lineLength, gridColor)
	grid.Update()

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.Black)
		grid.Draw()
		rl.DrawText(fmt.Sprintf("%v", rl.GetFPS()), 0, 0, 40, rl.Green)
		rl.EndDrawing()
	}
	rl.CloseWindow()

}
