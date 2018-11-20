CREATE OR REPLACE FUNCTION tap_aroonosc(_interval INT, _instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, aroonosc DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY
    SELECT
      a.close_date,
      a.up - a.down aroonosc
    FROM tap_aroon(_interval, _instrument_id, _from, _to) a;
END;
$$;
