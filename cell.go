package main

import (
	"math/rand"

	rl "github.com/gen2brain/raylib-go/raylib"
)

type Cell struct {
	x, y, cellSize, gridX, gridY int32
	active                       bool
	neighbors                    []*Cell
	color                        rl.Color
}

func newCell(x, y, cellSize, gridX, gridY int32, color rl.Color) *Cell {
	cell := &Cell{
		x:        x,
		y:        y,
		cellSize: cellSize,
		gridX:    gridX,
		gridY:    gridY,
		color:    color,
	}
	cell.setStartingStatus()

	return cell
}

func (c *Cell) activeNeighbors() int32 {
	var count int32 = 0

	for _, cell := range c.neighbors {
		if cell.active {
			count++
		}
	}

	return count
}

func (c *Cell) draw() {
	rl.DrawRectangle(c.x, c.y, c.cellSize, c.cellSize, c.color)
}

func (c *Cell) setStartingStatus() {
	randomNumber := rand.Intn(100)
	if randomNumber <= 10 {
		c.active = true
	} else {
		c.active = false
	}
}
