--for basis_catch_spp_lh_0
WITH speccatch
     AS (  SELECT Event.StationID,
                  Event.EventCode,
                  Event.SampleYear,
                  Event.GearCode,
                  Event.TrawlPERformance,
                  Event.EQ_LATITUDE,
                  Event.EQ_LONGITUDE,
                  EVENTEFFORT.HaversineDistance2,
                  EVENTEFFORT.AvgNetHorizontalOpening,
                  EVENTEFFORT.Effort_area_km2,
                  species.tsn,
                  species.commonname,
                  UPPER (catch.lhscode) AS lhscode,
                  SUM (catch.totalcatchnum) AS totalcatchnum,
                  SUM (catch.totalcatchwt) AS totalcatchwt
             FROM ema.BASISFISH_Event EVENT
                  INNER JOIN ema.BASISFISH_EVENTEFFORT EVENTEFFORT
                     ON     (Event.EventCode = EVENTEFFORT.EventCode)
                        AND (Event.StationID = EVENTEFFORT.StationID)
                  INNER JOIN EMA.BASISFISH_CATCH CATCH
                     ON     (Event.EventCode = Catch.EventCode)
                        AND (Event.StationID = Catch.StationID)
                  INNER JOIN EMA.BASISFISH_SPECIES SPECIES
                     ON Species.TSN = Catch.SpeciesTSN
            WHERE (    ( (Event.SampleYear) >= 2002)
                   AND (   NOT (Event.TrawlPERformance) = 'A'
                        OR (Event.TrawlPERformance) = 'U')--AND ( (Event.EQ_LATITUDE) BETWEEN 60 AND 66.5));
                                                          /*replace with bind variable*/
                                                          /*AND ( (Event.EQ_LATITUDE) BETWEEN :minlat AND :maxlat)*/
                  )
         GROUP BY Event.StationID,
                  Event.EventCode,
                  Event.SampleYear,
                  Event.GearCode,
                  Event.TrawlPERformance,
                  Event.EQ_LATITUDE,
                  Event.EQ_LONGITUDE,
                  EVENTEFFORT.HaversineDistance2,
                  EVENTEFFORT.AvgNetHorizontalOpening,
                  EVENTEFFORT.Effort_area_km2,
                  species.commonname,
                  species.tsn,
                  catch.lhscode),
     cjoin
     AS (SELECT e.*, s.*
           FROM    (SELECT DISTINCT
                           stationid,
                           eventcode,
                           sampleyear,
                           gearcode,
                           trawlperformance AS trawlperformance_code,
                           eq_latitude,
                           eq_longitude,
                           haversinedistance2,
                           avgnethorizontalopening,
                           effort_area_km2
                      FROM speccatch) e
                CROSS JOIN
                   (SELECT DISTINCT
                           tsn,
                           commonname AS speciesname,
                           UPPER (lhscode) AS lhscode
                      FROM speccatch) s)
SELECT cj.*,
       tg.description AS gear_description,
       tp.trawlperformance,
       lhs.description AS lifehistory_stage,
       NVL (sc.totalcatchnum, 0) AS totalcatchnum,
       NVL (sc.totalcatchwt, 0) AS totalcatchwt
  FROM cjoin cj
       LEFT JOIN speccatch sc
          ON     cj.stationid = sc.stationid
             AND cj.eventcode = sc.eventcode
             AND cj.tsn = sc.tsn
             AND cj.lhscode = sc.lhscode
       LEFT JOIN ema.basisfish_lifehistorystage lhs
          ON cj.lhscode = lhs.code
       LEFT JOIN ema.basisfish_trawlperformance tp
          ON cj.trawlperformance_code = tp.trawlperformancecode
       LEFT JOIN ema.basisfish_trawlgear tg
          ON cj.gearcode = tg.code;
          
          --rewrite with "into" based on error...
          --Nevermind. This morning it magically works! 
          --Now add optional filters on year, tsn, minlat, maxlat
          WITH speccatch
     AS (  SELECT Event.StationID,
                  Event.EventCode,
                  Event.SampleYear,
                  Event.GearCode,
                  Event.TrawlPERformance,
                  Event.EQ_LATITUDE,
                  Event.EQ_LONGITUDE,
                  EVENTEFFORT.HaversineDistance2,
                  EVENTEFFORT.AvgNetHorizontalOpening,
                  EVENTEFFORT.Effort_area_km2,
                  species.tsn,
                  species.commonname,
                  UPPER (catch.lhscode) AS lhscode,
                  SUM (catch.totalcatchnum) AS totalcatchnum,
                  SUM (catch.totalcatchwt) AS totalcatchwt
             FROM ema.BASISFISH_Event EVENT
                  INNER JOIN ema.BASISFISH_EVENTEFFORT EVENTEFFORT
                     ON     (Event.EventCode = EVENTEFFORT.EventCode)
                        AND (Event.StationID = EVENTEFFORT.StationID)
                  INNER JOIN EMA.BASISFISH_CATCH CATCH
                     ON     (Event.EventCode = Catch.EventCode)
                        AND (Event.StationID = Catch.StationID)
                  INNER JOIN EMA.BASISFISH_SPECIES SPECIES
                     ON Species.TSN = Catch.SpeciesTSN
            WHERE (    ( (Event.SampleYear) >= 2002)
                   AND (   NOT (Event.TrawlPERformance) = 'A'
                        OR (Event.TrawlPERformance) = 'U')--AND ( (Event.EQ_LATITUDE) BETWEEN 60 AND 66.5));
                                                          /*replace with bind variable*/
                                                          /*AND ( (Event.EQ_LATITUDE) BETWEEN :minlat AND :maxlat)*/
                  )
         GROUP BY Event.StationID,
                  Event.EventCode,
                  Event.SampleYear,
                  Event.GearCode,
                  Event.TrawlPERformance,
                  Event.EQ_LATITUDE,
                  Event.EQ_LONGITUDE,
                  EVENTEFFORT.HaversineDistance2,
                  EVENTEFFORT.AvgNetHorizontalOpening,
                  EVENTEFFORT.Effort_area_km2,
                  species.commonname,
                  species.tsn,
                  catch.lhscode),
     cjoin
     AS (SELECT e.*, s.*
           FROM    (SELECT DISTINCT
                           stationid,
                           eventcode,
                           sampleyear,
                           gearcode,
                           trawlperformance AS trawlperformance_code,
                           eq_latitude,
                           eq_longitude,
                           haversinedistance2,
                           avgnethorizontalopening,
                           effort_area_km2
                      FROM speccatch) e
                CROSS JOIN
                   (SELECT DISTINCT
                           tsn,
                           commonname AS speciesname,
                           UPPER (lhscode) AS lhscode
                      FROM speccatch) s)
SELECT cj.*,
       tg.description AS gear_description,
       tp.trawlperformance,
       lhs.description AS lifehistory_stage,
       NVL (sc.totalcatchnum, 0) AS totalcatchnum,
       NVL (sc.totalcatchwt, 0) AS totalcatchwt
  FROM cjoin cj
       LEFT JOIN speccatch sc
          ON     cj.stationid = sc.stationid
             AND cj.eventcode = sc.eventcode
             AND cj.tsn = sc.tsn
             AND cj.lhscode = sc.lhscode
       LEFT JOIN ema.basisfish_lifehistorystage lhs
          ON cj.lhscode = lhs.code
       LEFT JOIN ema.basisfish_trawlperformance tp
          ON cj.trawlperformance_code = tp.trawlperformancecode
       LEFT JOIN ema.basisfish_trawlgear tg
          ON cj.gearcode = tg.code
          where cj.sampleyear=2010 and
          cj.tsn=160939 and
          cj.eq_latitude>65;
          
          --test parameterization
          WITH speccatch
     AS (  SELECT Event.StationID,
                  Event.EventCode,
                  Event.SampleYear,
                  Event.GearCode,
                  Event.TrawlPERformance,
                  Event.EQ_LATITUDE,
                  Event.EQ_LONGITUDE,
                  EVENTEFFORT.HaversineDistance2,
                  EVENTEFFORT.AvgNetHorizontalOpening,
                  EVENTEFFORT.Effort_area_km2,
                  species.tsn,
                  species.commonname,
                  UPPER (catch.lhscode) AS lhscode,
                  SUM (catch.totalcatchnum) AS totalcatchnum,
                  SUM (catch.totalcatchwt) AS totalcatchwt
             FROM ema.BASISFISH_Event EVENT
                  INNER JOIN ema.BASISFISH_EVENTEFFORT EVENTEFFORT
                     ON     (Event.EventCode = EVENTEFFORT.EventCode)
                        AND (Event.StationID = EVENTEFFORT.StationID)
                  INNER JOIN EMA.BASISFISH_CATCH CATCH
                     ON     (Event.EventCode = Catch.EventCode)
                        AND (Event.StationID = Catch.StationID)
                  INNER JOIN EMA.BASISFISH_SPECIES SPECIES
                     ON Species.TSN = Catch.SpeciesTSN
            WHERE (    ( (Event.SampleYear) >= 2002)
                   AND (   NOT (Event.TrawlPERformance) = 'A'
                        OR (Event.TrawlPERformance) = 'U')--AND ( (Event.EQ_LATITUDE) BETWEEN 60 AND 66.5));
                                                          /*replace with bind variable*/
                                                          /*AND ( (Event.EQ_LATITUDE) BETWEEN :minlat AND :maxlat)*/
                  )
         GROUP BY Event.StationID,
                  Event.EventCode,
                  Event.SampleYear,
                  Event.GearCode,
                  Event.TrawlPERformance,
                  Event.EQ_LATITUDE,
                  Event.EQ_LONGITUDE,
                  EVENTEFFORT.HaversineDistance2,
                  EVENTEFFORT.AvgNetHorizontalOpening,
                  EVENTEFFORT.Effort_area_km2,
                  species.commonname,
                  species.tsn,
                  catch.lhscode),
     cjoin
     AS (SELECT e.*, s.*
           FROM    (SELECT DISTINCT
                           stationid,
                           eventcode,
                           sampleyear,
                           gearcode,
                           trawlperformance AS trawlperformance_code,
                           eq_latitude,
                           eq_longitude,
                           haversinedistance2,
                           avgnethorizontalopening,
                           effort_area_km2
                      FROM speccatch) e
                CROSS JOIN
                   (SELECT DISTINCT
                           tsn,
                           commonname AS speciesname,
                           UPPER (lhscode) AS lhscode
                      FROM speccatch) s)
SELECT cj.*,
       tg.description AS gear_description,
       tp.trawlperformance,
       lhs.description AS lifehistory_stage,
       NVL (sc.totalcatchnum, 0) AS totalcatchnum,
       NVL (sc.totalcatchwt, 0) AS totalcatchwt
  FROM cjoin cj
       LEFT JOIN speccatch sc
          ON     cj.stationid = sc.stationid
             AND cj.eventcode = sc.eventcode
             AND cj.tsn = sc.tsn
             AND cj.lhscode = sc.lhscode
       LEFT JOIN ema.basisfish_lifehistorystage lhs
          ON cj.lhscode = lhs.code
       LEFT JOIN ema.basisfish_trawlperformance tp
          ON cj.trawlperformance_code = tp.trawlperformancecode
       LEFT JOIN ema.basisfish_trawlgear tg
          ON cj.gearcode = tg.code
               where cj.sampleyear between nvl(:startyear, 2000)and nvl(:endyear, 3000) and
          cj.tsn in (select * from table(apex_string.split(nvl(:tsncode,tsn),','))) and
          cj.eq_latitude between nvl(:minlat, 0)and nvl(:maxlat, 90)
          ;


--Parameters for summary table
select* from EMA.BASISFISH_SPECIES;
          
          select* from ema.basisocean_tsn;
          select distinct(sampleyear) from ema.basisfish_event
          order by sampleyear;
          
            select max(eq_latitude) from ema.basisfish_event;
            select min(eq_latitude) from ema.basisfish_event;

          
            select * from ema.basisfish_species;
            
            select effort_area_km2, round(avgnethorizontalopening*haversinedistance2/1000,4commo) as calc
            from EMA.basisfish_eventeffort;