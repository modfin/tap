CREATE OR REPLACE FUNCTION tap_vwma(_interval INT, _stock_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, vwma DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY

  WITH prices AS (
      SELECT *
      FROM tap_price_data_interval(_stock_id, _from - _interval * 2, _to)
  )
  SELECT
    aph.close_date,
    avg.vwma vwma
  FROM prices aph
    INNER JOIN
    LATERAL (
    SELECT sum(lat.close_price*quantity)/sum(quantity) vwma
    FROM (
           SELECT *
           FROM tap_price_data_limit(_stock_id, aph.close_date, _interval)
         ) lat
    ) avg ON TRUE
  WHERE aph.close_date BETWEEN _from AND _to
  ORDER BY aph.close_date;

END;
$$;