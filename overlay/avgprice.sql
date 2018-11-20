CREATE OR REPLACE FUNCTION tap_avgprice(_instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, avgprice DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY
      SELECT a.close_date ::DATE, ((high_price + low_price + close_price + open_price) / 4.0) :: DOUBLE PRECISION AS avgprice
      FROM tap_price_data_interval(_instrument_id, _from, _to) a;

END;
$$;