-- AVISO: executada com uma função não superusuária, a consulta inspeciona apenas o índice nas tabelas que você pode ler.
SELECT current_database(), nspname AS schemaname, c.relname AS tablename, indexname, bs*(sub.relpages)::bigint AS real_size,
  bs*otta::bigint as estimated_size,
  bs*(sub.relpages-otta)::bigint                                     AS bloat_size,
  bs*(sub.relpages-otta)::bigint * 100 / (bs*(sub.relpages)::bigint) AS bloat_ratio
  -- , index_tuple_hdr_bm, maxalign, pagehdr, nulldatawidth, nulldatahdrwidth, datawidth, sub.reltuples, sub.relpages -- (DEBUG INFO)
FROM (
  SELECT bs, nspname, table_oid, indexname, relpages, coalesce(
      ceil((reltuples*(4+nulldatahdrwidth))/(bs-pagehdr::float)) + 1, 0 -- ItemIdData size + computed avg size of a tuple (nulldatahdrwidth)
    ) AS otta
    -- , index_tuple_hdr_bm, maxalign, pagehdr, nulldatawidth, nulldatahdrwidth, datawidth, reltuples -- (DEBUG INFO)
  FROM (
    SELECT maxalign, bs, nspname, relname AS indexname, reltuples, relpages, relam, table_oid,
      ( index_tuple_hdr_bm +
          maxalign - CASE -- Add padding to the index tuple header to align on MAXALIGN
            WHEN index_tuple_hdr_bm%maxalign = 0 THEN maxalign
            ELSE index_tuple_hdr_bm%maxalign
          END
        + nulldatawidth + maxalign - CASE -- Add padding to the data to align on MAXALIGN
            WHEN nulldatawidth = 0 THEN 0
            WHEN nulldatawidth::integer%maxalign = 0 THEN maxalign
            ELSE nulldatawidth::integer%maxalign
          END
      )::numeric AS nulldatahdrwidth, pagehdr
      -- , index_tuple_hdr_bm, nulldatawidth, datawidth -- (DEBUG INFO)
    FROM (
      SELECT
        i.nspname, i.relname, i.reltuples, i.relpages, i.relam, a.attrelid AS table_oid,
        CASE cluster_version.v > 7
            WHEN true THEN current_setting('block_size')::numeric
            ELSE 8192::numeric
        END AS bs,
        CASE  -- MAXALIGN: 4 on 32bits, 8 on 64bits (and mingw32 ?)
          WHEN version() ~ 'mingw32' OR version() ~ '64-bit|x86_64|ppc64|ia64|amd64' THEN 8
          ELSE 4
        END AS maxalign,
        /* per page header, fixed size: 20 for 7.X, 24 for others */
        CASE WHEN cluster_version.v > 7
          THEN 24
          ELSE 20
        END AS pagehdr,
        /* per tuple header: add IndexAttributeBitMapData if some cols are null-able */
        CASE WHEN max(coalesce(s.null_frac,0)) = 0
          THEN 2 -- IndexTupleData size
          ELSE  2 + (( 32 + 8 - 1 ) / 8) -- IndexTupleData size + IndexAttributeBitMapData size ( max num filed per index + 8 - 1 /8)
        END AS index_tuple_hdr_bm,
        /* data len: we remove null values save space using it fractionnal part from stats */
        sum( (1-coalesce(s.null_frac, 0)) * coalesce(s.avg_width, 1024) ) AS nulldatawidth
        -- , sum( s.stawidth ) AS datawidth -- (DEBUG INFO)
      FROM pg_attribute AS a
        JOIN pg_stats AS s ON (quote_ident(s.schemaname) || '.' || quote_ident(s.tablename))::regclass=a.attrelid AND s.attname = a.attname
        JOIN (
          SELECT nspname, relname, reltuples, relpages, indrelid, relam,
            string_to_array(pg_catalog.textin(pg_catalog.int2vectorout(indkey)), ' ')::smallint[] AS attnum
          FROM pg_index
            JOIN pg_class ON pg_class.oid=pg_index.indexrelid
            JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
        ) AS i ON i.indrelid = a.attrelid AND a.attnum = ANY (i.attnum),
        ( SELECT substring(current_setting('server_version') FROM '#"[0-9]+#"%' FOR '#')::integer ) AS cluster_version(v)
      WHERE a.attnum > 0
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, cluster_version.v
    ) AS s1
  ) AS s2
    JOIN pg_am am ON s2.relam = am.oid WHERE am.amname = 'btree'
) as sub
JOIN pg_class c ON c.oid=sub.table_oid
WHERE sub.relpages > 2
ORDER BY 2,3,4;