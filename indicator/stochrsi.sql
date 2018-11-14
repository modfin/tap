

CREATE OR REPLACE FUNCTION tap_stochrsi(_interval INT, _instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, stochrsi DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY
  WITH rsi AS (
    SELECT * FROM tap_rsi(_interval, _instrument_id, _from - 2*_interval, _to )
  )
  SELECT
    n.close_date,
    (n.rsi - rrr.rmin) / (rrr.rmax - rrr.rmin)
  FROM rsi n
    INNER JOIN
    LATERAL (
    SELECT max(rr.rsi) rmax, min(rr.rsi) rmin
    FROM (
           SELECT *
           FROM rsi r
           WHERE r.close_date <= n.close_date
           ORDER BY r.close_date DESC
           LIMIT _interval
         ) AS rr
    ) AS rrr ON TRUE
   WHERE n.close_date BETWEEN _from AND _to
  ;
END;
$$;