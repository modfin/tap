package taptest

import (
	"fmt"
	"github.com/technicalviking/tulipindicators"
	"testing"
)





func TestCCI(t *testing.T){
	interval := 5
	for add:= 0; add < 10; add++ {
		pricedata, err := GetPriceData(from, to)

		if err != nil{
			t.Error(err)
			return
		}
		bands, err := GetCCI(interval+add, from, to)

		if err != nil{
			t.Error(err)
			return
		}
		var highPrice []float64
		var lowPrice []float64
		var closePrice []float64

		for _, p := range pricedata{
			closePrice = append(closePrice, p.ClosePrice)
			lowPrice = append(lowPrice, p.LowPrice)
			highPrice = append(highPrice, p.HighPrice)
		}


		sampleOptions := []float64{float64(interval+add)}
		sampleOutputs, err:= tulipindicators.Indicators["cci"](
			[][]float64{highPrice, lowPrice, closePrice},
			sampleOptions,
		)

		if err != nil{
			t.Error(err)
			return
		}

		for i := 0; i < 30; i++{
			need := float32(sampleOutputs[0][i])


			adjust := interval+3+(add*2)

			got := float32(bands[i+adjust].Float1)


			if need != got {
				fmt.Println(i, "Need", need, "got", got)
				fmt.Println()
				t.Fail()
			}


		}


	}

}



func TestNATR(t *testing.T){
	interval := 5
	for add:= 0; add < 1; add++ {
		pricedata, err := GetPriceData(from, to)

		if err != nil{
			t.Error(err)
			return
		}
		bands, err := GetNATR(interval+add, from, to)

		if err != nil{
			t.Error(err)
			return
		}
		var highPrice []float64
		var lowPrice []float64
		var closePrice []float64

		for _, p := range pricedata{
			closePrice = append(closePrice, p.ClosePrice)
			lowPrice = append(lowPrice, p.LowPrice)
			highPrice = append(highPrice, p.HighPrice)
		}


		sampleOptions := []float64{float64(interval+add)}
		sampleOutputs, err:= tulipindicators.Indicators["natr"](
			[][]float64{highPrice, lowPrice, closePrice},
			sampleOptions,
		)

		if err != nil{
			t.Error(err)
			return
		}

		for i := 0; i < 30; i++{
			need := float32(sampleOutputs[0][i])


			adjust := interval+3+(add*2)

			got := float32(bands[i+adjust].Float1)


			if need != got {
				fmt.Println(i, "Need", need, "got", got)
				fmt.Println()
				t.Fail()
			}


		}


	}

}



//
//// TODO check into, it seems that wildersum might not be correct?
//func TestATR(t *testing.T){
//	interval := 5
//	for add:= 0; add < 1; add++ {
//		pricedata, err := GetPriceData(from, to)
//
//		if err != nil{
//			t.Error(err)
//			return
//		}
//
//
//
//		var highPrice []float64
//		var lowPrice []float64
//		var closePrice []float64
//
//		for _, p := range pricedata{
//			closePrice = append(closePrice, p.ClosePrice)
//			lowPrice = append(lowPrice, p.LowPrice)
//			highPrice = append(highPrice, p.HighPrice)
//		}
//
//
//
//		sampleOptions := []float64{float64(interval+add)}
//		sampleOutputs, err:= tulipindicators.Indicators["atr"](
//			[][]float64{highPrice, lowPrice, closePrice},
//			sampleOptions,
//		)
//
//		if err != nil{
//			t.Error(err)
//			return
//		}
//
//
//		// It seems some how that wildersums are making a mess of things...
//		atr, err := GetATR(interval+add, pricedata[interval].CloseDate, to)
//
//		if err != nil{
//			t.Error(err)
//			return
//		}
//
//		for i := 0; i < 10; i++{
//			need := float32(sampleOutputs[0][i])
//
//
//			//adjust := 0//interval// interval-1//interval+3+(add*2)
//
//			got := float32(atr[i].Float1)
//
//			fmt.Println(i, "Need", need, "got", got)
//			if need != got {
//
//				t.FailNow()
//			}
//
//
//		}
//
//
//	}
//
//}