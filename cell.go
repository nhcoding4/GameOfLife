package main

import (
	"math/rand"

	rl "github.com/gen2brain/raylib-go/raylib"
)

type Vec2 struct {
	x int32
	y int32
}

func NewVec2(x, y int32) Vec2 {
	return Vec2{x: x, y: y}
}

type Cell struct {
	active     bool
	sideLength int32
	color      rl.Color
	centerPos  Vec2
	neighbors  []*Cell
}

func NewCell(centerPos Vec2, sideLength int32, color rl.Color) *Cell {
	newCell := &Cell{
		sideLength: sideLength,
		color:      color,
		centerPos:  centerPos,
	}
	newCell.setStartingState()

	return newCell
}

func (c *Cell) AliveNeighbors() int {
	alive := 0

	for _, neighbor := range c.neighbors {
		if neighbor.active {
			alive++
		}
	}

	return alive
}

func (c *Cell) Draw() {
	if c.active {
		rl.DrawRectangle(c.centerPos.x, c.centerPos.y, c.sideLength, c.sideLength, c.color)
	}
}

func (c *Cell) setStartingState() {
	randNumber := rand.Intn(100)

	if randNumber <= 10 {
		c.active = true
	} else {
		c.active = false
	}
}
