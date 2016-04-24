use Analytics_DB1

-- Apply Interpolation

-- Start with 1-Grams
truncate table dbo.[1Grams_int_probs]
drop table #tmp_1Grams_int
select Z.*,
      --(prob_pkn * 0.064) AS prob_int
      prob_pkn AS prob_int
into #tmp_1Grams_int
from (select word,
             pred,
             prob as prob_pkn 
from dbo.[1-Grams_prob]) Z

insert into dbo.[1Grams_int_probs] (word, pred, prob_pkn, prob_int)
select word, pred, prob_pkn, prob_int from #tmp_1Grams_int


-- Then 2-Grams
truncate table dbo.[2Grams_int_probs]
drop table #tmp_2Grams_int
select Z.*,
     --(Z.prob_pkn + (0.064 * Z.prev_prob)) AS prob_int4     
      prob_pkn AS prob_int
into #tmp_2Grams_int
from (select distinct B.*,
            (B.var1 + (B.var2 * A.prob_pkn)) as prob_pkn 
            -- A.prob_int AS prev_prob 
from dbo.[2-Grams_prob] B INNER JOIN #tmp_1Grams_int A
ON A.pred = B.[pred]) Z


insert into dbo.[2Grams_int_probs] (word_1, pred, prob_pkn, prob_int)
select word_1, pred, prob_pkn, prob_int from #tmp_2Grams_int


-- Now 3-Grams
truncate table dbo.[3Grams_int_probs]
drop table #tmp_3Grams_int
select Z.*,
     --(Z.prob_pkn + (0.16 * Z.prev_prob)) AS prob_int
     prob_pkn AS prob_int
into #tmp_3Grams_int
from (select B.*,
            (B.var1 + (B.var2 * A.prob_pkn)) as prob_pkn
            -- A.prob_int AS prev_prob
from dbo.[3-Grams_prob] B INNER JOIN #tmp_2Grams_int A
ON A.[word_1] = B.[word_2] AND
   A.[pred] = B.[pred]) Z
   
--delete #tmp_3Grams_int WHERE prob_int <= 0 
-- select * from #tmp_3Grams_int where word_1 = '300420' and word_2 = '31223' order by prob_int desc

insert into dbo.[3Grams_int_probs] (word_1, word_2, pred, prob_pkn, prob_int)
select word_1, word_2, pred, prob_pkn, prob_int from #tmp_3Grams_int
 
 select * from #tmp_2Grams_int where word_1 = '757479' and pred = '1' 
 select * from [Analytics_DB1].dbo.[3-Grams_prob] where word_1 = '31223' and word_2 = '757479' and pred = '1' 
 select * from [Analytics_DB1].dbo.[3Grams_int_probs] where word_1 = '31223' and word_2 = '757479' and pred = '1'
 
 select * from #tmp_2Grams_int where word_1 = '757479' and pred = '31223' 
 select * from [Analytics_DB1].dbo.[3-Grams_prob] where word_1 = '31223' and word_2 = '757479' and pred = '31223' 
 select * from [Analytics_DB1].dbo.[3Grams_int_probs] where word_1 = '31223' and word_2 = '757479' and pred = '31223'

-- Now 4-Grams
truncate table dbo.[4Grams_int_probs]
drop table #tmp_4Grams_int
select Z.*,
     --(Z.prob_pkn + (0.4 * Z.prev_prob)) AS prob_int
     prob_pkn AS prob_int
into #tmp_4Grams_int
from (select B.*,
            (B.var1 + (B.var2 * A.prob_pkn)) as prob_pkn
            -- A.prob_int AS prev_prob
from dbo.[4-Grams_prob] B INNER JOIN #tmp_3Grams_int A
ON A.[word_1] = B.[word_2] AND
   A.[word_2] = B.[word_3] AND
   A.[pred] = B.[pred]) Z  
   
insert into dbo.[4Grams_int_probs] (word_1, word_2, word_3, pred, prob_pkn, prob_int)
select word_1, word_2, word_3, pred, prob_pkn, prob_int from #tmp_4Grams_int  


select * from #tmp_1Grams_int where pred = '757479'
select * from #tmp_2Grams_int where word_1 = '757479' order by prob_int desc 
select * from #tmp_3Grams_int where word_1 = '31223' and word_2 = '757479' order by prob_int desc 
select * from #tmp_4Grams_int where word_1 = '300420' and word_2 = '31223' and word_3 = '757479' order by prob_int desc 