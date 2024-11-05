package main

import (
	rl "github.com/gen2brain/raylib-go/raylib"
)

type Grid struct {
	cells        [][]*Cell
	rows         int
	columns      int
	lineLength   int32
	stateData    chan [][]*Cell
	gridColor    rl.Color
	currentState [][]*Cell
}

func NewGrid(screenWidth, screenHeight int, lineLength int32, color rl.Color) *Grid {
	newGrid := &Grid{
		rows:       screenHeight / int(lineLength),
		columns:    screenWidth / int(lineLength),
		lineLength: lineLength,
		stateData:  make(chan [][]*Cell, 144),
		gridColor:  color,
	}
	newGrid.populate()
	newGrid.neighbors()

	return newGrid
}

func (g *Grid) Draw() {
	for _, row := range g.cells {
		for _, cell := range row {
			cell.Draw()
		}
	}
}

func (g *Grid) neighbors() {
	type Pair struct {
		x int
		y int
	}
	pairs := []Pair{{-1, 0}, {1, 0}, {0, -1}, {0, 1}, {-1, -1}, {-1, 1}, {1, -1}, {1, 1}}

	calculateOffset := func(y, x int) {
		offsets := make([]Pair, 0)

		for _, pair := range pairs {
			yOffset := (y + pair.y + g.rows) % g.rows
			xOffset := (x + pair.x + g.columns) % g.columns

			offsets = append(offsets, Pair{x: xOffset, y: yOffset})
		}

		for _, pair := range offsets {
			g.cells[y][x].neighbors = append(g.cells[y][x].neighbors, g.cells[pair.y][pair.x])
		}
	}

	for y := range g.rows {
		for x := range g.columns {
			calculateOffset(y, x)
		}
	}
}

func (g *Grid) populate() {
	for y := range g.rows {
		newRow := make([]*Cell, 0)
		for x := range g.columns {
			newRow = append(newRow, NewCell(NewVec2(int32(x*int(g.lineLength)+1), int32(y*int(g.lineLength)+1)), g.lineLength-1, g.gridColor))
		}
		g.cells = append(g.cells, newRow)
	}
}

func (g *Grid) CreateStates() {
	for {
		newState := make([][]bool, 0)

		for y, row := range g.cells {
			newRow := make([]bool, 0)
			for x, cell := range row {
				switch cell.AliveNeighbors() {
				case 3:
					newRow = append(newRow, true)
				case 2:
					newRow = append(newRow, g.cells[y][x].active)
				default:
					newRow = append(newRow, false)
				}
			}
			newState = append(newState, newRow)
		}

		for y, row := range g.cells {
			for x := range row {
				g.cells[y][x].active = newState[y][x]
			}
		}

		g.stateData <- g.cells
	}
}

func (g *Grid) PullState() {
	if len(g.stateData) > 0 {
		g.currentState = <-g.stateData
	}

}
