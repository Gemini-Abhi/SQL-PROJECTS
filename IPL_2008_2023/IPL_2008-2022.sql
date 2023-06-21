--IPL_2008-2022 Analysis
select * from IPL_Matches_2008_2022

alter table IPL_Matches_2008_2022
drop column method


update IPL_Matches_2008_2022 
set Team2 = 'Royal Challengers Bangalore'
where Team2= 'Royal Challengers Bengaluru'

update IPL_Matches_2008_2022 
set WinningTeam = 'Rising Pune Supergiant'
where WinningTeam= 'Rising Pune Supergiants'

--Number of IPL teams each year
select Season, count(season) as Number_of_Teams 
from
    (select team1 ,season from [IPL_Matches_2008_2022] union select Team2 ,season from [IPL_Matches_2008_2022] ) s
group by Season order by Season 

--How many matches are won by each team through out 2008-2022?
select WinningTeam, COUNT(winningteam) as No_of_matches 
from [dbo].[IPL_Matches_2008_2022]  group by WinningTeam order by No_of_matches desc



--Create a  stored procedure for   Points table for IPL matches?
create procedure Points_table @year varchar(50)
as
with Points as 
(select team1 as team_name,
case when team1 = winningteam then 1 else 0 end as Win_flag
from IPL_Matches_2008_2022 where Season like  @year 
union all
select team2 as team_name,
case when team2 = winningteam then 1 else 0 end as Win_flag
from IPL_Matches_2008_2022 where Season like  @year )  

select team_name,COUNT(win_flag) as No_of_Played_matches,SUM(win_flag) as Total_wins,
COUNT(win_flag) - SUM(win_flag) as Total_losses
from points group by team_name order by Total_wins desc, No_of_Played_matches desc

exec Points_table '2012'

--Points Table
with Points as 
(select team1 as team_name,
case when team1 = winningteam then 1 else 0 end as Win_flag
from IPL_Matches_2008_2022 
union all
select team2 as team_name,
case when team2 = winningteam then 1 else 0 end as Win_flag
from IPL_Matches_2008_2022  )  

select team_name,COUNT(win_flag) as No_of_Played_matches,SUM(win_flag) as Total_wins,
COUNT(win_flag) - SUM(win_flag) as Total_losses
from points group by team_name order by Total_wins desc, No_of_Played_matches desc


--Toss Winner as well as match winner
with cte as (select tosswinner,
case when winningteam=tosswinner then 1 else 0 end as check1
from IPL_Matches_2008_2022 )
select  tosswinner , count(*) as No_of_Matches_Won 
from cte where check1 = 1 
group by tosswinner 
order by No_of_Matches_Won desc


select * from Toss_and_match_Winner

--toss winner as well as Match winner percentage
with toss_cte as ( select  team_name,COUNT(team_name) as Total_win
					from (select team1 as team_name from IPL_Matches_2008_2022
						 union all
						select team2 as team_name from IPL_Matches_2008_2022) s group by team_name)

				,toss_winner as (select tosswinner,COUNT(tosswinner) as Total_toss_winner from IPL_Matches_2008_2022 group by tosswinner )

select  t1.team_name,Total_win,No_of_Matches_Won as total_toss_and_Match_winner,round((No_of_Matches_Won*1.0/Total_win)*100,2) as Toss_and_match_win_percentage
from toss_cte t1 join toss_winner t2 on t1.team_name=t2.tosswinner 
join Toss_and_match_Winner ts on t1.team_name=ts.tosswinner
order by Toss_and_match_win_percentage desc



--On which venue most matches were played 
select venue,city,count(venue)as Count_ from IPL_Matches_2008_2022 group by venue ,city order by count(venue)   desc

--Which venue results in a win for Batting first team ?
select venue, WinningTeam,TossWinner,TossDecision,count(venue)as Matches_played from IPL_Matches_2008_2022
where WinningTeam = TossWinner and TossDecision = 'bat'
group by venue, WinningTeam,TossWinner,TossDecision order by Matches_played   desc


--Chase and Defend Percentage
with CD as (select WinningTeam,
sum(case when WonBy = 'Wickets' then 1 else 0 end) as Chase,
sum(case when WonBy= 'Runs' then 1 else 0 end )as Defend
from [dbo].[IPL_Matches_2008_2022] where WinningTeam is not null  group by WinningTeam )
select *,
round(cast(((chase*1.0/(chase+defend))*100) as float),2) as Percentage_Chasing,
round(cast(((defend*1.0/(chase+defend))*100) as float),2) as Percentage_Defend
from cd

--Percentage Win in Superover
select * from superover
--create view superover as select * from [dbo].[IPL_Matches_2008_2022]  where SuperOver = 1

with cte1 as(
			select team_name , COUNT(*)  as Total from 
			(
			select team1 as team_name from superover
			union all
			select team2 as team_name from superover) s
			 where team_name in (select winningteam from superover)
			 group by team_name
			)
,cte2 as	(select winningteam as team_name,COUNT(winningteam) Winning_Count
			from superover  group by winningteam)

select c2.team_name,total as Total_Superover_Matches,winning_count, cast((winning_count*1.0/total*100) as float) as Percentage_win 
from cte1 c1 join cte2 c2 on c1.team_name=c2.team_name




--Home Wins
select  WinningTeam,City,COUNT(winningteam) Home_Wins from IPL_Matches_2008_2022
where city is not null and
winningteam = 'Chennai Super Kings' and city = 'Chennai' or
winningteam = 'Delhi capitals' and city = 'Delhi' or
winningteam like '%pune%'  and city = 'Pune' or
winningteam like '%pune%'  and city = 'Pune' or
winningteam like '%Gujarat%'  and city = 'Ahmedabad' or
winningteam like '%rajasthan%'  and city = 'Jaipur' or
winningteam like '%punjab%'  and city = 'Chandigarh' or
winningteam like '%bangalore%'  and city = 'bengaluru' 
 group by WinningTeam,City
 
 select  WinningTeam,COUNT(winningteam) from IPL_Matches_2008_2022
where city is not null  group by WinningTeam

select distinct city from [dbo].[IPL_Matches_2008_2022] order by city where WinningTeam is not null

--Number of times Qualified
with matchnumber as (select team1 as team_name ,matchnumber from IPL_Matches_2008_2022
union all
select Team2 as team_name , matchnumber from IPL_Matches_2008_2022)

select team_name,count(matchnumber) as Number_of_times_Qualified 
from matchnumber where MatchNumber in ('Qualifier 1','Qualifier 2') group by team_name order by  Number_of_times_Qualified desc


--What is the percentage of wins of each team?
with points_table as (select team1 as team_name,
case when team1 = winningteam then 1 else 0 end as Win_flag
from IPL_Matches_2008_2022 
union all
select team2 as team_name,
case when team2 = winningteam then 1 else 0 end as Win_flag
from IPL_Matches_2008_2022)

select team_name,COUNT(win_flag) as No_of_Played_matches,SUM(win_flag) as Total_wins,
COUNT(win_flag) - SUM(win_flag) as Total_losses,
round(SUM(win_flag)*100/COUNT(win_flag),2) Percentage_Wins

from points_table group by team_name order by Percentage_Wins desc, No_of_Played_matches desc


--Who won the most player of the matches in the tournament?

select season,player_of_match , count(player_of_match ) as Numner_of_wins
from IPL_Matches_2008_2022 group by Season, player_of_match order by Season desc, Numner_of_wins desc

--Who won the most player of the matches all time?
select player_of_match , count(player_of_match ) as Numner_of_wins
from IPL_Matches_2008_2022 group by player_of_match order by Numner_of_wins desc



--Who is the most consistent batsman and bowler in each team and also in the entire league?
--Predict the winning team with the consistency of wins and ball deliveries?
--Who is the most valuable player of every season?

select * from IPL_Matches_2008_2022