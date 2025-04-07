
use roundof16;
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS QuarterFinalWinners;
CREATE TABLE QuarterFinalWinners (
    match_id VARCHAR(2),
    team_id VARCHAR(5),
    team_name VARCHAR(50)
);

DROP PROCEDURE IF EXISTS FillQuarterFinalWinners;
DELIMITER $$

CREATE PROCEDURE FillQuarterFinalWinners()
BEGIN
    DECLARE qf_match VARCHAR(2);

    -- Clear previous winners
    DELETE FROM QuarterFinalWinners;

    -- Insert winners of Q1 to Q4
    INSERT INTO QuarterFinalWinners (match_id, team_id, team_name)
    SELECT 
        match_id,
        team_id,
        team_name
    FROM QuarterFinalMatches AS qfm
    WHERE score = (
        SELECT MAX(score)
        FROM QuarterFinalMatches
        WHERE match_id = qfm.match_id
    );
END $$

DELIMITER ;

CALL FillQuarterFinalWinners();

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- What this block does:
-- It creates a table called QuarterFinalWinners and a procedure FillQuarterFinalWinners() that:

-- Finds the winning team from each quarter-final match (Q1 to Q4) based on the highest score.

-- Stores those winners (along with match ID and team name) in a clean and accessible table: QuarterFinalWinners.

-- Why you need it:
-- semi-final logic depends on the winners of the quarter-finals.

-- The FillSemiFinals() procedure pulls from this exact table:

-- SELECT team_id INTO q1_winner FROM QuarterFinalWinners WHERE match_id = 'Q1';
-- If you skip this code, the QuarterFinalWinners table won’t exist or be filled correctly — and your semi-finals won’t have any teams to match up.



-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Semi fianls here we come
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS SemiFinalMatches;
CREATE TABLE SemiFinalMatches (
    match_id VARCHAR(2),
    team_id VARCHAR(5),
    team_name VARCHAR(50),
    score INT
);

-- ---------------------------------------------------------------------------------------------------------------------------------------
-- Procedure to insert a semi-final match (with random non-draw scores)
-- ---------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS InsertSemiNonDraw;

DELIMITER $$

CREATE PROCEDURE InsertSemiNonDraw(IN m_id VARCHAR(2), IN t1 VARCHAR(5), IN t2 VARCHAR(5))
BEGIN
    DECLARE s1 INT DEFAULT FLOOR(RAND() * 5);
    DECLARE s2 INT DEFAULT FLOOR(RAND() * 5);
    DECLARE name1 VARCHAR(50);
    DECLARE name2 VARCHAR(50);

    -- Ensure no draw
    WHILE s1 = s2 DO
        SET s2 = FLOOR(RAND() * 5);
    END WHILE;

    -- Get team names
    SELECT team_name INTO name1 FROM Teams WHERE custom_team_id = t1 LIMIT 1;
    SELECT team_name INTO name2 FROM Teams WHERE custom_team_id = t2 LIMIT 1;

    -- Insert the match
    INSERT INTO SemiFinalMatches (match_id, team_id, team_name, score)
    VALUES 
        (m_id, t1, name1, s1),
        (m_id, t2, name2, s2);
END$$

DELIMITER ;
-- ------------------------------------------------------------------------------------------------------------------------------------
-- Procedure to fill the semi-final matchups
-- ------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS FillSemiFinals;

DELIMITER $$

CREATE PROCEDURE FillSemiFinals()
BEGIN
    DECLARE q1_winner VARCHAR(5);
    DECLARE q2_winner VARCHAR(5);
    DECLARE q3_winner VARCHAR(5);
    DECLARE q4_winner VARCHAR(5);

    -- Clean slate
    DELETE FROM SemiFinalMatches;

    -- Get winners from the QuarterFinalWinners table (which you already made!)
    SELECT team_id INTO q1_winner FROM QuarterFinalWinners WHERE match_id = 'Q1';
    SELECT team_id INTO q2_winner FROM QuarterFinalWinners WHERE match_id = 'Q2';
    SELECT team_id INTO q3_winner FROM QuarterFinalWinners WHERE match_id = 'Q3';
    SELECT team_id INTO q4_winner FROM QuarterFinalWinners WHERE match_id = 'Q4';

    -- Semi matchups
    CALL InsertSemiNonDraw('S1', q1_winner, q2_winner);  -- S1: Winner Q1 vs Q2
    CALL InsertSemiNonDraw('S2', q3_winner, q4_winner);  -- S2: Winner Q3 vs Q4
END$$

DELIMITER ;
-- ------------------------------------------------------------------------------------------------------------------------------------
--  Running the procedures
-- ------------------------------------------------------------------------------------------------------------------------------------
CALL FillSemiFinals();
SELECT * FROM SemiFinalMatches;
-- ------------------------------------------------------------------------------------------------------------------------------------


--  What we did right:
-- Creating QuarterFinalWinners properly 

-- Using MAX(score) logic to determine the winners 

-- Creating SemiFinalMatches 

-- Random non-draw logic in InsertSemiNonDraw ️

-- Using LIMIT 1 in team name selects to avoid errors 

-- Good use of DELETE FROM to reset before inserts 

-- Correct match logic: Q1 vs Q2 and Q3 vs Q4 












