-- ================================
-- STEP 1: Create the database
-- ================================
DROP DATABASE IF EXISTS roundof16;
CREATE DATABASE roundof16;
USE roundof16;

-- ================================
-- STEP 2: Create Teams table
-- ================================
drop table Teams;
CREATE TABLE Teams (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(50) NOT NULL,
    pool ENUM('Pool A', 'Pool B') NOT NULL,
    group_name ENUM('A','B','C','D','E','F','G','H','I') NOT NULL,
    custom_team_id VARCHAR(5)
);

-- ================================
-- STEP 3: Insert Teams
-- ================================

-- Teams in Pool A (Groups A–D)
INSERT INTO Teams (team_name, pool, group_name) VALUES
('Nepal', 'Pool A', 'A'), ('Brazil', 'Pool A', 'A'), ('Germany', 'Pool A', 'A'), ('Argentina', 'Pool A', 'A'),
('France', 'Pool A', 'B'), ('England', 'Pool A', 'B'), ('Italy', 'Pool A', 'B'), ('Spain', 'Pool A', 'B'),
('Portugal', 'Pool A', 'C'), ('Netherlands', 'Pool A', 'C'), ('Belgium', 'Pool A', 'C'), ('Croatia', 'Pool A', 'C'),
('Uruguay', 'Pool A', 'D'), ('Denmark', 'Pool A', 'D'), ('Switzerland', 'Pool A', 'D'), ('Mexico', 'Pool A', 'D');

-- Teams in Pool B (Groups E–I)
INSERT INTO Teams (team_name, pool, group_name) VALUES
('USA', 'Pool B', 'E'), ('Japan', 'Pool B', 'E'), ('South Korea', 'Pool B', 'E'), ('Australia', 'Pool B', 'E'),
('Saudi Arabia', 'Pool B', 'F'), ('Iran', 'Pool B', 'F'), ('Qatar', 'Pool B', 'F'), ('Ghana', 'Pool B', 'F'),
('Senegal', 'Pool B', 'G'), ('Morocco', 'Pool B', 'G'), ('Tunisia', 'Pool B', 'G'), ('Algeria', 'Pool B', 'G'),
('Nigeria', 'Pool B', 'H'), ('Cameroon', 'Pool B', 'H'), ('Egypt', 'Pool B', 'H'), ('Ivory Coast', 'Pool B', 'H');

-- ================================
-- STEP 4: Assign custom_team_id (e.g. A1, A2...)
-- ================================
UPDATE Teams t
JOIN (
    SELECT 
        team_id,
        CONCAT(group_name, ROW_NUMBER() OVER (PARTITION BY pool, group_name ORDER BY team_id)) AS new_id
    FROM Teams
) ranked
ON t.team_id = ranked.team_id
SET t.custom_team_id = ranked.new_id;

-- ================================
-- STEP 5: Create Matches table
-- ================================
DROP TABLE IF EXISTS Matches;

CREATE TABLE Matches (
    match_id INT AUTO_INCREMENT PRIMARY KEY,
    group_name ENUM('A','B','C','D','E','F','G','H','I') NOT NULL,
    pool ENUM('Pool A', 'Pool B') NOT NULL,
    team1_id INT NOT NULL,
    team2_id INT NOT NULL,
    team1_score INT DEFAULT 0,
    team2_score INT DEFAULT 0,
    FOREIGN KEY (team1_id) REFERENCES Teams(team_id),
    FOREIGN KEY (team2_id) REFERENCES Teams(team_id)
);

-- ================================
-- STEP 6: Create Standings table
-- ================================
CREATE TABLE Standings (
    team_id INT PRIMARY KEY,
    group_name ENUM('A','B','C','D','E','F','G','H','I') NOT NULL,
    pool ENUM('Pool A', 'Pool B') NOT NULL,
    matches_played INT DEFAULT 0,
    wins INT DEFAULT 0,
    losses INT DEFAULT 0,
    draws INT DEFAULT 0,
    goals_for INT DEFAULT 0,
    goals_against INT DEFAULT 0,
    goal_difference INT DEFAULT 0,
    points INT DEFAULT 0,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
);

-- ================================
-- STEP 7: Procedure to generate matches
-- ================================
DROP PROCEDURE IF EXISTS GenerateMatches;
DELIMITER $$

CREATE PROCEDURE GenerateMatches()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE t1 INT;
    DECLARE t2 INT;
    DECLARE grp CHAR(1);
    DECLARE pool VARCHAR(10);

    -- Cursor for all team pairs within same group & pool
    DECLARE team_cursor CURSOR FOR
        SELECT t1.team_id, t2.team_id, t1.group_name, t1.pool
        FROM Teams t1
        JOIN Teams t2 
            ON t1.group_name = t2.group_name 
           AND t1.pool = t2.pool 
           AND t1.team_id < t2.team_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Clear previous matches
    DELETE FROM Matches;

    OPEN team_cursor;

    read_loop: LOOP
        FETCH team_cursor INTO t1, t2, grp, pool;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Insert random score match
        INSERT INTO Matches (group_name, pool, team1_id, team2_id, team1_score, team2_score)
        VALUES (grp, pool, t1, t2, FLOOR(RAND() * 5), FLOOR(RAND() * 5));
    END LOOP;

    CLOSE team_cursor;
END $$

DELIMITER ;

-- ================================
-- STEP 8: Procedure to calculate standings
-- ================================
DROP PROCEDURE IF EXISTS CalculateStandings;
DELIMITER $$

CREATE PROCEDURE CalculateStandings()
BEGIN
    -- Clear old standings
    TRUNCATE TABLE Standings;

    -- Insert new calculated standings
    INSERT INTO Standings (
        team_id, group_name, pool, matches_played,
        wins, losses, draws, goals_for, goals_against,
        goal_difference, points
    )
    SELECT 
        t.team_id,
        t.group_name,
        t.pool,
        COUNT(m.match_id) AS matches_played,
        SUM(
            CASE 
                WHEN (m.team1_id = t.team_id AND m.team1_score > m.team2_score) 
                  OR (m.team2_id = t.team_id AND m.team2_score > m.team1_score)
                THEN 1 ELSE 0 
            END
        ) AS wins,
        SUM(
            CASE 
                WHEN (m.team1_id = t.team_id AND m.team1_score < m.team2_score) 
                  OR (m.team2_id = t.team_id AND m.team2_score < m.team1_score)
                THEN 1 ELSE 0 
            END
        ) AS losses,
        SUM(CASE WHEN m.team1_score = m.team2_score THEN 1 ELSE 0 END) AS draws,
        SUM(CASE WHEN m.team1_id = t.team_id THEN m.team1_score ELSE m.team2_score END) AS goals_for,
        SUM(CASE WHEN m.team1_id = t.team_id THEN m.team2_score ELSE m.team1_score END) AS goals_against,
        SUM(CASE WHEN m.team1_id = t.team_id THEN m.team1_score - m.team2_score ELSE m.team2_score - m.team1_score END) AS goal_difference,
        SUM(
            CASE 
                WHEN (m.team1_id = t.team_id AND m.team1_score > m.team2_score) 
                  OR (m.team2_id = t.team_id AND m.team2_score > m.team1_score)
                THEN 3
                WHEN m.team1_score = m.team2_score THEN 1
                ELSE 0
            END
        ) AS points
    FROM Teams t
    LEFT JOIN Matches m 
        ON t.team_id IN (m.team1_id, m.team2_id)
        AND t.group_name = m.group_name 
        AND t.pool = m.pool
    GROUP BY t.team_id, t.group_name, t.pool;
END $$

DELIMITER ;

-- ================================
-- STEP 9: Create a View to display standings
-- ================================

CREATE OR REPLACE VIEW View_Standings AS
SELECT 
    t.custom_team_id AS Team_ID,
    t.team_name AS Team,
    s.group_name AS Group_Grp,
    s.pool AS Pool,
    s.matches_played AS MP,         -- Matches Played
    s.wins AS W,                    -- Wins
    s.draws AS D,                   -- Draws
    s.losses AS L,                  -- Losses
    s.goals_for AS GF,              -- Goals For
    s.goals_against AS GA,          -- Goals Against
    s.goal_difference AS GD,        -- Goal Difference
    s.points AS PTS,                 -- Points
    ROW_NUMBER() OVER (
        PARTITION BY s.pool, s.group_name 
        ORDER BY s.points DESC, s.goal_difference DESC, s.goals_for DESC
    ) AS rnk
FROM Standings s
JOIN Teams t ON t.team_id = s.team_id
ORDER BY s.pool, s.group_name, s.points DESC, s.goal_difference DESC;


-- chekcing that the rank column that we added is correct or not 
SELECT * FROM View_Standings WHERE group_grp = 'A' ORDER BY rnk;



-- ================================
-- STEP 10: Generate matches & standings
-- ================================
CALL GenerateMatches();
CALL CalculateStandings();

-- ================================
-- STEP 11: View the final standings
-- ================================
SELECT * FROM View_Standings;


-- format milayer herna khojeko 
SELECT * FROM (
    SELECT 
        t.custom_team_id AS Team_ID,
        t.team_name AS Team,
        s.group_name AS Group_Grp,
        s.pool AS Pool,
        s.matches_played AS MP,
        s.wins AS W,
        s.draws AS D,
        s.losses AS L,
        s.goals_for AS GF,
        s.goals_against AS GA,
        s.goal_difference AS GD,
        s.points AS PTS,
        CONCAT(s.pool, '-', s.group_name) AS group_sort
    FROM Standings s
    JOIN Teams t ON t.team_id = s.team_id

    UNION ALL

    -- Add blank rows as separators between groups
    SELECT
        '' AS Team_ID, '' AS Team, '' AS Group_Grp, '' AS Pool,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        CONCAT(s.pool, '-', s.group_name) AS group_sort
    FROM (
        SELECT DISTINCT pool, group_name FROM Standings
    ) s
) AS combined
ORDER BY group_sort, PTS DESC, GD DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ROUND OF 16 STARTS
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Step 1: Create RoundOf16Matches Table
drop table RoundOf16Matches;
CREATE TABLE RoundOf16Matches (
    match_id VARCHAR(2),
    team_id VARCHAR(5),
    team_name VARCHAR(50),
    score INT
);

-- ================================
-- Procedure to Fill Round of 16 Matches with No Draws
-- ================================

DROP PROCEDURE IF EXISTS FillRoundOf16;
DELIMITER $$

CREATE PROCEDURE FillRoundOf16()
BEGIN
    DECLARE team1_id VARCHAR(5);
    DECLARE team1_name VARCHAR(50);
    DECLARE team2_id VARCHAR(5);
    DECLARE team2_name VARCHAR(50);
    DECLARE match_code VARCHAR(2);
    DECLARE score1 INT;
    DECLARE score2 INT;

    DECLARE r16_cursor CURSOR FOR
        SELECT 
            r.match_code,
            t1.Team_ID, t1.Team,
            t2.Team_ID, t2.Team
        FROM (
            SELECT 'R1' AS match_code, 'A' AS g1, 1 AS r1, 'B' AS g2, 2 AS r2
            UNION ALL SELECT 'R2', 'A', 2, 'B', 1
            UNION ALL SELECT 'R3', 'C', 1, 'D', 2
            UNION ALL SELECT 'R4', 'C', 2, 'D', 1
            UNION ALL SELECT 'R5', 'E', 1, 'F', 2
            UNION ALL SELECT 'R6', 'E', 2, 'F', 1
            UNION ALL SELECT 'R7', 'G', 1, 'H', 2
            UNION ALL SELECT 'R8', 'G', 2, 'H', 1
        ) r
        JOIN View_Standings t1 ON t1.Group_Grp = r.g1 AND t1.rnk = r.r1
        JOIN View_Standings t2 ON t2.Group_Grp = r.g2 AND t2.rnk = r.r2;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET match_code = NULL;

    -- Clean table first
    DELETE FROM RoundOf16Matches;

    OPEN r16_cursor;

    loop_matches: LOOP
        FETCH r16_cursor INTO match_code, team1_id, team1_name, team2_id, team2_name;

        IF match_code IS NULL THEN
            LEAVE loop_matches;
        END IF;

        -- Generate non-draw scores
        SET score1 = FLOOR(RAND()*5);
        SET score2 = FLOOR(RAND()*5);

        WHILE score1 = score2 DO
            SET score2 = FLOOR(RAND()*5);
        END WHILE;

        -- Insert both team entries
        INSERT INTO RoundOf16Matches (match_id, team_id, team_name, score)
        VALUES 
            (match_code, team1_id, team1_name, score1),
            (match_code, team2_id, team2_name, score2);

    END LOOP;

    CLOSE r16_cursor;
END $$

DELIMITER ;
CALL FillRoundOf16();



-- Step 2: Fill R16 Matches
INSERT INTO RoundOf16Matches (match_id, team_id, team_name, score)
SELECT
    r.match_code,
    t1.Team_ID,
    t1.Team,
    FLOOR(RAND()*5)
FROM (
    SELECT 'R1' AS match_code, 'A' AS g1, 1 AS r1
    UNION ALL SELECT 'R2', 'A', 2
    UNION ALL SELECT 'R3', 'C', 1
    UNION ALL SELECT 'R4', 'C', 2
    UNION ALL SELECT 'R5', 'E', 1
    UNION ALL SELECT 'R6', 'E', 2
    UNION ALL SELECT 'R7', 'G', 1
    UNION ALL SELECT 'R8', 'G', 2
) r
JOIN View_Standings t1 ON t1.Group_Grp = r.g1 AND t1.rnk = r.r1

UNION ALL

SELECT
    r.match_code,
    t2.Team_ID,
    t2.Team,
    FLOOR(RAND()*5)
FROM (
    SELECT 'R1' AS match_code, 'B' AS g2, 2 AS r2
    UNION ALL SELECT 'R2', 'B', 1
    UNION ALL SELECT 'R3', 'D', 2
    UNION ALL SELECT 'R4', 'D', 1
    UNION ALL SELECT 'R5', 'F', 2
    UNION ALL SELECT 'R6', 'F', 1
    UNION ALL SELECT 'R7', 'H', 2
    UNION ALL SELECT 'R8', 'H', 1
) r
JOIN View_Standings t2 ON t2.Group_Grp = r.g2 AND t2.rnk = r.r2;

-- Step 3: View Knockout Matches
SELECT * FROM RoundOf16Matches;
SELECT * FROM RoundOf16Matches
ORDER BY match_id;


SELECT 
    match_id,
    CONCAT('===== MATCH ', match_id, ' =====') AS match_info,
    NULL AS team_id,
    NULL AS team_name,
    NULL AS score
FROM (
    SELECT DISTINCT match_id FROM RoundOf16Matches
) AS headers

UNION ALL

SELECT 
    match_id,
    NULL AS match_info,
    team_id,
    team_name,
    score
FROM RoundOf16Matches

ORDER BY match_id, match_info DESC;


-- tesing new format 
SELECT 
    match_id,
    team_id,
    team_name,
    score
FROM (
    SELECT 
        match_id,
        team_id,
        team_name,
        score,
        0 AS sort_order
    FROM RoundOf16Matches

    UNION ALL

    SELECT 
        match_id,
        '' AS team_id,
        '' AS team_name,
        NULL AS score,
        1 AS sort_order
    FROM (
        SELECT DISTINCT match_id FROM RoundOf16Matches
    ) AS blanks
) AS combined
ORDER BY match_id, sort_order, team_id;









