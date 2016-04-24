use Analytics_DB1

-- Select only the top 3

-- 2 Grams
drop table #tmp_2Grams
drop table #tmp_2G

select distinct word_1, pred, avg(prob_int) AS prob_int into #tmp_2Grams from dbo.[2Grams_int_probs_gt]
group by word_1, pred
ORDER BY word_1, prob_int DESC

select Z.* 
into #tmp_2G
from (select *,
       rowid = ROW_NUMBER() OVER (PARTITION BY word_1 ORDER BY prob_int DESC)
from #tmp_2Grams) Z
where Z.rowid <= 3
ORDER BY word_1, prob_int DESC

truncate table dbo.final_2G_gt
insert into dbo.final_2G_gt (word_1, pred, prob_int)
select word_1, pred, prob_int from #tmp_2G


-- 3 Grams
drop table #tmp_3Grams
drop table #tmp_3G

select distinct word_1, word_2, pred, avg(prob_int) AS prob_int into #tmp_3Grams from dbo.[3Grams_int_probs_gt]
group by word_1, word_2, pred
ORDER BY word_1, word_2, prob_int DESC

select Z.* 
into #tmp_3G
from (select *,
       rowid = ROW_NUMBER() OVER (PARTITION BY word_1, word_2 ORDER BY prob_int DESC)
from #tmp_3Grams) Z
where Z.rowid <= 3
ORDER BY word_1, word_2, prob_int DESC

truncate table dbo.final_3G_gt
insert into dbo.final_3G_gt (word_1, word_2, pred, prob_int)
select word_1, word_2, pred, prob_int from #tmp_3G


-- 4 Grams
drop table #tmp_4Grams
drop table #tmp_4G

select distinct word_1, word_2, word_3, pred, avg(prob_int) AS prob_int into #tmp_4Grams from dbo.[4Grams_int_probs_gt]
group by word_1, word_2, word_3, pred
ORDER BY word_1, word_2, word_3, prob_int DESC

select Z.* 
into #tmp_4G
from (select *,
       rowid = ROW_NUMBER() OVER (PARTITION BY word_1, word_2, word_3 ORDER BY prob_int DESC)
from #tmp_4Grams) Z
where Z.rowid <= 3
ORDER BY word_1, word_2, word_3, prob_int DESC

truncate table dbo.final_4G_gt
insert into dbo.final_4G_gt (word_1, word_2, word_3, pred, prob_int)
select word_1, word_2, word_3, pred, prob_int from #tmp_4G