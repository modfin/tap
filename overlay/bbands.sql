CREATE OR REPLACE FUNCTION tap_bbands(_interval INT, _factor INT, _instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, sma DOUBLE PRECISION, upper DOUBLE PRECISION, lower DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY

  WITH prices AS (
      SELECT *
      FROM tap_price_data_interval(_instrument_id, _from - _interval * 2, _to) inr
  )
  SELECT
    aph.close_date,
    avg.sma                      sma,
    avg.sma + (stddev * _factor),
    avg.sma - (stddev * _factor) lower
  FROM prices aph
    INNER JOIN
    LATERAL (
    SELECT
      avg(lat.close_price)        sma,
      stddev_pop(lat.close_price) stddev
    FROM (
           SELECT inr.close_price
           FROM prices inr
           WHERE inr.close_date <= aph.close_date
           ORDER BY inr.close_date DESC
           LIMIT _interval
         ) lat
    ) avg ON TRUE
  WHERE aph.close_date BETWEEN _from AND _to
  ORDER BY aph.close_date;
END;
$$;