

-- True Range
CREATE OR REPLACE FUNCTION tap_tr(_instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, "tr" DOUBLE PRECISION, "tr_percent" DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
--   a) dagshögsta - dagslägsta
--   b) aboslutvärdet av (dagshögsta - gårdagens stängningspris)
--   c) absolutvärdet av (dagslägsta - gårdagens stängningspris)
-- max(a, b, c) = true range

  RETURN QUERY
  WITH prices AS (
      SELECT *
      FROM tap_price_data_interval(_instrument_id, _from - 7, _to)
  )
  SELECT
    d.close_date,
    GREATEST(a,b, c ) as tr,
    GREATEST(a,b, c ) / d.close_price as tr_percent
  FROM (
    SELECT
      today.close_date,
      today.close_price,
      today.high_price-today.low_price as a,
      abs(today.high_price - yesterday.close_price) b,
      abs(today.low_price - yesterday.close_price) c
    FROM prices today
      INNER JOIN
      LATERAL (
        SELECT yesterday.close_price FROM prices yesterday
        WHERE yesterday.close_date < today.close_date
        ORDER BY yesterday.close_date DESC
        LIMIT 1
      ) yesterday ON TRUE
    WHERE today.close_date BETWEEN _from AND _to
  ) d
  ;
END;
$$;