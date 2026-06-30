-- Total Matches
SELECT COUNT(*) AS total_matches
FROM matches;

-- Total Seasons
SELECT COUNT(DISTINCT season)
FROM matches;

-- Total Teams
SELECT COUNT(DISTINCT team1)
FROM matches;

-- Matches Per Season
SELECT season,
COUNT(*) matches
FROM matches
GROUP BY season
ORDER BY season;

-- Most Successful Teams
SELECT match_winner,
COUNT(*) wins
FROM matches
GROUP BY match_winner
ORDER BY wins DESC;

-- Top 10 Run Scorers
SELECT batter,
SUM(batter_runs) runs
FROM balls
GROUP BY batter
ORDER BY runs DESC
LIMIT 10;

-- Top Six Hitters
SELECT batter,
COUNT(*) sixes
FROM balls
WHERE batter_runs=6
GROUP BY batter
ORDER BY sixes DESC
LIMIT 10;

-- Top Four Hitters
SELECT batter,
COUNT(*) fours
FROM balls
WHERE batter_runs=4
GROUP BY batter
ORDER BY fours DESC
LIMIT 10;

-- Top Strike Rate Players
SELECT
batter,
SUM(batter_runs) runs,
COUNT(*) balls_faced,
ROUND(
SUM(batter_runs)*100.0/
COUNT(*),
2
) strike_rate
FROM balls
GROUP BY batter
HAVING runs >= 500
ORDER BY strike_rate DESC
LIMIT 10;

-- Most Wickets
SELECT
bowler,
COUNT(*) wickets
FROM balls
WHERE is_wicket=1
GROUP BY bowler
ORDER BY wickets DESC
LIMIT 10;

-- Economy Rate
SELECT
bowler,
ROUND(
SUM(total_runs)/
(COUNT(*)/6.0),
2
) economy
FROM balls
GROUP BY bowler
HAVING COUNT(*)>=300
ORDER BY economy;

-- Bowling Strike Rate
SELECT
bowler,
COUNT(*) balls_bowled,
SUM(is_wicket) wickets,
ROUND(
COUNT(*)/
SUM(is_wicket),
2
) bowling_sr
FROM balls
GROUP BY bowler
HAVING wickets>20
ORDER BY bowling_sr;

-- Most Matches Hosted
SELECT venue,
COUNT(*) matches
FROM matches
GROUP BY venue
ORDER BY matches DESC;

-- Venues Wise Average Score
SELECT
venue,
AVG(team_runs)
FROM
(
SELECT
m.venue,
b.match_id,
b.team_batting,
SUM(total_runs) team_runs
FROM balls b
JOIN matches m
ON b.match_id=m.match_id
GROUP BY
m.venue,
b.match_id,
b.team_batting
) x
GROUP BY venue;

-- Toss Advantage
SELECT
ROUND(
100*
SUM(
CASE
WHEN toss_winner=match_winner
THEN 1
ELSE 0
END
)/COUNT(*),
2
) toss_advantage
FROM matches;

-- Orange Cap Winners
WITH season_runs AS
(
SELECT
season_id,
batter,
SUM(batter_runs) runs,
RANK() OVER(
PARTITION BY season_id
ORDER BY SUM(batter_runs) DESC
) rnk
FROM balls
GROUP BY season_id,batter
)
SELECT *
FROM season_runs
WHERE rnk=1;

-- Purple Cap Winners
WITH season_wickets AS
(
SELECT
season_id,
bowler,
COUNT(*) wickets,
RANK() OVER(
PARTITION BY season_id
ORDER BY COUNT(*) DESC
) rnk
FROM balls
WHERE is_wicket=1
GROUP BY season_id,bowler
)
SELECT *
FROM season_wickets
WHERE rnk=1;

-- Team Ranking
SELECT
match_winner,
COUNT(*) wins,
RANK() OVER(
ORDER BY COUNT(*) DESC
) ranking
FROM matches
GROUP BY match_winner;

-- Best Finishers
SELECT
batter,
SUM(batter_runs) runs
FROM balls
WHERE over_number>=16
GROUP BY batter
ORDER BY runs DESC
LIMIT 10;

-- Best Powerplay Batters
SELECT
batter,
SUM(batter_runs) runs
FROM balls
WHERE over_number<=6
GROUP BY batter
ORDER BY runs DESC
LIMIT 10;

-- Top Batters for Each Team
WITH batter_team AS (
    SELECT
        team_batting,
        batter,
        SUM(batter_runs) runs,
        RANK() OVER(
            PARTITION BY team_batting
            ORDER BY SUM(batter_runs) DESC
        ) rnk
    FROM balls
    GROUP BY team_batting,batter
)
SELECT *
FROM batter_team
WHERE rnk = 1;

-- Highest Team Score
SELECT
team_batting,
match_id,
SUM(total_runs) score
FROM balls
GROUP BY team_batting,match_id
ORDER BY score DESC
LIMIT 10;

-- Lowest Defended Score
SELECT
match_id,
match_winner,
win_by_runs
FROM matches
WHERE win_by_runs > 0
ORDER BY win_by_runs;

-- Most Player Of the Match Awards
SELECT 
    p.player_name, 
    COUNT(*) AS awards
FROM matches m
JOIN players p ON m.player_of_match = p.player_id
GROUP BY p.player_name
ORDER BY awards DESC;

-- Best Venue for Chasing
SELECT
venue,
COUNT(*) chase_wins
FROM matches
WHERE toss_decision='field'
AND toss_winner=match_winner
GROUP BY venue
ORDER BY chase_wins DESC;

-- Most Consistent Batter
SELECT
batter,
AVG(batter_runs) avg_runs
FROM balls
GROUP BY batter
HAVING COUNT(*) > 1000
ORDER BY avg_runs DESC;

-- Most Economical Bowler by Season
WITH eco AS (
SELECT
season_id,
bowler,
ROUND(
SUM(total_runs)/(COUNT(*)/6.0),
2
) economy,
RANK() OVER(
PARTITION BY season_id
ORDER BY SUM(total_runs)/(COUNT(*)/6.0)
) rnk
FROM balls
GROUP BY season_id,bowler
)
SELECT *
FROM eco
WHERE rnk=1;

-- Team Win PErcentage
WITH matches_played AS (
SELECT team1 team FROM matches
UNION ALL
SELECT team2 FROM matches
),

wins AS (
SELECT match_winner team,
COUNT(*) wins
FROM matches
GROUP BY match_winner
)

SELECT
w.team,
w.wins,
COUNT(mp.team) matches_played,
ROUND(
100*w.wins/COUNT(mp.team),
2
) win_pct
FROM wins w
JOIN matches_played mp
ON w.team=mp.team
GROUP BY w.team,w.wins;

-- Best Finisher
SELECT
batter,
SUM(batter_runs) runs
FROM balls
WHERE over_number BETWEEN 16 AND 20
GROUP BY batter
ORDER BY runs DESC;

-- Most Dangerous Powerplay Bowler
SELECT
bowler,
COUNT(*) wickets
FROM balls
WHERE over_number <= 6
AND is_wicket=1
GROUP BY bowler
ORDER BY wickets DESC;