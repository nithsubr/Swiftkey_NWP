/****** Script for SelectTopNRows command from SSMS  ******/

-- Kenser Ney Smoothing formula to be solved -
-- prob <- (max(A-D2,0)/ B) + ((D2/B) * C)

-- Here we solve the Kensar Ney part 1 = 
-- Var1 = max(A-D2,0)/ B)
-- Var2 = ((D2/B) * C)

use [Analytics_DB1]

truncate table dbo.[2-Grams_prob]

-- Get all the 3 Grams
drop table #tmp_3Grams 
SELECT [""]
      ,value
      ,word_1
      ,word_2
      ,pred
  into #tmp_3Grams
  FROM [Analytics_DB1].[dbo].[3-Grams]
  
-- Get all the 2 Grams
drop table #tmp_2Grams  
SELECT [""]
      ,value
      ,word_1
      ,pred
  into #tmp_2Grams
  FROM [Analytics_DB1].[dbo].[2-Grams]

--select * from #tmp_2Grams where word_1 = '300420'  order by value desc
  
-- Get all the A
drop table #tmp_A
select distinct X.word_1 AS word_1,
       X.pred AS pred,
       Z.A as A
 INTO #tmp_A
 from #tmp_2Grams X
 left join ( select word_2,
        pred,
        COUNT_BIG(1) as A
  from #tmp_3Grams B
  GROUP BY word_2, pred ) Z
 on Z.word_2 = X.word_1
 and Z.pred = X.pred
  
  --select * from #tmp_A where word_1 = '300420' order by A desc
  --select COUNT(*) from #tmp_3Grams where word_2 = '300420' and pred = '662023' 
   
  -- Get all the B
  drop table #tmp_B
  select distinct X.word_1 AS word_1,
         Z.B AS B
  into #tmp_B
  from #tmp_2Grams X 
  left join ( select pred ,
               COUNT_BIG(1) AS B
  from #tmp_2Grams
  GROUP BY pred ) Z
  on X.word_1 = Z.pred
  
--  select * from #tmp_B where word_1 = '300420'

  -- Get all the C
  drop table #tmp_C
  select distinct X.word_1 AS word_1,
         Z.C AS C
  into #tmp_C
  from #tmp_2Grams X 
  left join ( select word_1 ,
               COUNT_BIG(1) AS C
  from #tmp_2Grams
  GROUP BY word_1 ) Z
  on X.word_1 = Z.word_1
  
  --select COUNT(*) from #tmp_2Grams WHERE word_1 = '300420'
  --select * from #tmp_C where word_1 = '300420'
      
  -- Get the discounting factor
  DECLARE @N1 FLOAT
  SET @N1 = (select COUNT(*) from #tmp_2Grams WHERE value = 1)
  DECLARE @N2 FLOAT
  SET @N2 = (select COUNT(*) from #tmp_2Grams WHERE value = 2)
  DECLARE @DISC FLOAT
  DECLARE @DIN FLOAT
  SET @DIN = (@N1 + (2 * @N2))
  SET @DISC = (@N1/@DIN)
 -- print(@disc)
  
--Apply the Formula
drop table #tmp_final_2Grams

select distinct Z.*,
       CASE WHEN (Z.A2 > 0 AND Z.B > 0)
       THEN (Z.A2 / Z.B)
       ELSE 0
       END AS var1,
       CASE WHEN (Z.B > 0)
       THEN ((@DISC / Z.B) * Z.C)
       ELSE 0
       END AS var2  
into #tmp_final_2Grams
from( select X.word_1,
       X.pred,
       Y1.A AS A1,
       Y2.B,
       Y3.C,
       @DISC AS D2,
       (Y1.A - @DISC) AS A2
from #tmp_2Grams X LEFT JOIN #tmp_A Y1 ON Y1.[word_1] = X.word_1 AND Y1.[pred] = X.pred
                   LEFT JOIN #tmp_B Y2 ON Y2.[word_1] = X.word_1
                   LEFT JOIN #tmp_C Y3 ON Y3.[word_1] = X.word_1) Z
                 
insert into [Analytics_DB1].dbo.[2-Grams_prob] (word_1, pred, var1, var2)
select word_1, pred, var1, var2 from #tmp_final_2Grams where word_1 <> 'NA' AND pred <> 'NA'

--select word_1, pred, var1, var2 from #tmp_final_2Grams where word_1 = '31223' order by var1 desc and pred = '430903'
                    
  
  
  
  
  
  