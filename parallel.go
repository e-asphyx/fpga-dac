package main

import (
	"bufio"
	"fmt"
	"log"
	"math"
	"os"
	"strconv"
	"strings"
)

const (
	FpBits  = 22
	Samples = 8
)

func round(x float64) float64 {
	if x >= 0 {
		return math.Trunc(x + 0.5)
	} else {
		return math.Trunc(x - 0.5)
	}
}

func main() {
	if len(os.Args) < 1 {
		log.Fatal("Table must be provided")
	}

	var (
		in  *os.File
		err error
	)

	if in, err = os.Open(os.Args[1]); err != nil {
		log.Fatal(err)
	}
	defer in.Close()

	coef := make([]float64, 0, 1024)

	scanner := bufio.NewScanner(in)
	for scanner.Scan() {
		s := strings.TrimSpace(scanner.Text())
		if s == "" || s[0] == '#' || s[0] == '%' {
			continue
		}

		if val, err := strconv.ParseFloat(s, 64); err == nil {
			coef = append(coef, val)
		}
	}
	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}

	bufSz := (len(coef) + 7) / 8
	for step := 0; step < 8; step++ {
		fmt.Printf("// step %d\n", step)

		for idx := 0; idx < bufSz; idx++ {
			tap := step + idx*8
			if tap < len(coef) {
				val := int32(round(coef[tap] * 8 * (1 << FpBits)))
				fmt.Printf("mul_%d_%d <= buffer[%d] * (%d);\n", step, idx, idx, val)
			}
		}
	}
}
