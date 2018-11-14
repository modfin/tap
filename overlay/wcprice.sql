CREATE OR REPLACE FUNCTION tap_wcprice(_stock_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, wcprice DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY
      SELECT a.close_date ::DATE, ((high_price + low_price + 2*close_price) / 4.0) :: DOUBLE PRECISION AS wcprice
      FROM tap_price_data_interval(_stock_id, _from, _to) a;

END;
$$;