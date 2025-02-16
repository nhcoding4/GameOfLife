package main

import "math/rand"

// --------------------------------------------------------------------------------------------------------------------

type Cell struct {
	gridX, gridY int32
	neighbours   []*Cell
	active       bool
}

// --------------------------------------------------------------------------------------------------------------------

func newCell(gridX, gridY int32) Cell {
	return Cell{
		neighbours: make([]*Cell, 0),
		gridX:      gridX,
		gridY:      gridY,
		active:     rand.Intn(100) <= 10,
	}
}

// --------------------------------------------------------------------------------------------------------------------

func (c *Cell) countLiveNeighbours() uint8 {
	var alive uint8 = 0

	for _, cell := range c.neighbours {
		if cell.active {
			alive += 1
		}
	}

	return alive
}

// --------------------------------------------------------------------------------------------------------------------
