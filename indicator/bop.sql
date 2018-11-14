CREATE OR REPLACE FUNCTION tap_bop(_stock_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, bop DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY
  SELECT m.close_date, (m.close_price - m.open_price) / (m.high_price - m.low_price) bop
  FROM tap_price_data_interval(_stock_id,  _from, _to) m;
END;
$$;
