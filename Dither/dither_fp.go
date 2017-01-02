package main

import (
	"encoding/binary"
	"fmt"
	"log"
	"math/rand"
	"os"
)

const (
	bufMask = 7
	FPBits  = 22
)

type FPNum int64

const FpOne FPNum = 1 << FPBits

func (f FPNum) ToFloat64() float64 {
	return float64(f) / float64(FpOne)
}

func FPNumFromFloat64(f float64) FPNum {
	return FPNum(f * float64(FpOne))
}

func (f FPNum) String() string {
	return fmt.Sprintf("%f", f.ToFloat64())
}

var Filter = [5]FPNum{
	FPNumFromFloat64(2.033),
	FPNumFromFloat64(-2.165),
	FPNumFromFloat64(1.959),
	FPNumFromFloat64(-1.590),
	FPNumFromFloat64(0.6149),
}

type ShapedDither struct {
	buffer [8]FPNum
	idx    int
}

func (f FPNum) Round() FPNum {
	if f >= 0 {
		return (f + 1<<(FPBits-1)) &^ (FpOne - 1)
	} else {
		return (f - 1<<(FPBits-1)) &^ (FpOne - 1)
	}
}

func (s *ShapedDither) Do(in FPNum) FPNum {
	r := FPNum(rand.Int63n(int64(FpOne))) + FPNum(rand.Int63n(int64(FpOne))) - FpOne
	//fmt.Println(r)
	//fmt.Printf("%016x\n", rand.Int63n(int64(FpOne)))

	xe := in + ((s.buffer[s.idx]*Filter[0])+
		(s.buffer[(s.idx-1)&bufMask]*Filter[1])+
		(s.buffer[(s.idx-2)&bufMask]*Filter[2])+
		(s.buffer[(s.idx-3)&bufMask]*Filter[3])+
		(s.buffer[(s.idx-4)&bufMask]*Filter[4]))>>FPBits

	//fmt.Println(s.buffer)

	result := (xe + r).Round()
	s.idx = (s.idx + 1) & bufMask
	s.buffer[s.idx] = xe - result

	//fmt.Println(result)
	return result
}

func main() {
	var (
		out *os.File
		err error
	)

	if len(os.Args) < 1 {
		log.Fatal("Out file must be provided")
	}

	if out, err = os.Create(os.Args[1]); err != nil {
		log.Fatal(err)
	}
	defer out.Close()

	var dither ShapedDither
	for i := 0; i < 44100*10; i++ {
		val := int16(dither.Do(0) >> FPBits)

		binary.Write(out, binary.LittleEndian, val)
	}
}
