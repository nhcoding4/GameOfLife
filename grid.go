package main

import (
	"sync"

	rl "github.com/gen2brain/raylib-go/raylib"
)

// --------------------------------------------------------------------------------------------------------------------

type Grid struct {
	grid                    [][]Cell
	gridLength              int
	nextState               [][]bool
	columns, rows, cellsize int32
	stateChannel            chan ([][]bool)
	waitGroup               sync.WaitGroup
}

// --------------------------------------------------------------------------------------------------------------------

func newGrid(width, height, cellSize int32, stateChan chan [][]bool) *Grid {
	rows := height / cellSize
	columns := width / cellSize
	grid := &Grid{columns: columns, rows: rows, cellsize: cellSize, stateChannel: stateChan}
	grid.init()
	grid.gridLength = len(grid.grid)

	return grid
}

// --------------------------------------------------------------------------------------------------------------------

func (g *Grid) init() {
	g.initArrays()
	g.setNeighbours()
}

// --------------------------------------------------------------------------------------------------------------------

func (g *Grid) initArrays() {
	newGrid := make([][]Cell, 0)
	newState := make([][]bool, 0)

	for y := range g.rows {
		newGridRow := make([]Cell, 0)
		newStateRow := make([]bool, 0)

		for x := range g.columns {
			cell := newCell(x, y)
			newGridRow = append(newGridRow, cell)
			newStateRow = append(newStateRow, false)
		}

		newGrid = append(newGrid, newGridRow)
		newState = append(newState, newStateRow)
	}

	g.grid = newGrid
	g.nextState = newState
}

// --------------------------------------------------------------------------------------------------------------------

func (g *Grid) setNeighbours() {
	offsets := []rl.Vector2{
		{X: -1, Y: 0},
		{X: 1, Y: 0},
		{X: 0, Y: -1},
		{X: 0, Y: 1},
		{X: -1, Y: -1},
		{X: -1, Y: 1},
		{X: 1, Y: -1},
		{X: 1, Y: 1},
	}

	for y := range g.rows {
		for x := range g.columns {
			for _, offset := range offsets {
				cellX := (x + g.columns + int32(offset.X)) % g.columns
				cellY := (y + g.rows + int32(offset.Y)) % g.rows

				g.grid[y][x].neighbours = append(g.grid[y][x].neighbours, &g.grid[cellY][cellX])
			}
		}
	}
}

// --------------------------------------------------------------------------------------------------------------------
// Hot path
// --------------------------------------------------------------------------------------------------------------------

func (g *Grid) update() {
	g.calcNewState()
	g.applyState()
}

// --------------------------------------------------------------------------------------------------------------------

func (g *Grid) calcNewState() {
	g.waitGroup.Add(g.gridLength)

	for y := range g.grid {
		g.calcRow(y)
	}

	g.waitGroup.Wait()

	g.stateChannel <- g.nextState
}

// --------------------------------------------------------------------------------------------------------------------

func (g *Grid) calcRow(y int) {
	for x, cell := range g.grid[y] {
		if !cell.active {
			continue
		}

		liveNeighbours := cell.countLiveNeighbours()

		switch liveNeighbours {
		case 3:
			g.nextState[y][x] = true
		case 2:
		default:
			g.nextState[y][x] = false
		}

		for _, neighbour := range cell.neighbours {
			if neighbour.countLiveNeighbours() == 3 {
				g.nextState[neighbour.gridY][neighbour.gridX] = true
			}
		}
	}

	g.waitGroup.Done()
}

// --------------------------------------------------------------------------------------------------------------------

func (g *Grid) applyState() {
	for y := range g.rows {
		for x := range g.columns {
			g.grid[y][x].active = g.nextState[y][x]
		}
	}
}

// --------------------------------------------------------------------------------------------------------------------
