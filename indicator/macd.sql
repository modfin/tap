
CREATE OR REPLACE FUNCTION tap_macd(_short INT, _long INT, _signal INT, _instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, macd DOUBLE PRECISION, signal DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
  _start DATE;
BEGIN

  SELECT aa.close_date
  INTO _start
  FROM tap_price_data_limit(_instrument_id, _from - 1, 2 * _long) aa
  ORDER BY aa.close_date DESC
  LIMIT 1;


  RETURN QUERY

  WITH RECURSIVE md AS (
      SELECT
        short.close_date     AS close_date,
        short.ema - long.ema AS macd
      FROM tap_ema(_short, _instrument_id, _start, _to) short
        INNER JOIN tap_ema(_long, _instrument_id, _start, _to) long
          ON short.close_date = long.close_date
      ORDER BY short.close_date
  ),
      t AS (
        SELECT
          md.close_date,
          2.0 / (_signal + 1) AS alpha,
          row_number()
          OVER ()             AS row_number,
          md.macd
        FROM md
    ),
      ema AS (
      SELECT
        *,
        t.macd AS signal
      FROM t
      WHERE t.row_number = 1

      UNION ALL

      SELECT
        t2.close_date,
        t2.alpha,
        t2.row_number,
        t2.macd,

        (t2.macd - ema.signal) * t2.alpha + ema.signal AS signal
      FROM ema
        INNER JOIN t t2 ON ema.row_number = t2.row_number - 1
    )

  SELECT
    ema.close_date,
    ema.macd,
    ema.signal
  FROM ema
  WHERE ema.close_date BETWEEN _from AND _to;
END;
$$;