CREATE OR REPLACE FUNCTION tap_aroon(_interval INT, _stock_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, up DOUBLE PRECISION, down DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY

  WITH hl AS (
      SELECT m.close_date, m.high_price, m.low_price
      FROM tap_price_data_interval(_stock_id,  _from - _interval*2, _to) m
  )
  SELECT
    dd.close_date,
    100.0*(_interval-low.bars)/_interval::DOUBLE PRECISION down,
    100.0*(_interval-high.bars)/_interval::DOUBLE PRECISION up
  FROM hl dd
    INNER JOIN
    LATERAL (
    SELECT count(*) bars
    FROM (
           SELECT *, split_part(min(low_price::TEXT || ' ' || aa.close_date) OVER (), ' ', 2)::DATE low_date
           FROM (
                  SELECT *
                  FROM hl mm1
                  WHERE mm1.close_date <= dd.close_date
                  ORDER BY mm1.close_date DESC
                  LIMIT _interval
                ) aa
    ) lat
    WHERE lat.close_date > lat.low_date
    ) low ON TRUE
    INNER JOIN
    LATERAL (
    SELECT count(*) bars
    FROM (
           SELECT *, split_part(max(high_price::TEXT || ' ' || aa.close_date) OVER (), ' ', 2)::DATE low_date
           FROM (
                  SELECT *
                  FROM hl mm1
                  WHERE mm1.close_date <= dd.close_date
                  ORDER BY mm1.close_date DESC
                  LIMIT _interval
                ) aa
         ) lat
    WHERE lat.close_date > lat.low_date
    ) high ON TRUE
  WHERE dd.close_date BETWEEN _from AND _to
  ORDER BY dd.close_date;
END;
$$;
