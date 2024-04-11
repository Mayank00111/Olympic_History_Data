SELECT * FROM athletes
LIMIT 10;

SELECT * FROM athlete_events
ORDER BY year
LIMIT 10;

-- 1 which team has won the maximum gold medals over the years

SELECT team, count(medal) AS cnt 
FROM athletes a
INNER JOIN athlete_events ae ON a.id = ae.athlete_id 
WHERE medal='Gold'
GROUP BY team
ORDER BY cnt DESC
LIMIT 10;

-- 2. for each team print total silver medals and year in which they won maximum silver medal..
-- output 3 columns
-- team,  total_silver_medals,  year_of_max_silver

SELECT  team,  COUNT(medal) AS total_silver_medal
FROM athletes a
JOIN athlete_events ae ON a.id = ae.athlete_id
WHERE medal = 'Silver'
GROUP BY team;

WITH CTE AS(
select a.team, ae.year , count(distinct event) as silver_medals
,rank() over(partition by team order by count(distinct event) desc) as rn
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal='Silver'
group by a.team,ae.year
)
SELECT team, year, SUM(silver_medals) AS total_silver_medal,  max(case when rn=1 then year end) as  year_of_max_silver
from CTE
group by team, year;

-- 3 which player has won maximum gold medals  amongst the players 
-- which have won only gold medal (never won silver or bronze) over the years

WITH CTE AS
(
SELECT  name, medal
FROM athletes a
INNER JOIN athlete_events ae ON a.id = ae.athlete_id 
)
SELECT name, count(medal) AS cnt
FROM CTE 
WHERE name NOT IN (select distinct name from cte where medal in ('Silver','Bronze')) AND medal = 'Gold'
GROUP BY name
ORDER BY cnt DESC;

-- 4. In each year which player has won maximum gold medal . Write a query to print year,player name 
-- And no of golds won in that year. In case of a tie print comma separated player names.

-- You can disable sql_mode=only_full_group_by by some command you can try this by terminal or MySql IDE

set global sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,
NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
set session sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,
NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';

SHOW VARIABLES LIKE 'sql_mode';



WITH CTE AS(
select ae.year,a.name,count(1) as no_of_gold
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal='Gold'
group by ae.year,a.name
ORDER BY YEAR 
), CTE2 AS(
select *, concat(name,',') as players from (
select *,
rank() over(partition by year order by no_of_gold desc) as rn
from CTE) a where rn=1
)
SELECT year, players, no_of_gold FROM CTE2;


-- 5. In which event and year India has won its first gold medal,first silver medal and first bronze medal
-- print 3 columns medal,year,sport
SELECT * FROM athlete_events
LIMIT 10;
SELECT * FROM athletes
LIMIT 10;

-- TINY APPROACH 
WITH CTE AS(
SELECT  medal, year, event,  RANK() OVER(PARTITION BY medal ORDER BY year) AS rn
FROM athletes a
JOIN  athlete_events ae ON a.id = ae.athlete_id
WHERE team = 'India' AND medal IS NOT NULL
ORDER BY year
)
SELECT distinct * 
FROM CTE WHERE rn = 1;

select distinct * from (
select medal,year,event,rank() over(partition by medal order by year)  rn
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where team='India' and medal != 'NA'
) A
where rn=1;

-- 6. Find players who won gold medal in summer and winter olympics both.

select a.name  
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal='Gold'
group by a.name 
having count(distinct season)=2;

-- 7. Find players who won gold, silver and bronze medal in a single olympics. Print player name along with year.

select year,name
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal != 'NA'
group by year,name having count(distinct medal)=3;

-- 8 Find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
-- Assume summer olympics happens every 4 year starting 2000. print player name and event name.

with cte as (
select name,year,event
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where year >=2000 and season='Summer'and medal = 'Gold'
group by name,year,event)
select * from
(select *, lag(year,1) over(partition by name,event order by year ) as prev_year
, lead(year,1) over(partition by name,event order by year ) as next_year
from cte) A
where year=prev_year+4 and year=next_year-4






