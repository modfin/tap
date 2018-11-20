

-- Rate of Change
CREATE OR REPLACE FUNCTION tap_rocr(_interval INT, _instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS TABLE("close_date" DATE, "rocr" DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN

  RETURN QUERY
  WITH prices AS (
      SELECT *
      FROM tap_price_data_interval(_instrument_id, _from - 2*_interval, _to)
  )
  SELECT
         d.close_date,
         d.rocr
  FROM (
       SELECT
              today.close_date,
              today.close_price / yesterday.close_price AS rocr
       FROM prices today
              INNER JOIN
                LATERAL (
                       SELECT yesterday.close_price, yesterday.close_date
                       FROM prices yesterday
                       WHERE yesterday.close_date <= today.close_date
                       ORDER BY yesterday.close_date DESC
                       OFFSET _interval
                       LIMIT 1
                    ) yesterday ON TRUE
       WHERE today.close_date BETWEEN _from AND _to
       ) d
  ;
END;
$$;