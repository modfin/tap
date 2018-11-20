package taptest

import (
	"fmt"
	"github.com/technicalviking/tulipindicators"
	"testing"
	"time"
)

var from time.Time
var to time.Time

func init(){
	from, _ = time.Parse("2006-01-02", "2017-01-01")
	to, _ = time.Parse("2006-01-02", "2017-12-31")
}



func TestSMA(t *testing.T){
	interval := 10
	for add:= 0; add < 10; add++ {
		pricedata, err := GetPriceData(from, to)

		if err != nil{
			t.Error(err)
			return
		}
		sma, err := GetSMA(interval+add, from, to)

		if err != nil{
			t.Error(err)
			return
		}
		var sampleInputs []float64

		for _, p := range pricedata{
			// Tulip seams to whant things in reverse order for sma...
			sampleInputs = append([]float64{p.ClosePrice}, sampleInputs...)
		}


		sampleOptions := []float64{float64(interval+add)}

		sampleOutputs, err:= tulipindicators.Indicators["sma"](
			[][]float64{sampleInputs},
			sampleOptions,
		)

		if err != nil{
			t.Error(err)
			return
		}

		sLen := len(sma)
		for i := 0; i < 30; i++{
			smaI := sampleOutputs[0][i]
			smaP := sma[sLen-1-i]

			need :=  float32(smaI)
			got := float32(smaP.Float1)
			if need != got {
				fmt.Println("Need", need, ", got", got, ", for interval", interval+add, "item", i )
				t.Fail()
			}


		}


	}

}


func TestEMA(t *testing.T){
	interval := 5
	for add:= 0; add < 10; add++ {
		pricedata, err := GetPriceData(from, to)

		if err != nil{
			t.Error(err)
			return
		}
		ema, err := GetEMA(interval+add, from, to)

		if err != nil{
			t.Error(err)
			return
		}
		var sampleInputs []float64

		for _, p := range pricedata{
			//sampleInputs = append([]float64{p.ClosePrice}, sampleInputs...)
			sampleInputs = append(sampleInputs, p.ClosePrice)
		}


		sampleOptions := []float64{float64(interval+add)}
		sampleOutputs, err:= tulipindicators.Indicators["ema"](
			[][]float64{sampleInputs},
			sampleOptions,
		)

		if err != nil{
			t.Error(err)
			return
		}

		for i := 0; i < 60; i++{
			smaI := sampleOutputs[0][i]
			smaP := ema[i]
			p := sampleInputs[i]

			need :=  float32(smaI)
			got := float32(smaP.Float1)

			if need != got {
				fmt.Println(i, smaP.CloseDate.Format("2006-01-02"), "Need", need, ", got", got, ", for interval", interval+add, "price", p )
				t.Fail()
			}


		}


	}

}




func TestBBands(t *testing.T){
	interval := 5
	factor := 2
	for add:= 0; add < 10; add++ {
		pricedata, err := GetPriceData(from, to)

		if err != nil{
			t.Error(err)
			return
		}
		bands, err := GetBBands(interval+add, factor, from, to)

		if err != nil{
			t.Error(err)
			return
		}
		var sampleInputs []float64

		for _, p := range pricedata{
			sampleInputs = append(sampleInputs, p.ClosePrice)
		}


		sampleOptions := []float64{float64(interval+add), float64(factor)}
		sampleOutputs, err:= tulipindicators.Indicators["bbands"](
			[][]float64{sampleInputs},
			sampleOptions,
		)

		if err != nil{
			t.Error(err)
			return
		}

		for i := 0; i < 30; i++{
			needL := float32(sampleOutputs[0][i])
			needM := float32(sampleOutputs[1][i])
			needU := float32(sampleOutputs[2][i])


			adjust := interval+add-1

			gotL := float32(bands[i+adjust].Float1)
			gotM := float32(bands[i+adjust].Float2)
			gotU := float32(bands[i+adjust].Float3)


			if needL != gotL ||  needM != gotM || needU != gotU {
				fmt.Println(i, "Need", needL, needM, needU, "\n   got", gotL, gotM, gotU)
				fmt.Println()
				t.Fail()
			}


		}


	}

}


func TestTR(t *testing.T){
	pricedata, err := GetPriceData(from, to)

	if err != nil{
		t.Error(err)
		return
	}
	bands, err := GetTR(from, to)

	if err != nil{
		t.Error(err)
		return
	}
	var closePrice []float64
	var lowPrice []float64
	var highPrice []float64

	for _, p := range pricedata{
		closePrice = append(closePrice, p.ClosePrice)
		lowPrice = append(lowPrice, p.LowPrice)
		highPrice = append(highPrice, p.HighPrice)
	}


	sampleOptions := []float64{}
	sampleOutputs, err:= tulipindicators.Indicators["tr"](
		[][]float64{highPrice, lowPrice, closePrice},
		sampleOptions,
	)

	if err != nil{
		t.Error(err)
		return
	}

	for i := 0; i < 100; i++{
		need := float32(sampleOutputs[0][i])

		got := float32(bands[i].Float1)


		if need != got {
			fmt.Println(i, "Need", need, "\n   got", got)
			t.Fail()
		}


	}




}




// TODO for some reason har to compute in refrence to wilder with offset
//func TestWilders(t *testing.T){
//	for interval:= 5; interval <= 6; interval++ {
//		pricedata, err := GetPriceData(from, to)
//
//		if err != nil{
//			t.Error(err)
//			return
//		}
//
//		if err != nil{
//			t.Error(err)
//			return
//		}
//		var closePrice []float64
//
//		for _, p := range pricedata{
//			closePrice = append(closePrice, p.ClosePrice)
//		}
//
//
//		sampleOptions := []float64{float64(interval)}
//		sampleOutputs, err:= tulipindicators.Indicators["wilders"](
//			[][]float64{closePrice},
//			sampleOptions,
//		)
//
//		if err != nil{
//			t.Error(err)
//			return
//		}
//
//
//		whilders, err := GetWilders(interval, pricedata[interval].CloseDate, to)
//
//		for i := 0; i < 10; i++{
//			smaI := sampleOutputs[0][i]
//
//			adjust := 0// interval+add - 1
//
//			smaP := whilders[i + adjust]
//			p := closePrice[i+interval]
//
//			need :=  float32(smaI)
//			got := float32(smaP.Float1)
//
//
//			if need != got {
//				fmt.Println(i, smaP.CloseDate.Format("2006-01-02"), "Need", need, ", got", got, ", for interval", interval, "price", p )
//				t.Fail()
//			}
//
//
//		}
//
//
//	}
//
//}