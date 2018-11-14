

CREATE OR REPLACE FUNCTION tap_linereg(_data DOUBLE PRECISION [] [])
  RETURNS TABLE(m DOUBLE PRECISION, b DOUBLE PRECISION)
LANGUAGE plpgsql
AS $$
DECLARE
BEGIN
  RETURN QUERY

  WITH points AS (
      SELECT d[1] x, d[2] y FROM tap_unnest_2d_1d(_data) d
  )
  SELECT
    (v.a - v.b) / (c - d)                         AS m,
    (sum_y - sum_x * ((v.a - v.b) / (c - d))) / n AS b
  FROM (
         SELECT
           count(*)              n,
           count(*) * sum(x * y) a,
           sum(x) * sum(y)       b,
           count(*) * sum(x * x) c,
           sum(x) * sum(x)       d,
           sum(y)                sum_y,
           sum(x)                sum_x
         FROM points
       ) v
  WHERE  (c - d) <> 0
   AND n <> 0;
END;
$$;
