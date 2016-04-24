use [Analytics_DB1]

truncate table dbo.[1-Grams_prob]

drop table #tmp_1grams
select word,
       pred
into #tmp_1grams
from dbo.[1-Grams]

drop table #tmp_2grams
select word_1,
       pred
into #tmp_2grams
from dbo.[2-Grams]

-- Get the discounting factor
DECLARE @UNQ BIGINT
SET @UNQ = (select distinct COUNT(*) from #tmp_2grams)

drop table #tmp_final_1Grams
select replace(cast(X.word as varchar), '"', '') AS word, 
       Z.pred,
      (cast(Z.gcount as float) / cast(@UNQ as float)) as prob
into #tmp_final_1Grams
from #tmp_1grams X INNER JOIN 
     (select pred,
             COUNT_BIG(1) as gcount
      from #tmp_2grams
      GROUP BY pred ) Z 
ON X.pred = Z.pred
     
--select * from dbo.[1-Grams] where word like '"are"'
--select * from #tmp_final_1Grams order by prob desc

insert into [Analytics_DB1].dbo.[1-Grams_prob] (word, pred, prob)
select word, pred, prob from #tmp_final_1Grams where word <> 'NA'

--select word, pred, prob from [Analytics_DB1].dbo.[1-Grams_prob] order by prob desc