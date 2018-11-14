CREATE OR REPLACE FUNCTION tap_apo(_short INT, _long INT, _stock_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, apo DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY
  SELECT
    short.close_date,
    short.ema - long.ema apo
  FROM tap_ema(_short, _stock_id, _from, _to) short 
    INNER JOIN tap_ema(_long, _stock_id, _from, _to) long
    USING(close_date)
  ORDER BY short.close_date;

END;
$$;