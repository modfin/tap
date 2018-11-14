CREATE OR REPLACE FUNCTION tap_price_data_interval(_instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS SETOF a_price_data
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY

  SELECT
    inr.insref :: BIGINT                      instrument_id,
    inr.date :: DATE                          close_date,
    inr.openprice :: DOUBLE PRECISION         open_price,
    inr.closeprice :: DOUBLE PRECISION        close_price,
    inr.closedayhighprice :: DOUBLE PRECISION high_price,
    inr.closedaylowprice :: DOUBLE PRECISION  low_price,
    inr.closequantity :: BIGINT               quantity,
    inr.closeturnover :: DOUBLE PRECISION     turnover,
    inr.numtrades :: BIGINT                   num_of_trades,
    inr.mcap :: DOUBLE PRECISION              mcap

  FROM adjustedpricehistory inr
  WHERE inr.date BETWEEN _from AND _to
        AND inr.insref = _instrument_id
  ORDER BY date;
END;
$$;


CREATE OR REPLACE FUNCTION tap_price_data_limit(_instrument_id BIGINT, _at DATE, _limit INT)
  RETURNS SETOF a_price_data
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY

  SELECT *
  FROM (
         SELECT
           inr.insref :: BIGINT                      instrument_id,
           inr.date :: DATE                          close_date,
           inr.openprice :: DOUBLE PRECISION         open_price,
           inr.closeprice :: DOUBLE PRECISION        close_price,
           inr.closedayhighprice :: DOUBLE PRECISION high_price,
           inr.closedaylowprice :: DOUBLE PRECISION  low_price,
           inr.closequantity :: BIGINT               quantity,
           inr.closeturnover :: DOUBLE PRECISION     turnover,
           inr.numtrades :: BIGINT                   num_of_trades,
           inr.mcap :: DOUBLE PRECISION              mcap

         FROM adjustedpricehistory inr
         WHERE inr.date <= _at
               AND inr.insref = _instrument_id
         ORDER BY inr.date DESC
         LIMIT _limit
       ) a
  ORDER BY close_date;
END;
$$;