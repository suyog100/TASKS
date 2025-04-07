DROP TABLE IF EXISTS SemiFinalLosers;
CREATE TABLE SemiFinalLosers (
    match_id VARCHAR(2),
    team_id VARCHAR(5),
    team_name VARCHAR(50)
);


DROP PROCEDURE IF EXISTS FillSemiFinalLosers;
DELIMITER $$

CREATE PROCEDURE FillSemiFinalLosers()
BEGIN
    DELETE FROM SemiFinalLosers;

    -- Insert losers from each semi-final match
    INSERT INTO SemiFinalLosers (match_id, team_id, team_name)
    SELECT 
        sf.match_id,
        sf.team_id,
        sf.team_name
    FROM SemiFinalMatches sf
    WHERE NOT EXISTS (
        SELECT 1
        FROM SemiFinalWinners sw
        WHERE sw.match_id = sf.match_id AND sw.team_id = sf.team_id
    );
END $$
DELIMITER ;

-- Run it
CALL FillSemiFinalLosers();

DROP TABLE IF EXISTS ThirdPlaceMatch;
CREATE TABLE ThirdPlaceMatch (
    match_id VARCHAR(2),
    team_id VARCHAR(5),
    team_name VARCHAR(50),
    score INT
);

DROP PROCEDURE IF EXISTS InsertThirdPlaceNonDraw;
DELIMITER $$

CREATE PROCEDURE InsertThirdPlaceNonDraw(IN m_id VARCHAR(2), IN t1 VARCHAR(5), IN t2 VARCHAR(5))
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

    INSERT INTO ThirdPlaceMatch (match_id, team_id, team_name, score)
    VALUES 
        (m_id, t1, name1, s1),
        (m_id, t2, name2, s2);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS FillThirdPlaceMatch;
DELIMITER $$

CREATE PROCEDURE FillThirdPlaceMatch()
BEGIN
    DECLARE loser1 VARCHAR(5);
    DECLARE loser2 VARCHAR(5);

    DELETE FROM ThirdPlaceMatch;

    SELECT team_id INTO loser1 FROM SemiFinalLosers WHERE match_id = 'S1';
    SELECT team_id INTO loser2 FROM SemiFinalLosers WHERE match_id = 'S2';

    CALL InsertThirdPlaceNonDraw('T1', loser1, loser2);
END$$
DELIMITER ;

-- Run it
CALL FillThirdPlaceMatch();

SELECT * FROM ThirdPlaceMatch;




