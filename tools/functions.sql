BEGIN TRANSACTION;

DROP TYPE IF EXISTS _mt_point CASCADE;

CREATE TYPE _mt_point AS (
  "lat" DOUBLE PRECISION,
  "lon" DOUBLE PRECISION
);

CREATE OR REPLACE FUNCTION _mt_ways(way_ids BIGINT[])
  RETURNS SETOF _mt_point
  AS $$
    DECLARE
      "wid" BIGINT;
      "empty" _mt_point%rowtype;
    BEGIN
        FOR "wid" IN SELECT * FROM UNNEST("way_ids")
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
                  "way_nodes"."way_id" = "wid"
                ORDER BY
                  "way_nodes"."sequence_id" ASC
                ;

                RETURN NEXT "empty";
            END LOOP;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION mt_all_ways()
  RETURNS SETOF _mt_point
  AS $$
    DECLARE
      wids BIGINT[];
    BEGIN
        SELECT ARRAY(SELECT DISTINCT "id" FROM "ways") INTO "wids";
        RETURN QUERY SELECT * FROM _mt_ways(
          wids
        );
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION mt_ways_by_tag(tagexpr TEXT)
  RETURNS SETOF _mt_point
  AS $$
    DECLARE
      wids BIGINT[];
      tag_key TEXT;
      tag_values TEXT[];
    BEGIN
      tag_key := split_part("tagexpr", '=', 1);
      tag_values := regexp_split_to_array(
        split_part("tagexpr", '=', 2),
        E',\\s?'
      );
      
      SELECT ARRAY(
          SELECT DISTINCT
            "id"
          FROM
            "ways"
          RIGHT JOIN
            "way_tags"
              ON
                "way_tags"."way_id" = "ways"."id"
          WHERE
            "way_tags"."k" = "tag_key" AND
            "way_tags"."v" = ANY("tag_values")
      ) INTO "wids";

      RETURN QUERY SELECT * FROM _mt_ways(
        wids
      );      
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION mt_nodes_by_tag(tagexpr TEXT)
  RETURNS SETOF _mt_point
  AS $$
    DECLARE
      tag_key TEXT;
      tag_values TEXT[];
    BEGIN
      tag_key := split_part("tagexpr", '=', 1);
      tag_values := regexp_split_to_array(
        split_part("tagexpr", '=', 2),
        E',\\s?'
      );

      RETURN QUERY SELECT
        ST_X("nodes"."geom"),
        ST_Y("nodes"."geom")
      FROM
        "nodes"
      JOIN
        "node_tags"
          ON
            "node_tags"."node_id" = "nodes"."id"
      WHERE
        "node_tags"."k" = "tag_key" AND
        "node_tags"."v" = ANY("tag_values")
      ;
    END;
$$ LANGUAGE plpgsql;

COMMIT;