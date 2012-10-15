DROP TYPE IF EXISTS geopoint_matlab;

CREATE TYPE geopoint_matlab AS (
  "lat" DOUBLE PRECISION,
  "lon" DOUBLE PRECISION
);

CREATE OR REPLACE FUNCTION get_all_ways_matlab()
  RETURNS SETOF geopoint_matlab
  AS $$
    DECLARE
      "wr" RECORD;
      "empty" geopoint_matlab%rowtype;
    BEGIN
        FOR "wr" IN SELECT "ways"."id" AS "way_id" FROM "ways"
          LOOP
              RETURN QUERY SELECT
                ST_X("nodes"."geom"),
                ST_Y("nodes"."geom")
              FROM
                "way_nodes"
              JOIN
                "nodes"
                  ON
                    "nodes"."id" = "way_nodes"."node_id"
              WHERE
                "way_nodes"."way_id" = "wr"."way_id"
              ORDER BY
                "way_nodes"."sequence_id" ASC
              ;

              RETURN NEXT "empty";
          END LOOP;
    END;
$$ LANGUAGE plpgsql;