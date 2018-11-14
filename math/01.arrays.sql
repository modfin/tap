-- unnest 2d array to 1d arrays
CREATE OR REPLACE FUNCTION tap_unnest_2d_1d(anyarray)
  RETURNS SETOF anyarray AS
$BODY$
SELECT array_agg($1[d1][d2])
FROM   generate_series(array_lower($1,1), array_upper($1,1)) d1
  ,  generate_series(array_lower($1,2), array_upper($1,2)) d2
GROUP  BY d1
ORDER  BY d1
$BODY$
LANGUAGE sql IMMUTABLE;

