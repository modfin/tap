CREATE OR REPLACE FUNCTION tap_medprice(_stock_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, medprice DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY
      SELECT a.close_date ::DATE, ((high_price + low_price) / 2.0) :: DOUBLE PRECISION AS medprice
      FROM tap_price_data_interval(_stock_id, _from, _to) a;

END;
$$;