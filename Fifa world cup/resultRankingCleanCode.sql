DROP TABLE IF EXISTS TournamentFinalRanking;
CREATE TABLE TournamentFinalRanking (
    position VARCHAR(15),
    team_id VARCHAR(5),
    team_name VARCHAR(50)
);

DROP PROCEDURE IF EXISTS FillFinalRanking;
DELIMITER $$

CREATE PROCEDURE FillFinalRanking()
BEGIN
    DECLARE champion_id VARCHAR(5);
    DECLARE runner_up_id VARCHAR(5);
    DECLARE third_place_id VARCHAR(5);
    DECLARE fourth_place_id VARCHAR(5);
    DECLARE champion_name VARCHAR(50);
    DECLARE runner_up_name VARCHAR(50);
    DECLARE third_place_name VARCHAR(50);
    DECLARE fourth_place_name VARCHAR(50);

    DELETE FROM TournamentFinalRanking;

    -- Final
    SELECT team_id INTO champion_id 
    FROM FinalMatch 
    WHERE score = (SELECT MAX(score) FROM FinalMatch);

    SELECT team_id INTO runner_up_id 
    FROM FinalMatch 
    WHERE score <> (SELECT MAX(score) FROM FinalMatch);

    -- Third place
    SELECT team_id INTO third_place_id 
    FROM ThirdPlaceMatch 
    WHERE score = (SELECT MAX(score) FROM ThirdPlaceMatch);

    SELECT team_id INTO fourth_place_id 
    FROM ThirdPlaceMatch 
    WHERE score <> (SELECT MAX(score) FROM ThirdPlaceMatch);

    -- Get names
    SELECT team_name INTO champion_name FROM Teams WHERE custom_team_id = champion_id LIMIT 1;
    SELECT team_name INTO runner_up_name FROM Teams WHERE custom_team_id = runner_up_id LIMIT 1;
    SELECT team_name INTO third_place_name FROM Teams WHERE custom_team_id = third_place_id LIMIT 1;
    SELECT team_name INTO fourth_place_name FROM Teams WHERE custom_team_id = fourth_place_id LIMIT 1;

    -- Insert positions
    INSERT INTO TournamentFinalRanking (position, team_id, team_name)
    VALUES 
        ('Champion', champion_id, champion_name),
        ('Runner-Up', runner_up_id, runner_up_name),
        ('Third Place', third_place_id, third_place_name),
        ('Fourth Place', fourth_place_id, fourth_place_name);
END$$
DELIMITER ;

-- Run it
CALL FillFinalRanking();

SELECT * FROM TournamentFinalRanking;


