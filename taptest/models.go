package taptest

import "time"

type PriceData struct {
	InstrumentId int64
	CloseDate    time.Time
	OpenPrice    float64
	ClosePrice   float64
	HighPrice    float64
	LowPrice     float64
	Quantity     int64
	Turnover     float64
	NumOfTrades  int64
	MCAP         float64
}


type OneVal struct {
	CloseDate time.Time
	Float1 float64
}
type TwoVal struct {
	CloseDate time.Time
	Float1 float64
	Float2 float64
}
type ThreeVal struct {
	CloseDate time.Time
	Float1 float64
	Float2 float64
	Float3 float64
}