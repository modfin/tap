-- Average True Range
CREATE OR REPLACE FUNCTION tap_atr(_interval INT, _instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, "atr" DOUBLE PRECISION, "atr_percent" DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN


  RETURN QUERY
  WITH RECURSIVE true_range AS (
      SELECT * FROM tap_tr(_instrument_id, _from - _interval * 2, _to)
  ),
      t AS (
        SELECT row_number() OVER () AS row_number,
               tt.close_date,
               tt.tr,
               tt.tr_percent

        FROM true_range tt WHERE tt.close_date BETWEEN _from AND _to
    ),

      wilder AS (
      SELECT *, (SELECT avg(pp.tr)
                 FROM (SELECT *
                       FROM true_range pp
                       WHERE pp.close_date <= tt.close_date
                       ORDER BY tt.close_date DESC
                       LIMIT _interval) pp) AS atr,
                (SELECT avg(pp.tr_percent)
                 FROM (SELECT *
                       FROM true_range pp
                       WHERE pp.close_date <= tt.close_date
                       ORDER BY tt.close_date DESC
                       LIMIT _interval) pp) AS atr_percent
      FROM t tt
      WHERE row_number = 1

      UNION ALL

      SELECT t2.row_number, t2.close_date, t2.tr, t2.tr_percent,
             t2.tr / (_interval) + (_interval - 1) / _interval :: DOUBLE PRECISION * wilder.atr AS atr,
             t2.tr_percent / (_interval) + (_interval - 1) / _interval :: DOUBLE PRECISION * wilder.atr_percent AS atr_percent
      FROM wilder
             INNER JOIN t t2 ON wilder.row_number = t2.row_number - 1
    )

  SELECT wilder.close_date, wilder.atr, wilder.atr_percent FROM wilder WHERE wilder.close_date BETWEEN _from AND _to
  ;
END;
$$;
