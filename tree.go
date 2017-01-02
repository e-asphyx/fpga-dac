package main

import "fmt"

const N = 32

func main() {
	stage := 1
	for s := N; s >= 1; s >>= 1 {
		fmt.Printf("// Stage %d\n", stage-1)
		for i := 0; i < s; i++ {
			fmt.Printf("sum_stage%d_%d <= sum_stage%d_%d + sum_stage%d_%d;\n", stage, i, stage-1, i*2, stage-1, i*2+1)
		}
		stage++
	}
}
