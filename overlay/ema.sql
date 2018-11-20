CREATE OR REPLACE FUNCTION tap_ema(_interval INT, _instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, ema DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN

  RETURN QUERY
  WITH RECURSIVE prices AS (
      SELECT
        aph.close_date  dt,
        aph.close_price closeprice
      FROM tap_price_data_interval(_instrument_id, _from, _to) aph
      ORDER BY aph.close_date
  ),
      t AS (
        SELECT
          dt,
          2.0 / (_interval + 1) AS alpha,
          row_number()
          OVER (),
          closeprice
        FROM prices
    ),

      ema AS (
      SELECT
        *,
        closeprice AS closeprice_ema
      FROM t
      WHERE row_number = 1

      UNION ALL

      SELECT
        t2.dt,
        t2.alpha,
        t2.row_number,
        t2.closeprice,

        (t2.closeprice - ema.closeprice_ema) * t2.alpha + ema.closeprice_ema AS closeprice_ema
      FROM ema
        INNER JOIN t t2 ON ema.row_number = t2.row_number - 1
    )

  SELECT
    dt             close_date,
    closeprice_ema ema
  FROM ema
  WHERE dt BETWEEN _from AND _to;

END;
$$;