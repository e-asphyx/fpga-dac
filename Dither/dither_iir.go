package main

import (
	"encoding/binary"
	"fmt"
	"log"
	"math"
	"math/rand"
	"os"
)

func solve(x0, x1, tol float64, f func(float64) float64) float64 {
	fx1 := f(x1)

	for {
		m := (x0 + x1) / 2
		fm := f(m)

		if fm == 0 || x1-x0 < tol {
			return m
		}

		if math.Signbit(fm) == math.Signbit(fx1) {
			x1 = m
			fx1 = fm
		} else {
			x0 = m
		}
	}
}

type Filter struct {
	B    [3]float64
	A    [3]float64
	Gain float64
	d1   float64
	d2   float64
}

const fNotch = 4000

func ShaperFilter(fs float64, gain_db float64) Filter {
	theta := fNotch * 2 * math.Pi / fs
	ct := math.Cos(theta)
	g0 := math.Pow(10, -gain_db*2/20)

	bb := solve(0, 0.99999, 1e-12, func(x float64) float64 {
		// DC gain
		g_dc := (2 - 2*ct) / ((x + 1) * (x + 1))
		// Max gain
		g_max := (2 + 2*ct) / ((x - 1) * (x - 1))
		return g_dc/g_max - g0
	})

	g_dc := (2 - 2*ct) / ((bb + 1) * (bb + 1))
	g_max := (2 + 2*ct) / ((bb - 1) * (bb - 1))
	g_dc_db := 20 * math.Log10(g_dc)
	g_max_db := 20 * math.Log10(g_max)

	pre_db := -(g_max_db + g_dc_db) / 2
	pre := math.Pow(10, pre_db/20)

	fmt.Printf("DC gain: %f dB (%f)\n", g_dc_db, g_dc)
	fmt.Printf("Nyquist gain: %f dB (%f)\n", g_max_db, g_max)

	fmt.Printf("Pregain: %f dB (%f)\n", pre_db, pre)

	/*
		coef := FilterCoef{
			B: [3]float64{
				1,
				-2 * ct,
				1,
			},
			A: [3]float64{
				1,
				2 * bb,
				bb * bb,
			},
		}
	*/

	filter := Filter{
		B: [3]float64{
			-2*ct - 2*bb,
			1 - bb*bb,
		},
		A: [3]float64{
			1,
			2 * bb,
			bb * bb,
		},
		Gain: pre,
	}

	return filter
}

// Single transposed Direct Form II Biquad
func (f *Filter) Do(x float64) float64 {
	x = x * f.Gain
	y := f.B[0]*x + f.d1
	f.d1 = f.B[1]*x - f.A[1]*y + f.d2
	f.d2 = f.B[2]*x - f.A[2]*y
	return y
}

type ShapedDither struct {
	Filter Filter
	delay  float64 // z^-1
}

func round(x float64) float64 {
	if x >= 0 {
		return math.Trunc(x + 0.5)
	} else {
		return math.Trunc(x - 0.5)
	}
}

func (s *ShapedDither) Do(in float64) float64 {
	r := rand.Float64() + rand.Float64() - 1.0

	xe := in + s.Filter.Do(s.delay)
	result := round(xe + r)
	s.delay = result - xe
	return result
}

func Clamp(x, min, max float64) float64 {
	if x > max {
		return max
	} else if x < min {
		return min
	} else {
		return x
	}
}

func main() {
	var (
		in  *os.File
		out *os.File
		err error
	)

	if len(os.Args) < 3 {
		log.Fatal("In and out files must be provided")
	}

	if in, err = os.Open(os.Args[1]); err != nil {
		log.Fatal(err)
	}
	defer in.Close()

	if out, err = os.Create(os.Args[2]); err != nil {
		log.Fatal(err)
	}
	defer out.Close()

	filter := ShaperFilter(44100, 20)

	ditherL := ShapedDither{
		Filter: filter,
	}

	ditherR := ShapedDither{
		Filter: filter,
	}

	var ilval, irval int32
	for {
		if binary.Read(in, binary.LittleEndian, &ilval) != nil {
			break
		}
		if binary.Read(in, binary.LittleEndian, &irval) != nil {
			break
		}

		lval := ditherL.Do(float64(ilval) / float64(1<<16))
		rval := ditherR.Do(float64(irval) / float64(1<<16))

		lout := int16(Clamp(lval, math.MinInt16, math.MaxInt16))
		rout := int16(Clamp(rval, math.MinInt16, math.MaxInt16))

		binary.Write(out, binary.LittleEndian, lout)
		binary.Write(out, binary.LittleEndian, rout)
	}
}
