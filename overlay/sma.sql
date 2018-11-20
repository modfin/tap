CREATE OR REPLACE FUNCTION tap_sma(_interval INT, _instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, sma DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY

  WITH prices AS (
      SELECT *
      FROM tap_price_data_interval(_instrument_id, _from - _interval * 2, _to)
  )
  SELECT
    aph.close_date,
    avg.sma sma
  FROM prices aph
    INNER JOIN
    LATERAL (
    SELECT avg(lat.close_price) sma
    FROM (
           SELECT *
           FROM tap_price_data_limit(_instrument_id, aph.close_date, _interval)
         ) lat
    ) avg ON TRUE
  WHERE aph.close_date BETWEEN _from AND _to
  ORDER BY aph.close_date;

END;
$$;