CREATE OR REPLACE FUNCTION tap_typprice(_stock_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, typprice DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY
      SELECT a.close_date ::DATE, ((high_price + low_price + close_price) / 3.0) :: DOUBLE PRECISION AS typprice
      FROM tap_price_data_interval(_stock_id, _from, _to) a;

END;
$$;