use Analytics_DB1

-- Apply Interpolation

-- Start with 1-Grams
truncate table dbo.[1Grams_int_probs_gt]
drop table #tmp_1Grams_int
select Z.word AS word,
       Z.value AS value,
       Z.pred AS pred,
      (Z.prob_int * 0.064) AS prob_int
into #tmp_1Grams_int
from dbo.GTsmooth_1 Z

--delete #tmp_1Grams_int WHERE prob_int <= 0 

insert into dbo.[1Grams_int_probs_gt] (word, value, pred, prob_int)
select word, value, pred, prob_int from #tmp_1Grams_int

select * from dbo.GTsmooth_3 order by word_1, word_2, pred

-- Then 2-Grams
truncate table dbo.[2Grams_int_probs_gt]
drop table #tmp_2Grams_int
select Z.word_1 AS word_1,
       Z.pred AS pred,
      ((Z.prob_int * 0.16) + Z.prev_prob) AS prob_int
into #tmp_2Grams_int
from (select DISTINCT B.word_1,
             B.pred,
             B.prob_int,
             A.prob_int AS prev_prob 
from dbo.GTsmooth_2 B INNER JOIN #tmp_1Grams_int A
ON A.pred = B.pred ) Z

--delete #tmp_2Grams_int WHERE prob_int <= 0 

insert into dbo.[2Grams_int_probs_gt] (word_1, pred, prob_int)
select word_1, pred, prob_int from #tmp_2Grams_int


-- Now 3-Grams
truncate table dbo.[3Grams_int_probs_gt]
drop table #tmp_3Grams_int
select Z.word_1 AS word_1,
       Z.word_2 AS word_2,
       Z.pred AS pred,
     ((Z.prob_int * 0.04) + Z.prev_prob) AS prob_int
into #tmp_3Grams_int
from ( select B.word_1,
              B.word_2,
              B.pred,
              B.prob_int,
              A.prob_int AS prev_prob
from dbo.GTsmooth_3 B INNER JOIN #tmp_2Grams_int A
ON A.word_1 = B.word_2 AND
   A.pred = B.pred ) Z
   
--delete #tmp_3Grams_int WHERE prob_int <= 0 

insert into dbo.[3Grams_int_probs_gt] (word_1, word_2, pred, prob_int)
select word_1, word_2, pred, prob_int from #tmp_3Grams_int


-- Now 4-Grams
truncate table dbo.[4Grams_int_probs_gt]
drop table #tmp_4Grams_int
select Z.word_1 AS word_1,
       Z.word_2 AS word_2,
       Z.word_3 AS word_3,
       Z.pred AS pred,
     ((Z.prob_int * 1) + Z.prev_prob) AS prob_int
into #tmp_4Grams_int
from ( select B.word_1,
              B.word_2,
              B.word_3,
              B.pred,
              B.prob_int,
              A.prob_int AS prev_prob
from dbo.GTsmooth_4 B INNER JOIN #tmp_3Grams_int A
ON A.word_1 = B.word_2 AND
   A.word_2 = B.word_3 AND
   A.pred = B.pred ) Z
   
insert into dbo.[4Grams_int_probs_gt] (word_1, word_2, word_3, pred, prob_int)
select word_1, word_2, word_3, pred, prob_int from #tmp_4Grams_int   