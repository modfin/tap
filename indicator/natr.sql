
-- Normalized Average True Range
CREATE OR REPLACE FUNCTION tap_natr(_interval INT, _instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, "natr" DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN


  RETURN QUERY
  SELECT
    atr.close_date,
    100 * atr.atr / price.close_price AS natr
  FROM tap_atr(_interval, _instrument_id, _from, _to) atr
    INNER JOIN tap_price_data_interval(_instrument_id, _from, _to) price
    USING(close_date)
  ORDER BY atr.close_date
  ;
END;
$$;
