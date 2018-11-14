CREATE TYPE tap_price_data AS (
  instrument_id BIGINT,
  close_date    DATE,
  open_price    DOUBLE PRECISION,
  close_price   DOUBLE PRECISION,
  high_price    DOUBLE PRECISION,
  low_price     DOUBLE PRECISION,
  quantity      BIGINT,
  turnover      DOUBLE PRECISION,
  num_of_trades BIGINT,
  mcap          DOUBLE PRECISION
);




-- Implement the following interface
-- It should return all data points in the inclusive interval _from _to (BETWEEN _from AND _to)
-- FUNCTION tap_price_data_interval(_instrument_id BIGINT, _from DATE, _to DATE)
--   RETURNS SETOF tap_price_data



-- Implement the following interface
-- It should return _limit number of data points before and upto _at
-- FUNCTION tap_price_data_limit(_instrument_id BIGINT, _at DATE, _limit INT)
--   RETURNS SETOF tap_price_data
