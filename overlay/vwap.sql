CREATE OR REPLACE FUNCTION tap_vwap(_instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, vwap DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY
      SELECT a.close_date ::DATE, (turnover/quantity::DOUBLE PRECISION ) AS vwap
      FROM tap_price_data_interval(_instrument_id, _from, _to) a;

END;
$$;