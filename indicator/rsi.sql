CREATE OR REPLACE FUNCTION tap_rsi(_interval INT, _instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, rsi DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
  _start DATE;
BEGIN

  RETURN QUERY
  WITH RECURSIVE prices AS (
      SELECT
        *,
        row_number()
        OVER () AS row_number
      FROM tap_price_data_interval(_instrument_id, _from - 2 * _interval, _to) p
      ORDER BY p.close_date
  ),
      gain AS (
      SELECT
        p.row_number,
        p.close_date,
        p.close_price,
        0 :: DOUBLE PRECISION AS gain
      FROM prices p
      WHERE p.row_number = 1

      UNION ALL

      SELECT
        p2.row_number,
        p2.close_date,
        p2.close_price,
        p2.close_price - gain.close_price AS gain
      FROM gain
        INNER JOIN prices p2 ON gain.row_number = p2.row_number - 1
    )
    , rs AS (
      SELECT
        p.*,
        avgGain,
        avgLoss
      FROM gain p
        INNER JOIN
        LATERAL (
        SELECT
          sum(r.gain)
            FILTER (WHERE r.gain > 0) / _interval avgGain,
          sum(-1 * r.gain)
            FILTER (WHERE r.gain < 0) / _interval avgLoss
        FROM (
               SELECT *
               FROM gain pp
               WHERE pp.close_date <= p.close_date
               ORDER BY pp.close_date DESC
               LIMIT _interval
             ) r

        ) av ON TRUE
  )
  SELECT
    g.close_date,
    100 - 100 / (1 + g.avgGain / g.avgLoss) rsi
  FROM rs g
  WHERE g.close_date BETWEEN _from AND _to
  ORDER BY g.close_date;
END;
$$;