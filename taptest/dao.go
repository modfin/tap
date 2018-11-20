package taptest

import (
	"errors"
	"fmt"
	"github.com/jmoiron/sqlx"
	"regexp"
	"strings"
	"sync"
	"sync/atomic"
	"time"
	_ "github.com/lib/pq"
)


type Once struct {
	m    sync.Mutex
	done uint32
}

// adapted from sync.Once.Do to support errors
func (o *Once) Do(f func() error) (err error) {
	if atomic.LoadUint32(&o.done) == 1 {
		return
	}
	// Slow-path.
	o.m.Lock()
	defer o.m.Unlock()
	if o.done == 0 {
		defer func() {
			if r := recover(); r != nil  {
				msg := fmt.Sprint("oncex: failed to init, panic:", r)
				fmt.Println(msg)
				err = errors.New(msg)
			} else if err != nil {
				fmt.Println("oncex: failed to init, error:", err)
			} else {
				atomic.StoreUint32(&o.done, 1)
			}
		}()
		err = f()
	}
	return
}


var db *sqlx.DB
var mu sync.Mutex
var camel = regexp.MustCompile("(^[^A-Z]*|[A-Z]*)([A-Z][^A-Z]+|$)")
var once = &Once{}


func GetDB() (*sqlx.DB, error) {

	err := once.Do(func() (error) {
		d, err := sqlx.Open("postgres", "postgres://postgres:qwerty@localhost:6543/tap?sslmode=disable")
		if err != nil {
			return err
		}
		db = d
		db.MapperFunc(camelToSnake)
		db.SetMaxOpenConns(10)
		//db.SetMaxIdleConns(0)
		db.SetConnMaxLifetime(time.Minute * 1)

		return nil
	})
	return db, err
}

func camelToSnake(s string) string {
	var a []string
	for _, sub := range camel.FindAllStringSubmatch(s, -1) {
		if sub[1] != "" {
			a = append(a, sub[1])
		}
		if sub[2] != "" {
			a = append(a, sub[2])
		}
	}
	return strings.ToLower(strings.Join(a, "_"))
}


func GetPriceData(from, to time.Time) ([]PriceData, error){
	dbb, err := GetDB()

	if err != nil{
		return nil, err
	}


	q := `
  	SELECT * FROM tap_price_data_interval(0, $1, $2) ORDER BY close_date
  `

	var prices []PriceData
	err = dbb.Select(&prices, q, from, to)
	return prices, err
}

func GetSMA(interval int, from, to time.Time) ([]OneVal, error){
	dbb, err := GetDB()

	if err != nil{
		return nil, err
	}


	q := `
  	SELECT close_date, sma float1 FROM tap_sma($1, 0, $2, $3)
  `

	var sma []OneVal
	err = dbb.Select(&sma, q, interval, from, to)
	return sma, err
}

func GetEMA(interval int, from, to time.Time) ([]OneVal, error){
	dbb, err := GetDB()

	if err != nil{
		return nil, err
	}


	q := `
  	SELECT close_date, ema float1 FROM tap_ema($1, 0, $2, $3)
  `

	var ema []OneVal
	err = dbb.Select(&ema, q, interval, from, to)
	return ema, err
}

func GetBBands(interval int, factor int, from, to time.Time) ([]ThreeVal, error){
	dbb, err := GetDB()

	if err != nil{
		return nil, err
	}


	q := `
  	SELECT close_date, "lower" float1, "sma" float2, "upper" float3 FROM tap_bbands($1, $2, 0, $3, $4)
  `

	var bands []ThreeVal
	err = dbb.Select(&bands, q, interval, factor, from, to)
	return bands, err
}