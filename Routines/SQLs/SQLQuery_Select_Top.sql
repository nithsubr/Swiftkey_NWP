use Analytics_DB1

-- Select only the top 3

-- 2 Grams
drop table #tmp_2Grams
drop table #tmp_2G

select distinct word_1, pred, avg(prob_int) AS prob_int into #tmp_2Grams from dbo.[2Grams_int_probs] 
group by word_1, pred
ORDER BY word_1, prob_int DESC

select Z.* 
into #tmp_2G
from (select *,
       rowid = ROW_NUMBER() OVER (PARTITION BY word_1 ORDER BY prob_int DESC)
from #tmp_2Grams) Z
where Z.rowid <= 3
ORDER BY word_1, prob_int DESC

truncate table dbo.final_2G
insert into dbo.final_2G (word_1, pred, prob_int)
select word_1, pred, prob_int from #tmp_2G where prob_int > 0


-- 3 Grams
drop table #tmp_3Grams
drop table #tmp_3G

select distinct word_1, word_2, pred, avg(prob_int) AS prob_int into #tmp_3Grams from dbo.[3Grams_int_probs] 
group by word_1, word_2, pred
ORDER BY word_1, word_2, prob_int DESC

select Z.* 
into #tmp_3G
from (select *,
       rowid = ROW_NUMBER() OVER (PARTITION BY word_1, word_2 ORDER BY prob_int DESC)
from #tmp_3Grams) Z
where Z.rowid <= 3
ORDER BY word_1, word_2, prob_int DESC

truncate table dbo.final_3G
insert into dbo.final_3G (word_1, word_2, pred, prob_int)
select word_1, word_2, pred, prob_int from #tmp_3G where prob_int > 0

-- 4 Grams
drop table #tmp_4Grams
drop table #tmp_4G

select distinct word_1, word_2, word_3, pred, avg(prob_int) AS prob_int into #tmp_4Grams from dbo.[4Grams_int_probs] 
group by word_1, word_2, word_3, pred
ORDER BY word_1, word_2, word_3, prob_int DESC

select Z.* 
into #tmp_4G
from (select *,
       rowid = ROW_NUMBER() OVER (PARTITION BY word_1, word_2, word_3 ORDER BY prob_int DESC)
from #tmp_4Grams) Z
where Z.rowid <= 3
ORDER BY word_1, word_2, word_3, prob_int DESC

truncate table dbo.final_4G
insert into dbo.final_4G (word_1, word_2, word_3, pred, prob_int)
select word_1, word_2, word_3, pred, prob_int from #tmp_4G where prob_int > 0

--select * from #tmp_4G where word_1 = '300420' and word_2 = '31223' and word_3 = '757479'
--select * from dbo.final_2G where word_1 = '300420' order by word_1, prob_int desc 