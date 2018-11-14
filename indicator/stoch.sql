
CREATE OR REPLACE FUNCTION tap_stoch(_interval INT, _factor INT, _instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, K DOUBLE PRECISION, D DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY
  WITH normal AS (

      SELECT
        aph.close_date,

        ((aph.close_price - k.low) / (k.high - k.low)) :: DOUBLE PRECISION AS K

      FROM tap_price_data_interval(_instrument_id, _from, _to) aph
        INNER JOIN
        LATERAL (
        SELECT
          max(high_price) high,
          min(low_price)  low
        FROM tap_price_data_limit(_instrument_id, aph.close_date, _interval) inr
        ) AS k ON TRUE
      ORDER BY aph.close_date
  )

  SELECT
    n.close_date,
    100 * n.K AS K,
    100 * d.D AS D
  FROM normal n
    INNER JOIN
    LATERAL (
    SELECT avg(d.K) :: DOUBLE PRECISION AS D
    FROM (
           SELECT inr.k
           FROM normal inr
           WHERE inr.close_date <= n.close_date
           ORDER BY inr.close_date DESC
           LIMIT _factor
         ) AS d
    ) AS d ON TRUE;
END;
$$;


CREATE OR REPLACE FUNCTION tap_stoch(_instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, K DOUBLE PRECISION, D DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY SELECT *
               FROM tap_stoch(14, 3, _instrument_id, _from, _to);
END;
$$;