CREATE OR REPLACE FUNCTION tap_wilders(_interval INT, _instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, wilders DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY
  WITH RECURSIVE prices AS (
      SELECT
             aph.close_date  dt,
             aph.close_price closeprice
      FROM tap_price_data_interval(_instrument_id, _from - 2*_interval, _to) aph
      ORDER BY aph.close_date
  ),
      t AS (
        SELECT
               dt,
               row_number() OVER () AS row_number,
               closeprice
        FROM prices
        WHERE dt BETWEEN _from AND _to
        ORDER BY dt
    ),

      wilder AS (
      SELECT *, (SELECT avg(pp.closeprice)
                 FROM (SELECT *
                       FROM prices pp
                       WHERE pp.dt <= tt.dt
                       ORDER BY tt.dt DESC
                       LIMIT _interval) pp) AS closeprice_wilder
      FROM t tt
      WHERE row_number = 1

      UNION ALL

      SELECT
             today.dt,
             today.row_number,
             today.closeprice,

             today.closeprice / (_interval::DOUBLE PRECISION)
               +  (_interval - 1 )/_interval::DOUBLE PRECISION * yesterday.closeprice_wilder AS closeprice_wilder
      FROM wilder yesterday
             INNER JOIN t today ON yesterday.row_number + 1 = today.row_number
    )

  SELECT
     dt    close_date,
     closeprice_wilder wilders
  FROM wilder
  WHERE dt BETWEEN _from AND _to;

END;
$$;