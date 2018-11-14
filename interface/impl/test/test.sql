CREATE OR REPLACE FUNCTION tap_price_data_interval(_instrument_id BIGINT, _from DATE, _to DATE)
  RETURNS SETOF tap_price_data
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY

  SELECT
    *
  FROM _test_data inr
  WHERE close_date BETWEEN _from AND _to
        AND inr.instrument_id = _instrument_id
  ORDER BY close_date;
END;
$$;


CREATE OR REPLACE FUNCTION tap_price_data_limit(_instrument_id BIGINT, _at DATE, _limit INT)
  RETURNS SETOF tap_price_data
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY

  SELECT *
  FROM (
         SELECT
          *
         FROM _test_data inr
         WHERE inr.close_date <= _at
               AND inr.instrument_id = _instrument_id
         ORDER BY inr.close_date DESC
         LIMIT _limit
       ) a
  ORDER BY close_date;
END;
$$;