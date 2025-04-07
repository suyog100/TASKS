USE roundof16;


DROP TABLE IF EXISTS SemiFinalWinners;
CREATE TABLE SemiFinalWinners (
    match_id VARCHAR(2),
    team_id VARCHAR(5),
    team_name VARCHAR(50)
);

DROP PROCEDURE IF EXISTS FillSemiFinalWinners;
DELIMITER $$

CREATE PROCEDURE FillSemiFinalWinners()
BEGIN
    DELETE FROM SemiFinalWinners;

    INSERT INTO SemiFinalWinners (match_id, team_id, team_name)
    SELECT 
        match_id,
        team_id,
        team_name
    FROM SemiFinalMatches AS sfm
    WHERE score = (
        SELECT MAX(score)
        FROM SemiFinalMatches
        WHERE match_id = sfm.match_id
    );
END $$
DELIMITER ;

-- Run it
CALL FillSemiFinalWinners();

-- -------------------------------------------------------------------
-- 1. Create FinalMatch Table
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS FinalMatch;
CREATE TABLE FinalMatch (
    match_id VARCHAR(2),
    team_id VARCHAR(5),
    team_name VARCHAR(50),
    score INT
);

-- -------------------------------------------------------------------
-- 2. Procedure to Insert Final Match (Non-draw)
-- -------------------------------------------------------------------
DROP PROCEDURE IF EXISTS InsertFinalNonDraw;
DELIMITER $$

CREATE PROCEDURE InsertFinalNonDraw(IN m_id VARCHAR(2), IN t1 VARCHAR(5), IN t2 VARCHAR(5))
BEGIN
    DECLARE s1 INT DEFAULT FLOOR(RAND() * 5);
    DECLARE s2 INT DEFAULT FLOOR(RAND() * 5);
    DECLARE name1 VARCHAR(50);
    DECLARE name2 VARCHAR(50);

    WHILE s1 = s2 DO
        SET s2 = FLOOR(RAND() * 5);
    END WHILE;

    SELECT team_name INTO name1 FROM Teams WHERE custom_team_id = t1 LIMIT 1;
    SELECT team_name INTO name2 FROM Teams WHERE custom_team_id = t2 LIMIT 1;

    INSERT INTO FinalMatch (match_id, team_id, team_name, score)
    VALUES 
        (m_id, t1, name1, s1),
        (m_id, t2, name2, s2);
END$$
DELIMITER ;


-- -------------------------------------------------------------------
-- 3. Procedure to Fill Final
-- -------------------------------------------------------------------
DROP PROCEDURE IF EXISTS FillFinal;

DELIMITER $$

CREATE PROCEDURE FillFinal()
BEGIN
    DECLARE s1_winner VARCHAR(5);
    DECLARE s2_winner VARCHAR(5);

    DELETE FROM FinalMatch;

    SELECT team_id INTO s1_winner FROM SemiFinalWinners WHERE match_id = 'S1';
    SELECT team_id INTO s2_winner FROM SemiFinalWinners WHERE match_id = 'S2';

    CALL InsertFinalNonDraw('F1', s1_winner, s2_winner);
END$$
DELIMITER ;

-- Run it
CALL FillFinal();

SELECT * FROM FinalMatch;

-- -------------------------------------------------------------------
-- 4. Run it!
-- -------------------------------------------------------------------
CALL FillFinal();
SELECT * FROM FinalMatch; 
