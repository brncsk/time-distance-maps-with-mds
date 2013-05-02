BEGIN TRANSACTION;

DROP TYPE IF EXISTS _mt_point CASCADE;

CREATE TYPE _mt_point AS (
  "lat" DOUBLE PRECISION,
  "lon" DOUBLE PRECISION,
  "name" TEXT
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
                  ST_Y("nodes"."geom"),
                  ''::text
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
    BEGIN
      EXECUTE 'SELECT
        ARRAY(SELECT DISTINCT "id" FROM "ways"
      WHERE
        ' || _parse_hstore_filter(tagexpr, 'tags') || ');'
      INTO wids;

      RETURN QUERY SELECT * FROM _mt_ways(wids);
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION mt_nodes_by_tag(tagexpr TEXT)
  RETURNS SETOF _mt_point
  AS $$
    BEGIN
      RETURN QUERY EXECUTE 'SELECT
        ST_X("nodes"."geom"),
        ST_Y("nodes"."geom"),
        "tags" -> ''name'' AS "name"
      FROM
        "nodes"
      WHERE
      ' || _parse_hstore_filter(tagexpr, 'tags') || '
      ;';
    END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS _parse_hstore_filter(TEXT, TEXT);
CREATE OR REPLACE FUNCTION _parse_hstore_filter(filterexpr TEXT, hstorecolname TEXT)
  RETURNS TEXT AS $$
    DECLARE
      tags TEXT[];
      tag_key TEXT;
      tag_values TEXT[];
      filters TEXT[];
      current_filter TEXT[];
      i INTEGER;
      j INTEGER;
      
    BEGIN
      filters := '{}';
      tags := regexp_split_to_array(filterexpr, E'\\s+');

      FOR i IN 1..array_upper(tags, 1)
        LOOP
          tag_key := split_part(tags[i], '=', 1);
          tag_values := regexp_split_to_array(split_part(tags[i], '=', 2), E',');
          current_filter := '{}';

          IF (tag_values[array_upper(tag_values, 1)] = '') THEN
            filters := array_append(filters, '("' || hstorecolname || '" ? ''' || tag_key || ''')');
          ELSE
            FOR j IN 1..array_upper(tag_values, 1)
              LOOP
                current_filter := array_append(
                  current_filter,
                  '("' || hstorecolname || '" @> ''' || tag_key || '=>' || tag_values[j] || ''')'
                );
              END LOOP;
              
              filters := array_append(filters, '(' || array_to_string(current_filter, ' OR ') || ')');
          END IF;
        END LOOP;

      RETURN array_to_string(filters, ' AND ');
  END;
$$ LANGUAGE plpgsql;

COMMIT;