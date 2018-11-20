CREATE OR REPLACE FUNCTION tap_ao(_instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, ao DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY

  WITH hl AS (
      SELECT m.close_date, m.medprice
      FROM tap_medprice(_instrument_id, _from - 64, _to) m
  )
  SELECT
    dd.close_date,
    avg1.m1 - avg2.m2 ao
  FROM hl dd
    INNER JOIN
    LATERAL (
    SELECT avg(lat.medprice) m1
    FROM (
           SELECT *
           FROM hl mm1
           WHERE mm1.close_date <= dd.close_date
           ORDER BY mm1.close_date DESC
           LIMIT 5
         ) lat
    ) avg1 ON TRUE
    INNER JOIN
    LATERAL (
    SELECT avg(lat.medprice) m2
    FROM (
           SELECT *
           FROM hl mm2
           WHERE mm2.close_date <= dd.close_date
           ORDER BY mm2.close_date DESC
           LIMIT 34
         ) lat
    ) avg2 ON TRUE

  WHERE dd.close_date BETWEEN _from AND _to
  ORDER BY dd.close_date;

END;
$$;