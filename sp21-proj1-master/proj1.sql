-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
	SELECT MAX(era)
	FROM pitching
  -- replace this line
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
	WHERE weight > 300 -- replace this line
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE '% %'
	ORDER BY namefirst, namelast-- replace this line
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
	FROM people
	GROUP BY birthyear -- replace this line
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT * FROM q1iii
  WHERE avgheight > 70
  

	-- replace this line
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT p.namefirst, p.namelast, p.playerid AS playerid, h.yearid
	FROM people AS p, HallofFame AS h
	WHERE p.playerid=h.playerid AND h.inducted="Y"
	ORDER BY yearid DESC, playerid ASC-- replace this line
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT i.namefirst, i.namelast, i.playerid AS playerid, s.schoolID as schoolid, i.yearid AS yearid
  FROM q2i AS i, Schools AS s, CollegePlaying as c
  WHERE i.playerid=c.playerid AND 
  c.schoolID=s.schoolID AND s.schoolState LIKE "CA"
  ORDER BY yearid DESC, schoolid, playerid
	-- replace this line
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT i.playerid AS playerid, i.namefirst, i.namelast, c.schoolID AS schoolid
	FROM q2i AS i LEFT OUTER JOIN CollegePlaying as c
		ON i.playerid=c.playerid 
		ORDER BY playerid DESC, schoolid ASC-- replace this line
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT b.playerid AS playerid, p.namefirst,p.namelast,b.yearID AS yearid, (b.H-b.H2B-b.H3B-b.HR+2*b.H2B+3*b.H3B+4*b.HR) / (CAST(b.AB AS REAL)) AS slg
	FROM Batting AS b, people AS p
	WHERE b.playerid=p.playerid AND b.AB > 50
	ORDER BY slg DESC,yearid,playerid
	LIMIT 10-- replace this line
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT b.playerid AS playerid, p.namefirst, p.namelast, SUM(b.H-b.H2B-b.H3B-b.HR+2*b.H2B+3*b.H3B+4*b.HR)/(CAST(SUM(b.AB) AS REAL)) AS LSLG
	FROM Batting AS b INNER JOIN people AS p
	ON b.playerid = p.playerid
	GROUP BY b.playerid
	HAVING SUM(b.AB)>50
	ORDER BY lslg DESC, playerid
	LIMIT 10-- replace this line
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  WITH q AS (
  SELECT b.playerid AS playerid, p.namefirst, p.namelast, SUM(b.H-b.H2B-b.H3B-b.HR+2*b.H2B+3*b.H3B+4*b.HR)/(CAST(SUM(b.AB) AS REAL)) AS LSLG
	FROM Batting AS b INNER JOIN people AS p
	ON b.playerid = p.playerid
	GROUP BY b.playerid
	HAVING SUM(b.AB)>50) 
	SELECT namefirst, namelast, lslg
	FROM q
	WHERE lslg> (SELECT lslg FROM q WHERE playerid = 'mayswi01')-- replace this line
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearID AS yearid, MIN(Salary), MAX(Salary), AVG(Salary)
	FROM Salaries
	GROUP BY yearid
	ORDER BY yearid-- replace this line
;


-- Helper table for 4ii
DROP TABLE IF EXISTS binids;
CREATE TABLE binids(binid);
INSERT INTO binids VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
 WITH sinfo AS (
 SELECT MIN(Salary) AS smin, MAX(Salary) AS smax,
 (MAX(Salary)-MIN(Salary))/10 AS srange FROM Salaries WHERE yearID='2016')
 , table1 AS (
 SELECT binids.binid AS binid, 
 sinfo.smin + binid*sinfo.srange AS low,
 sinfo.smin + (binid+1)*sinfo.srange AS high
 FROM binids,sinfo)
 SELECT t.binid AS binid, t.low AS low, t.high AS high, COUNT(*)
 FROM table1 AS t INNER JOIN Salaries AS s
 ON s.salary >= t.low AND (t.binid=9 OR s.salary<t.high)
 WHERE s.yearID='2016'
 GROUP BY binid, low, high
 ORDER BY binid
  
  
  -- replace this line
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
	WITH table_ AS (
	SELECT yearID AS yearid, MIN(Salary) AS smin, MAX(Salary) AS smax, AVG(Salary) AS salary
	FROM Salaries
	GROUP BY yearid
	ORDER BY yearid)
	SELECT t2.yearid, t2.smin-t1.smin AS mindiff, t2.smax-t1.smax AS maxdiff, t2.salary-t1.salary AS avgdiff
	FROM table_ AS t1, table_ AS t2
	WHERE t2.yearid = t1.yearid+1
	
  -- replace this line
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
	WITH table_ AS (
  SELECT MAX(salary) AS msalary, yearID AS yearid
	FROM Salaries AS s
	WHERE yearid = '2000' OR yearid ='2001'
	GROUP BY yearid)
	-- replace this line
	SELECT p.playerid, p.namefirst, p.namelast, s.salary, t.yearid
	FROM people AS p, Salaries AS s, table_ AS t
	WHERE p.playerid = s.playerid AND s.yearID = t.yearid
	AND s.salary = t.msalary
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamID AS teamid, MAX(s.salary) - MIN(s.salary) AS diffAvg
	FROM AllStarFull AS a, Salaries AS s
	WHERE a.playerid = s.playerid
	AND s.yearID = '2016'
	GROUP BY a.teamID
	-- replace this line
;

