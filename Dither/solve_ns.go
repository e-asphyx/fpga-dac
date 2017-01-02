package main

import (
	"fmt"
	"github.com/e-asphyx/dsputils"
	"github.com/e-asphyx/go-gnuplot"
	"log"
	"math"
	"math/cmplx"
)

/*

Two pole:
H(z)=\frac{(1-q_1z^{-1})(1-q_2z^{-1})}{(1-p_1z^{-1})(1-p_2z^{-1})}\\
H(z)=\frac{1-(q_1+q_2)z^{-1}+q_1q_2z^{-2}}{1-(p_1+p_2)z^{-1}+p_1p_2z^{-2}}\\
p_1=p_2=-A \\
q_1=B\cos\theta+jB\sin\theta \\
q_2=B\cos\theta-jB\sin\theta \\
H(z)=\frac {1-2B\cos \theta z^{-1}+B^2z^{-2}}{1+2Az^{-1}+A^2z^{-2}} \\
G_{dc}=\frac{1-2B\cos\theta+B^2}{1+2A+A^2}\\
G_{max}=\frac{1+2B\cos\theta+B^2}{1-2A+A^2}\\
G_{min}=\frac{(1-B)\sqrt{B^2-2B\cos(2\theta)+1}}{A^2+2A\cos\theta+1}

One pole:
H(z)=\frac{(1-q_1z^{-1})(1-q_2z^{-1})}{1-p_1z^{-1}} \\
H(z)=\frac{1-(q_1+q_2)z^{-1}+q_1q_2z^{-2}}{1-p_1z^{-1}} \\
p_1=-A \\
q_1=B\cos\theta+jB\sin\theta \\
q_2=B\cos\theta-jB\sin\theta \\
H(z)=\frac {1-2B\cos \theta z^{-1}+B^2z^{-2}}{1+Az^{-1}} \\
G_{dc}=\frac{1-2B\cos\theta+B^2}{1+A}\\
G_{max}=\frac{1+2B\cos\theta+B^2}{1-A}\\
G_{min}=\frac{(1-B)\sqrt{B^2-2B\cos(2\theta)+1}}{\sqrt{A^2+2A\cos\theta+1}}
*/

const (
	BisectionTolerance float64 = 1e-12
	BisectionOne       float64 = 1 - BisectionTolerance
)

func solve(x0, x1, tol float64, f func(float64) float64) float64 {
	fx0 := f(x0)
	fx1 := f(x1)

	if math.Signbit(fx0) == math.Signbit(fx1) {
		// No root, find minimum
		if math.Abs(fx0) < math.Abs(fx1) {
			return x0
		} else {
			return x1
		}
	} else {
		for {
			m := (x0 + x1) / 2
			fm := f(m)

			if math.Abs(fm) < tol || x1-x0 < tol {
				return m
			}

			if math.Signbit(fm) == math.Signbit(fx0) {
				x0 = m
				fx0 = fm
			} else {
				x1 = m
			}
		}
	}
}

const fNotch = 4000

func TwoPole(fs float64) dsputils.PoleZero {
	var dcToNyquistDb float64 = -20
	var dcToNotchDb float64 = 10

	theta := fNotch * 2 * math.Pi / fs
	ct := math.Cos(theta)
	c2t := math.Cos(2 * theta)

	// Find A at B=1
	g0 := math.Pow(10, dcToNyquistDb/20)
	A := solve(0, BisectionOne, BisectionTolerance, func(x float64) float64 {
		// DC gain
		gDc := (2 - 2*ct) / (1 + 2*x + x*x)
		// Max gain
		gNyquist := (2 + 2*ct) / (1 - 2*x + x*x)
		return gDc/gNyquist - g0
	})

	// Adjust B
	g0 = math.Pow(10, dcToNotchDb/20)
	B := solve(0, BisectionOne, BisectionTolerance, func(x float64) float64 {
		// DC gain
		gDc := (1 - 2*x*ct + x*x) / (A*A + 2*A + 1)
		// Notch gain
		gNotch := ((1 - x) * math.Sqrt(x*x-2*x*c2t+1)) / (A*A + 2*A*ct + 1)
		return gDc/gNotch - g0
	})

	z0 := cmplx.Rect(B, theta)
	return dsputils.PoleZero{
		P: []complex128{complex(-A, 0), complex(-A, 0)},
		Z: []complex128{z0, cmplx.Conj(z0)},
	}
}

func OnePole(fs float64) dsputils.PoleZero {
	var dcToNyquistDb float64 = -20
	var dcToNotchDb float64 = 10

	theta := fNotch * 2 * math.Pi / fs
	ct := math.Cos(theta)
	c2t := math.Cos(2 * theta)

	// Find A at B=1
	g0 := math.Pow(10, dcToNyquistDb/20)
	A := solve(0, BisectionOne, BisectionTolerance, func(x float64) float64 {
		// DC gain
		gDc := (2 - 2*ct) / (1 + x)
		// Max gain
		gNyquist := (2 + 2*ct) / (1 - x)
		return gDc/gNyquist - g0
	})

	// Adjust B
	g0 = math.Pow(10, dcToNotchDb/20)
	B := solve(0, BisectionOne, BisectionTolerance, func(x float64) float64 {
		// DC gain
		gDc := (1 - 2*x*ct + x*x) / (1 + A)
		// Notch gain
		gNotch := ((1 - x) * math.Sqrt(x*x-2*x*c2t+1)) / math.Sqrt(A*A+2*A*ct+1)
		return gDc/gNotch - g0
	})

	z0 := cmplx.Rect(B, theta)
	return dsputils.PoleZero{
		P: []complex128{complex(-A, 0)},
		Z: []complex128{z0, cmplx.Conj(z0)},
	}
}

func SemiCheb(n int, fstop, fs float64) dsputils.PoleZero {
	t := fstop * 2 * math.Pi / fs

	zeros := make([]complex128, n)
	for i := n/2 + 1; i <= n; i++ {
		theta := math.Pi / (2 * float64(n)) * (float64(i)*2 - 1)
		v := -math.Cos(theta)

		zeros[i-1] = cmplx.Rect(1, v*t)
		zeros[n-i] = cmplx.Conj(zeros[i-1])
	}

	return dsputils.PoleZero{
		Z: zeros,
	}
}

func makeMinPhase(pz dsputils.PoleZero) dsputils.PoleZero {
	if len(pz.Z) < 2 {
		return pz
	}

	pz2 := dsputils.PoleZero{
		Z: make([]complex128, len(pz.Z)),
	}

	r := solve(math.SmallestNonzeroFloat64, 1, BisectionTolerance, func(x float64) float64 {
		for i, z := range pz.Z {
			pz2.Z[i] = cmplx.Rect(x, cmplx.Phase(z))
		}
		b := pz2.Coef().Norm().B
		return math.Abs(b[1]) - math.Abs(b[2])
	})

	for i, z := range pz.Z {
		pz2.Z[i] = cmplx.Rect(r, cmplx.Phase(z))
	}

	return dsputils.PoleZero{
		P: pz.P,
		Z: pz2.Z,
	}
}

func main() {
	//freqzTwoPole := TwoPole(192000).FreqZ(1000)
	//freqzOnePole := OnePole(192000).FreqZ(1000)
	semiCheb := SemiCheb(4, 24000, 384000)
	semiChebMin := makeMinPhase(semiCheb)

	freqzSemiCheb := semiCheb.FreqZ(1000, 384)
	freqzSemiChebMin := semiChebMin.FreqZ(1000, 384)

	fmt.Printf("Original: %v\n", semiCheb.Coef().Norm().B)
	fmt.Printf("Min phase: %v\n", semiChebMin.Coef().Norm().B)

	plot := gnuplot.Plot2D{
		Grid:   true,
		YLabel: "Mag dB",
		XLabel: "Freq kHz",
		YScale: gnuplot.ScaleDb,
		Datasets: []*gnuplot.Dataset{
			/*
				&gnuplot.Dataset{
					Title: "Two pole",
					Color: gnuplot.ColorRed,
					Data:  freqzTwoPole,
				},
				&gnuplot.Dataset{
					Title: "One pole",
					Color: gnuplot.ColorGreen,
					Data:  freqzOnePole,
				},
			*/
			&gnuplot.Dataset{
				Title: "Semi Chebyshev",
				Color: gnuplot.ColorRed,
				Data:  freqzSemiCheb,
			},
			&gnuplot.Dataset{
				Title: "Min phase",
				Color: gnuplot.ColorGreen,
				Data:  freqzSemiChebMin,
			},
		},
	}

	cmd, err := plot.Exec()
	if err != nil {
		log.Fatal(err)
	}
	cmd.Wait()
}
