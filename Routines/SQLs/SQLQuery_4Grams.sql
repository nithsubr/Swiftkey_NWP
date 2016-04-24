/****** Script for SelectTopNRows command from SSMS  ******/

-- Kenser Ney Smoothing formula to be solved -
-- prob <- (max(A-D2,0)/ B) + ((D2/B) * C)

-- Here we solve the Kensar Ney part 1 = 
-- Var1 = max(A-D2,0)/ B)
-- Var2 = ((D2/B) * C)

truncate table [Analytics_DB1].dbo.[4-Grams_prob]

-- Get all the 5 Grams
drop table #tmp_5Grams
SELECT [""]
      ,value
      ,word_1
      ,word_2
      ,word_3
      ,word_4
      ,pred
  into #tmp_5Grams
  FROM [Analytics_DB1].[dbo].[5-Grams]
  
-- Get all the 4 Grams
drop table #tmp_4Grams
SELECT [""]
      ,value
      ,word_1
      ,word_2
      ,word_3
      ,pred
  into #tmp_4Grams
  FROM [Analytics_DB1].[dbo].[4-Grams]
  
  --select * from #tmp_4Grams where word_1 = '300420' and word_2 = '31223' and word_3 = '757479'
  
-- Get all the A
drop table #tmp_A
select distinct X.word_1 AS word_1,
       X.word_2 as word_2,
       X.word_3 as word_3,
       X.pred AS pred,
       Z.A as A
 INTO #tmp_A
 from #tmp_4Grams X
 left join ( select word_2,
        word_3,
        word_4,
        pred,
        COUNT_BIG(1) as A
  from #tmp_5Grams B
  GROUP BY word_2, word_3, word_4, pred ) Z
 on Z.word_2 = X.word_1
 and Z.word_3 = X.word_2
 and Z.word_4 = X.word_3
 and Z.pred = X.pred
   
   --select * from #tmp_A where word_1 = '300420' and word_2 = '31223' and word_3 = '757479' order by A desc
   
  -- Get all the B
  drop table #tmp_B
  select distinct X.word_1 AS word_1,
         X.word_2 AS word_2,
         X.word_3 AS word_3,
         Z.B AS B
  into #tmp_B
  from #tmp_4Grams X 
  left join ( select word_2,
                     word_3,
                     pred ,
               COUNT_BIG(1) AS B
  from #tmp_4Grams
  GROUP BY word_2, word_3, pred ) Z
  on X.word_1 = Z.word_2
  and X.word_2 = Z.word_3
  and X.word_3 = Z.pred

--select * from #tmp_B where word_1 = '300420' and word_2 = '31223' and word_3 = '757479' order by B desc

-- Get all the C  
 drop table #tmp_C
  select distinct X.word_1 AS word_1,
         X.word_2 AS word_2,
         X.word_3 AS word_3,
         Z.C AS C
  into #tmp_C
  from #tmp_4Grams X 
  left join ( select word_1,
                     word_2,
                     word_3,
               COUNT_BIG(1) AS C
  from #tmp_4Grams
  GROUP BY word_1, word_2, word_3 ) Z
  on X.word_1 = Z.word_1
  and X.word_2 = Z.word_2
  and X.word_3 = Z.word_3
  
 -- select * from #tmp_C where word_1 = '300420' and word_2 = '31223' and word_3 = '757479' order by C desc
  
-- Get the discounting factor
 DECLARE @N1 FLOAT
 SET @N1 = (select COUNT(*) from #tmp_4Grams WHERE value = 1)
 DECLARE @N2 FLOAT
 SET @N2 = (select COUNT(*) from #tmp_4Grams WHERE value = 2)
 DECLARE @DISC FLOAT
 DECLARE @DIN FLOAT
 SET @DIN = (@N1 + (2 * @N2))
 SET @DISC = (@N1/@DIN)
  
--Apply the Formula
-- Var1 = max(A-D2,0)/ B)
-- Var2 = ((D2/B) * C)
drop table #tmp_final_4Grams
select distinct Z.*,
       CASE WHEN (Z.A2 > 0 AND Z.B > 0)
       THEN (Z.A2 / Z.B)
       ELSE 0
       END AS var1,
       CASE WHEN (Z.B > 0)
       THEN ((@DISC / Z.B) * Z.C)
       ELSE 0
       END AS var2 
into #tmp_final_4Grams
from( select X.*,
       Y1.A AS A1,
       Y2.B,
       Y3.C,
       @DISC AS D2,
       (Y1.A - @DISC) AS A2
from #tmp_4Grams X LEFT JOIN #tmp_A Y1 ON Y1.[word_1] = X.word_1 AND Y1.[word_2] = X.word_2 AND Y1.[word_3] = X.word_3 AND Y1.[pred] = X.pred
                   LEFT JOIN #tmp_B Y2 ON Y2.[word_1] = X.word_1 AND Y2.[word_2] = X.word_2 AND Y2.[word_3] = X.word_3
                   LEFT JOIN #tmp_C Y3 ON Y3.[word_1] = X.word_1 AND Y3.[word_2] = X.word_2 AND Y3.[word_3] = X.word_3) Z
                 
insert into [Analytics_DB1].dbo.[4-Grams_prob] (word_1, word_2, word_3, pred, var1, var2)
select word_1, word_2, word_3, pred, var1, var2 from #tmp_final_4Grams WHERE word_1 <> 'NA' AND word_2 <> 'NA' AND word_3 <> 'NA' AND pred <> 'NA'

 
--  select * from #tmp_final_4Grams where word_1 = '300420' and word_2 = '31223' and word_3 = '757479' order by var1 desc