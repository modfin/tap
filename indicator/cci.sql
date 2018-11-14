CREATE OR REPLACE FUNCTION tap_cci(_interval INT, _instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, cci DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY
  WITH
      tp AS (
        SELECT
          t.close_date,
          t.typprice
        FROM tap_typprice(_instrument_id, _from - _interval * 2, _to) t
    ),
      atp AS (
        SELECT
          mm.close_date,
          avg.sma atp
        FROM tp mm
          INNER JOIN
          LATERAL (
          SELECT avg(lat.typprice) sma
          FROM (
                 SELECT *
                 FROM tp tt
                 WHERE tt.close_date <= mm.close_date
                 ORDER BY tt.close_date DESC
                 LIMIT _interval
               ) lat
          ) avg ON TRUE
    ),
      md AS (
        SELECT
          mm.close_date,
          avg.md md
        FROM atp mm
          INNER JOIN
          LATERAL (
          SELECT avg(abs(lat.typprice - mm.atp)) md
          FROM (
                 SELECT *
                 FROM tp tt
                 WHERE tt.close_date <= mm.close_date
                 ORDER BY tt.close_date DESC
                 LIMIT _interval
               ) lat
          ) avg ON TRUE
    )
  SELECT t.close_date, (t.typprice - a.atp) / (0.015 * m.md) FROM tp t
  INNER JOIN atp a
  USING(close_date)
  INNER JOIN md m
  USING(close_date)
  WHERE a.close_date BETWEEN _from AND _to
  ORDER BY a.close_date
  ;




END;
$$;
