package main

import (
	"github.com/e-asphyx/go-gnuplot"
	"github.com/mjibson/go-dsp/fft"
	"log"
	"math"
	"math/cmplx"
	"math/rand"
)

var filterMP = [4]float64{-2.5979018437487995, 2.597901843748854, -1.1845774582410686, 0.20791290752555358}
var filterOrig = [4]float64{-3.8472674238585087, 5.697469543085019, -3.8472674238585087, 1}

const bufMask = 7

type ShapedDither struct {
	Filter [4]float64
	buffer [8]float64
	idx    int
}

func round(x float64) float64 {
	if x >= 0 {
		return math.Trunc(x + 0.5)
	} else {
		return math.Trunc(x - 0.5)
	}
}

func clamp(x, min, max float64) float64 {
	if x > max {
		return max
	} else if x < min {
		return min
	} else {
		return x
	}
}

func (s *ShapedDither) Do(in float64) float64 {
	r := rand.Float64() + rand.Float64() - 1.0

	xe := in + s.buffer[s.idx]*s.Filter[0] +
		s.buffer[(s.idx-1)&bufMask]*s.Filter[1] +
		s.buffer[(s.idx-2)&bufMask]*s.Filter[2] +
		s.buffer[(s.idx-3)&bufMask]*s.Filter[3]

	result := round(xe + r)
	s.idx = (s.idx + 1) & bufMask
	s.buffer[s.idx] = result - xe

	return result
}

func sine(sample int64, freq float64, fs int) float64 {
	phase := float64(sample) * freq * 2 * math.Pi / float64(fs)
	return math.Sin(phase)
}

func testSpectrum(freq float64, fs int, samples int64, filter [4]float64) []float64 {
	out := make([]float64, samples)

	dither := ShapedDither{
		Filter: filter,
	}

	for i := int64(0); i < samples; i++ {
		in := sine(i, freq, fs) * math.MaxInt16
		out[i] = dither.Do(in) / math.MaxInt16
	}

	// No window, we have periodical signal
	f := fft.FFTReal(out)

	spec := make([]float64, len(f)/2)
	for i := 0; i < len(f)/2; i++ {
		spec[i] = 20 * math.Log10(cmplx.Abs(f[i])/float64(len(f)))
	}

	return spec
}

func testRounded(freq float64, fs int, samples int64) []float64 {
	out := make([]float64, samples)

	for i := int64(0); i < samples; i++ {
		in := sine(i, freq, fs) * math.MaxInt16
		out[i] = round(in) / math.MaxInt16
	}

	// No window, we have periodical signal
	f := fft.FFTReal(out)

	spec := make([]float64, len(f)/2)
	for i := 0; i < len(f)/2; i++ {
		spec[i] = 20 * math.Log10(cmplx.Abs(f[i])/float64(len(f)))
	}

	return spec
}

func main() {
	var fs = 384000
	var freq = 4000
	var sampleNum = fs / 10

	specOrig := testSpectrum(float64(freq), fs, int64(sampleNum), filterOrig)
	specMP := testSpectrum(float64(freq), fs, int64(sampleNum), filterMP)
	specRound := testRounded(float64(freq), fs, int64(sampleNum))

	plot := gnuplot.Plot2D{
		Grid:   true,
		YLabel: "Mag dB",
		Data: []*gnuplot.Plot2Data{
			&gnuplot.Plot2Data{
				Title: "Semi Chebyshev",
				Color: gnuplot.RGBA{255, 0, 0, 128},
				Data:  gnuplot.DataY(specOrig),
			},
			&gnuplot.Plot2Data{
				Title: "Min phase",
				Color: gnuplot.RGBA{0, 255, 0, 128},
				Data:  gnuplot.DataY(specMP),
			},
			&gnuplot.Plot2Data{
				Title: "No dithering, no shaping",
				Color: gnuplot.RGBA{0, 0, 255, 128},
				Data:  gnuplot.DataY(specRound),
			},
		},
	}

	cmd, err := plot.Exec()
	if err != nil {
		log.Fatal(err)
	}
	cmd.Wait()
}
