
-- -----------------------------------------------
-- quater finals here we come
-- --------------------------------------------------
use roundof16;

DROP TABLE IF EXISTS QuarterFinalMatches;
CREATE TABLE QuarterFinalMatches (
    match_id VARCHAR(2),
    team_id VARCHAR(5),
    team_name VARCHAR(50),
    score INT
);
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS FillQuarterFinals;
DELIMITER $$

DROP PROCEDURE IF EXISTS FillQuarterFinals;
DELIMITER $$

CREATE PROCEDURE FillQuarterFinals()
BEGIN
    DECLARE r1_team VARCHAR(5);
    DECLARE r2_team VARCHAR(5);
    DECLARE r3_team VARCHAR(5);
    DECLARE r4_team VARCHAR(5);
    DECLARE r5_team VARCHAR(5);
    DECLARE r6_team VARCHAR(5);
    DECLARE r7_team VARCHAR(5);
    DECLARE r8_team VARCHAR(5);

    -- Clear previous QF matches
    DELETE FROM QuarterFinalMatches;

    -- Get winners from R16
    SELECT team_id INTO r1_team FROM RoundOf16Matches WHERE match_id = 'R1' ORDER BY score DESC LIMIT 1;
    SELECT team_id INTO r2_team FROM RoundOf16Matches WHERE match_id = 'R2' ORDER BY score DESC LIMIT 1;
    SELECT team_id INTO r3_team FROM RoundOf16Matches WHERE match_id = 'R3' ORDER BY score DESC LIMIT 1;
    SELECT team_id INTO r4_team FROM RoundOf16Matches WHERE match_id = 'R4' ORDER BY score DESC LIMIT 1;
    SELECT team_id INTO r5_team FROM RoundOf16Matches WHERE match_id = 'R5' ORDER BY score DESC LIMIT 1;
    SELECT team_id INTO r6_team FROM RoundOf16Matches WHERE match_id = 'R6' ORDER BY score DESC LIMIT 1;
    SELECT team_id INTO r7_team FROM RoundOf16Matches WHERE match_id = 'R7' ORDER BY score DESC LIMIT 1;
    SELECT team_id INTO r8_team FROM RoundOf16Matches WHERE match_id = 'R8' ORDER BY score DESC LIMIT 1;

    -- Helper block to insert 2 teams with different scores
    CALL InsertNonDraw('Q1', r1_team, r2_team);
    CALL InsertNonDraw('Q2', r3_team, r4_team);
    CALL InsertNonDraw('Q3', r5_team, r6_team);
    CALL InsertNonDraw('Q4', r7_team, r8_team);
END $$

DELIMITER ;


CALL FillQuarterFinals();
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS InsertNonDraw;
DELIMITER $$

CREATE PROCEDURE InsertNonDraw(IN m_id VARCHAR(2), IN t1 VARCHAR(5), IN t2 VARCHAR(5))
BEGIN
    DECLARE s1 INT;
    DECLARE s2 INT;

    REPEAT
        SET s1 = FLOOR(1 + RAND() * 5);
        SET s2 = FLOOR(1 + RAND() * 5);
    UNTIL s1 <> s2 END REPEAT;

    INSERT INTO QuarterFinalMatches
    SELECT m_id, team_id, team_name,
        CASE WHEN team_id = t1 THEN s1 ELSE s2 END AS score
    FROM RoundOf16Matches
    WHERE team_id IN (t1, t2);
END $$

DELIMITER ;
CALL FillQuarterFinals();
SELECT * FROM QuarterFinalMatches ORDER BY match_id;



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
    FROM QuarterFinalMatches

    UNION ALL

    SELECT 
        match_id,
        '' AS team_id,
        '' AS team_name,
        NULL AS score,
        1 AS sort_order
    FROM (
        SELECT DISTINCT match_id FROM QuarterFinalMatches
    ) AS blanks
) AS combined
ORDER BY match_id, sort_order, team_id;



