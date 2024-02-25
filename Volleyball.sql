--Converting Duration Length to just Time

ALTER TABLE BeachVolleyball.dbo.Volleyball
ADD DurationConverted time

UPDATE BeachVolleyball.dbo.Volleyball
SET DurationConverted = CONVERT(time(0),duration)

SELECT DurationConverted
FROM BeachVolleyball.dbo.Volleyball

-- Create Columns for Average Heights of Both Winning and Losing Teams

SELECT (w_p1_hgt + w_p2_hgt)/2 as w_team_avg_hgt
FROM BeachVolleyball.dbo.Volleyball

ALTER TABLE BeachVolleyball.dbo.Volleyball
ADD w_team_avg_hgt int

UPDATE BeachVolleyball.dbo.Volleyball
SET w_team_avg_hgt = (w_p1_hgt + w_p2_hgt)/2

SELECT (l_p1_hgt + l_p2_hgt)/2 as l_team_avg_hgt
FROM BeachVolleyball.dbo.Volleyball

ALTER TABLE BeachVolleyball.dbo.Volleyball
ADD l_team_avg_hgt int

UPDATE BeachVolleyball.dbo.Volleyball
SET l_team_avg_hgt = (l_p1_hgt + l_p2_hgt)/2

-- Figuring Out if Height Correlates with Greater Amounts of Wins

SELECT COUNT(*)
FROM BeachVolleyball.dbo.Volleyball
WHERE w_team_avg_hgt > l_team_avg_hgt
--29987

SELECT COUNT(*)
FROM BeachVolleyball.dbo.Volleyball
WHERE l_team_avg_hgt > w_team_avg_hgt
--24103

SELECT COUNT(*)
FROM BeachVolleyball.dbo.Volleyball
WHERE l_team_avg_hgt = w_team_avg_hgt
--12307

SELECT COUNT(*)
FROM BeachVolleyball.dbo.Volleyball
WHERE l_team_avg_hgt is NULL or w_team_avg_hgt is NULL
--19114
--Lots of missing data for player heights

--Does having the tallest player on the court lead to more wins?

SELECT COUNT(*)
FROM BeachVolleyball.dbo.Volleyball
WHERE (w_p1_hgt > l_p1_hgt and w_p1_hgt > l_p2_hgt) or (w_p2_hgt > l_p1_hgt and w_p2_hgt > l_p2_hgt)
--32540

SELECT COUNT(*)
FROM BeachVolleyball.dbo.Volleyball
WHERE (l_p1_hgt > w_p1_hgt and l_p1_hgt > w_p2_hgt) or (l_p2_hgt > w_p1_hgt and l_p2_hgt > w_p2_hgt)
--26271

-- Figuring Out if Age Correlates with Greater Amounts of Wins

SELECT AVG(w_p1_age + w_p2_age)/2 AS avg_w_age
FROM BeachVolleyball.dbo.Volleyball
--28.689

SELECT AVG(l_p1_age + l_p2_age)/2 AS avg_l_age
FROM BeachVolleyball.dbo.Volleyball
--28.289

SELECT AVG(w_p1_age + w_p2_age +l_p1_age + l_p2_age)/4 AS avg_age
FROM BeachVolleyball.dbo.Volleyball
--Average player age is 28.495

SELECT MAX(w_p1_age) as oldestwp1, MAX(w_p2_age) as oldestwp2, MAX(l_p1_age) as oldestlp1, MAX(l_p2_age) as oldestlp2
FROM BeachVolleyball.dbo.Volleyball
--59.86, 52.399 vs 63.866, 67.764
--Oldest players are on the losing teams

SELECT MIN(w_p1_age) as youngwp1, MIN(w_p2_age) as youngwp2, MIN(l_p1_age) as younglp1, MIN(l_p2_age) as younglp2
FROM BeachVolleyball.dbo.Volleyball
--13.55, 13.413 vs -1.2??, 13.12
--Found an error in the data to address
--After updating the data, the number is 13.234 instead of -1.2, therefore the very youngest players are on losing teams

SELECT l_player1, l_p1_birthdate
FROM BeachVolleyball.dbo.Volleyball
WHERE l_p1_age < 1
--Senna van Den Berg shows birthdate 12-1-2022, cross referenced with online research, this is a typo and should be 2002

SELECT COUNT(l_player1)
FROM BeachVolleyball.dbo.Volleyball
WHERE l_player1 = 'Senna van Den Berg'
-- 1 instance to correct

UPDATE BeachVolleyball.dbo.Volleyball
SET l_p1_age = '18.715948', l_p1_birthdate = '2002-12-01'
WHERE l_player1 = 'Senna van Den Berg'

SELECT COUNT(*)
FROM BeachVolleyball.dbo.Volleyball
WHERE w_p1_age > l_p1_age and w_p1_age > l_p2_age or (w_p2_age > l_p1_age and w_p2_age > l_p2_age)
--43464

SELECT COUNT(*)
FROM BeachVolleyball.dbo.Volleyball
WHERE l_p1_age > w_p1_age and l_p1_age > w_p2_age or (l_p2_age > w_p1_age and l_p2_age > w_p2_age)
--39890


--Seeing Who has won the most and looking at some stats about them

SELECT w_player1, COUNT(*) AS win_count
FROM BeachVolleyball.dbo.Volleyball
GROUP BY w_player1
ORDER BY win_count DESC
--Female (and overall top from this group) is Kerri Walsh Jennings at 880, for Males its Phil Dalhausser with 716

SELECT w_player2, COUNT(*) AS win_count
FROM BeachVolleyball.dbo.Volleyball
GROUP BY w_player2
ORDER BY win_count DESC
--Female is Misty May-Traenor with 806, Male (and overall top) is Todd Rogers with 912

SELECT w_player1, COUNT(*) AS win_count
FROM BeachVolleyball.dbo.Volleyball
WHERE w_player2 = 'Todd Rogers'
GROUP BY w_player1
ORDER BY win_count DESC
--Todd Rogers best partner by far is Phil Dalhausser with 588 wins, second closest is Sean Scott with 195

SELECT l_player2, COUNT(*) AS loss_count
FROM BeachVolleyball.dbo.Volleyball
WHERE l_player2 = 'Todd Rogers'
GROUP BY l_player2
--Todd Rogers has a win-loss record of 912 wins and 341 losses

SELECT l_player1, COUNT(*) AS loss_count
FROM BeachVolleyball.dbo.Volleyball
WHERE l_player2 = 'Todd Rogers'
GROUP BY l_player1
ORDER BY loss_count DESC
--Top two partners when losing for Todd are not surprisingly his top two winning partners, though in inverse order!
--Sean Scott with 107 losses and only 101 with Phil Dalhausser

--Just a fun experiment to see some comparisons of when Todd without Phil beat teams vs when they lost to those same teams

WITH rematch
as
(SELECT a.score as wscore, CONCAT(a.w_player1, ' & ', a.w_player2) as wteam1, CONCAT(a.l_player1, ' & ', a.l_player2) as lteam1, b.score as lscore,
  CONCAT(b.w_player1, ' & ', b.w_player2) as wteam2, CONCAT(b.l_player1, ' & ', b.l_player2) as lteam2
FROM BeachVolleyball.dbo.TRogersW a
JOIN BeachVolleyball.dbo.TRogersL b
on a.w_player1 = b.l_player1)

SELECT DISTINCT *
FROM rematch
WHERE wscore IS NOT NULL
  and lteam1 = wteam2
  and wteam1 NOT LIKE '%Phil%'
ORDER BY lteam1

