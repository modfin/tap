
-- Average True Range
CREATE OR REPLACE FUNCTION tap_atr(_interval INT, _instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, "atr" DOUBLE PRECISION, "atr_percent" DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN


  RETURN QUERY
  WITH true_range AS (
      SELECT *
      FROM tap_tr(_instrument_id, _from - _interval * 2, _to)
  )
  SELECT
    tr.close_date,
    avg.sma atr,
    avg.sma_percent atr_percent
  FROM true_range tr
    INNER JOIN
    LATERAL (
    SELECT
      avg(lat.tr) sma,
      avg(lat.tr_percent) sma_percent
    FROM (
           SELECT * FROM true_range inr
           WHERE inr.close_date <= tr.close_date
           ORDER BY inr.close_date DESC
           LIMIT _interval
         ) lat
    ) avg ON TRUE
  WHERE tr.close_date BETWEEN _from AND _to
  ORDER BY tr.close_date
  ;
END;
$$;
