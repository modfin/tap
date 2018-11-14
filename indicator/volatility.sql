

CREATE OR REPLACE FUNCTION tap_volatility(_interval INT, _instrument_id BIGINT, _at DATE)
  RETURNS DOUBLE PRECISION
LANGUAGE plpgsql
AS $$
DECLARE
  _vol DOUBLE PRECISION;
BEGIN

  WITH prices AS (
      SELECT *
      FROM tap_price_data_limit(_instrument_id, _at, _interval+1)
  ),
  ret AS (
    SELECT
      today.close_date,
      today.close_price/yesterday.close_price - 1 as ret
    FROM prices today
      INNER JOIN
      LATERAL (
             SELECT * FROM prices inr
             WHERE inr.close_date < today.close_date
             ORDER BY inr.close_date DESC
             LIMIT 1
      ) yesterday ON TRUE
    ORDER BY today.close_date DESC
    LIMIT _interval
  )
  SELECT sqrt(252)*stddev_pop(ret.ret) INTO _vol FROM ret
  ;

  RETURN _vol;
END;
$$;
