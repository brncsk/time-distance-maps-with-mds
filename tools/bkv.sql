BEGIN TRANSACTION;

DROP TYPE IF EXISTS _bkv_relation CASCADE;

CREATE TYPE _bkv_relation AS (
  "geom" geometry,
  "headsign" TEXT
);

DROP FUNCTION IF EXISTS bkv_relations(DATE, BOOLEAN, FLOAT);
CREATE OR REPLACE FUNCTION bkv_relations(dt DATE, simplify BOOLEAN, tolerance FLOAT DEFAULT 0.1)
  RETURNS SETOF _bkv_relation
  AS $$
    BEGIN
      IF "simplify" THEN
        RETURN QUERY SELECT
          ST_Simplify("wkb_geometry", "tolerance"),
          "jaratszam"::text
         FROM
           "bkv_kotott"
         WHERE
           "dt" BETWEEN validfrom and validuntil
          AND
           "route_type" = 0
          AND
           "irany" = 'T'
          AND
           "nappal" = 'T'
        ;
      ELSE
        RETURN QUERY SELECT
          "wkb_geometry",
          "jaratszam"::text
         FROM
           "bkv_kotott"
         WHERE
           "dt" BETWEEN validfrom AND validuntil
          AND
            "route_type" = 0
          AND
           "irany" = 'T'
          AND
           "nappal" = 'T'
        ;
      END IF;
    END;
$$ LANGUAGE plpgsql;

COMMIT;