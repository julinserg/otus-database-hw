-- написать запрос суммы очков с группировкой и сортировкой по годам
select sum(points) as sum_points, year_game
from statistic
group by year_game
order by year_game
-- написать cte показывающее тоже самое
with sum_points_cte as (
	select sum(points) as sum_points, year_game
	from  statistic 
	group by year_game 
)
select sum_points, year_game
from sum_points_cte
order by year_game
-- используя функцию LAG вывести кол-во очков по всем игрокам за текущий код и за предыдущий.
with sum_points_cte as (
	select sum(points) as sum_points, year_game
	from  statistic 
	group by year_game 
)
select year_game, sum_points as sum_points_in_current_year,
LAG(sum_points, 1) OVER (
    ORDER BY
      year_game
) sum_points_in_previous_year
from sum_points_cte
order by year_game
