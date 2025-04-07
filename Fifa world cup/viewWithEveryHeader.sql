CREATE OR REPLACE VIEW AllMatchesViewWithHeaders AS

-- ================================
-- Group Stage Header
-- ================================
SELECT 
    'Group Stage' AS stage,
    'Team_ID | Group | Pool | MP | W | D | L | GF | GA | GD | PTS' AS info

UNION ALL

-- Group Stage Data
SELECT 
    NULL,
    CONCAT(
        team_id, ' | ',
        group_name, ' | ',
        pool, ' | ',
        matches_played, ' | ',
        wins, ' | ',
        draws, ' | ',
        losses, ' | ',
        goals_for, ' | ',
        goals_against, ' | ',
        goal_difference, ' | ',
        points
    )
FROM standings

UNION ALL
SELECT NULL, NULL

-- ================================
-- Round of 16 Header
-- ================================
UNION ALL
SELECT 
    'Round of 16',
    'Match_ID | Team_ID | Team_Name | Score'

UNION ALL
SELECT 
    NULL,
    CONCAT(match_id, ' | ', team_id, ' | ', team_name, ' | ', score)
FROM roundof16matches

UNION ALL
SELECT NULL, NULL

-- ================================
-- Quarter Final Header
-- ================================
UNION ALL
SELECT 
    'Quarter Finals',
    'Match_ID | Team_ID | Team_Name | Score'

UNION ALL
SELECT 
    NULL,
    CONCAT(match_id, ' | ', team_id, ' | ', team_name, ' | ', score)
FROM quarterfinalmatches

UNION ALL
SELECT NULL, NULL

-- ================================
-- Semi Final Header
-- ================================
UNION ALL
SELECT 
    'Semi Finals',
    'Match_ID | Team_ID | Team_Name | Score'

UNION ALL
SELECT 
    NULL,
    CONCAT(match_id, ' | ', team_id, ' | ', team_name, ' | ', score)
FROM semifinalmatches

UNION ALL
SELECT NULL, NULL

-- ================================
-- Final Header
-- ================================
UNION ALL
SELECT 
    'Final',
    'Match_ID | Team_ID | Team_Name | Score'

UNION ALL
SELECT 
    NULL,
    CONCAT(match_id, ' | ', team_id, ' | ', team_name, ' | ', score)
FROM finalmatch

UNION ALL
SELECT NULL, NULL

-- ================================
-- Third Place Header
-- ================================
UNION ALL
SELECT 
    'Third Place',
    'Match_ID | Team_ID | Team_Name | Score'

UNION ALL
SELECT 
    NULL,
    CONCAT(match_id, ' | ', team_id, ' | ', team_name, ' | ', score)
FROM thirdplacematch

UNION ALL
SELECT NULL, NULL

-- ================================
-- Final Rankings Header
-- ================================
UNION ALL
SELECT 
    'Final Rankings',
    'Position | Team_ID | Team_Name'

UNION ALL
SELECT 
    NULL,
    CONCAT(position, ' | ', team_id, ' | ', team_name)
FROM tournamentfinalranking;

SELECT * FROM AllMatchesViewWithHeaders;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------------------------------------

DELIMITER $$

CREATE PROCEDURE sp_ShowAllTournamentMatches()
BEGIN
    SELECT * FROM AllMatchesViewWithHeaders;
END $$

DELIMITER ;


