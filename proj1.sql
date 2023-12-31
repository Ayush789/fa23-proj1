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
CREATE VIEW q0(era) AS
 SELECT MAX(era)
 FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE nameFirst like '% %'
  ORDER BY nameFirst, nameLast  -- replace this line
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), count(*)
  FROM people
  GROUP BY birthYear 
  ORDER BY birthYear ASC
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), count(*)
  FROM people
  GROUP BY birthYear 
  HAVING AVG(height) > 70
  ORDER BY birthYear ASC
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT p.namefirst, p.namelast, h.playerid, h.yearid
  FROM halloffame AS h
  LEFT JOIN people AS p ON p.playerID = h.playerID 
  WHERE inducted = 'Y'
  ORDER BY h.yearid DESC, h.playerID ASC 
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT p.namefirst, p.namelast, h.playerid, s.schoolID ,h.yearid
  FROM halloffame h
  JOIN people p ON p.playerID = h.playerID
  JOIN collegeplaying c ON c.playerid = h.playerID 
  JOIN schools s ON s.schoolID = c.schoolID 
  WHERE inducted = 'Y'
  	AND s.schoolState = 'CA'
  ORDER BY h.yearid DESC, h.playerID ASC
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT h.playerid, p.namefirst, p.namelast, s.schoolID
  FROM halloffame h
  LEFT JOIN people p ON p.playerID = h.playerID
  LEFT JOIN collegeplaying c ON c.playerid = h.playerID 
  LEFT JOIN schools s ON s.schoolID = c.schoolID 
  WHERE inducted = 'Y'
  ORDER BY h.playerID DESC,s.schoolID ASC
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT b.playerID ,p.nameFirst ,p.nameLast , b.yearID , CAST(b.H + b.H2B + 2*b.H3B + 3*b.HR AS float)/b.AB AS 'slg'
  FROM batting b
  JOIN people p ON p.playerID = b.playerID 
  WHERE b.AB > 50
  ORDER BY CAST(b.H + b.H2B + 2*b.H3B + 3*b.HR AS float)/b.AB DESC, b.yearID ASC,b.playerID ASC
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  WITH l AS (
    SELECT b.playerID, CAST(SUM(b.H) + SUM(b.H2B) + SUM(2*b.H3B) + SUM(3*b.HR) AS float)/SUM(b.AB) AS lslg
    FROM batting b
    GROUP BY b.playerID
  )
  SELECT b.playerID, p.nameFirst , p.nameLast , l.lslg 
  FROM batting b
  JOIN l ON b.playerID = l.playerID
  JOIN people p on p.playerID = b.playerID 
  WHERE b.AB > 50
  GROUP BY b.playerID
  ORDER BY l.lslg DESC, b.playerID ASC
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  WITH l AS (
    SELECT b.playerID, CAST(SUM(b.H) + SUM(b.H2B) + SUM(2*b.H3B) + SUM(3*b.HR) AS float)/SUM(b.AB) AS lslg
    FROM batting b
    GROUP BY b.playerID
  )
  SELECT p.nameFirst , p.nameLast , l.lslg 
  FROM batting b
  JOIN l ON b.playerID = l.playerID
  JOIN people p on p.playerID = b.playerID 
  WHERE b.AB > 50 AND l.lslg > (SELECT lslg from l where playerID = 'mayswi01') 
  GROUP BY b.playerID
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT s.yearID, MIN(s.salary), MAX(s.salary), AVG(s.salary)
  FROM salaries s 
  GROUP BY s.yearID 
  ORDER BY s.yearID ASC
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH r AS (SELECT CAST(MAX(salary)-MIN(salary) AS FLOAT) r,CAST(MAX(salary)-MIN(salary) AS FLOAT)/10 as q,MIN(salary) as mn,MAX(salary) as mx FROM salaries WHERE yearID = 2016),
  b AS (
    SELECT b.binid, b.binid*r.q + r.mn AS low, (b.binid+1)*r.q + r.mn AS high
    FROM binids b,r
  )
  SELECT b.binid, b.low, b.high,COUNT(*)
  FROM salaries s
  JOIN b on s.salary >= b.low AND s.salary <= b.high
  WHERE s.yearID = 2016
  GROUP BY b.binid

;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  WITH q AS (SELECT  s.yearID, MIN(s.salary) mn, MAX(s.salary) mx, AVG(s.salary) av
  FROM salaries s
  GROUP BY s.yearID)
  SELECT r.yearID, r.mn - q.mn mindiff, r.mx - q.mx maxdiff, r.av - q.av avgdiff
  FROM q
  JOIN q AS r ON r.yearID = q.yearID+1
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT s.playerID,p.nameFirst ,p.nameLast  ,MAX(s.salary), s.yearID 
  FROM salaries s
  JOIN people p on p.playerID = s.playerID 
  WHERE s.yearID = 2000
  UNION
  SELECT s.playerID,p.nameFirst ,p.nameLast  ,MAX(s.salary), s.yearID 
  FROM salaries s
  JOIN people p on p.playerID = s.playerID 
  WHERE s.yearID = 2001
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamID, MAX(s.salary)-MIN(s.salary)
  FROM allstarfull a
  LEFT JOIN salaries s ON s.playerID = a.playerID AND s.yearID = a.yearID 
  WHERE a.yearID = 2016
  GROUP BY a.teamID 
;

