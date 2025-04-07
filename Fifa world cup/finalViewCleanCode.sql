CREATE OR REPLACE VIEW AllMatches AS
-- ================================
-- Group Stage Matches
-- ================================
SELECT 
    'Group Stage' AS stage,
    match_id,
    team_name,
    score
FROM roundof16matches
WHERE match_id IN (SELECT DISTINCT match_id FROM roundof16matches)

UNION ALL

-- ================================
-- Gap after Group Stage (empty line)
-- ================================
SELECT 
    NULL AS stage,
    NULL AS match_id,
    NULL AS team_name,
    NULL AS score

UNION ALL

-- ================================
-- Round of 16 Matches
-- ================================
SELECT 
    'Round of 16' AS stage,
    match_id,
    team_name,
    score
FROM roundof16matches

UNION ALL

-- ================================
-- Gap after Round of 16 (empty line)
-- ================================
SELECT 
    NULL AS stage,
    NULL AS match_id,
    NULL AS team_name,
    NULL AS score

UNION ALL

-- ================================
-- Quarter Final Matches
-- ================================
SELECT 
    'Quarter Finals' AS stage,
    match_id,
    team_name,
    score
FROM quarterfinalmatches

UNION ALL

-- ================================
-- Gap after Quarter Finals (empty line)
-- ================================
SELECT 
    NULL AS stage,
    NULL AS match_id,
    NULL AS team_name,
    NULL AS score

UNION ALL

-- ================================
-- Semi Final Matches
-- ================================
SELECT 
    'Semi Finals' AS stage,
    match_id,
    team_name,
    score
FROM semifinalmatches

UNION ALL

-- ================================
-- Gap after Semi Finals (empty line)
-- ================================
SELECT 
    NULL AS stage,
    NULL AS match_id,
    NULL AS team_name,
    NULL AS score

UNION ALL

-- ================================
-- Final Match
-- ================================
SELECT 
    'Final' AS stage,
    match_id,
    team_name,
    score
FROM finalmatch

UNION ALL

-- ================================
-- Gap after Final (empty line)
-- ================================
SELECT 
    NULL AS stage,
    NULL AS match_id,
    NULL AS team_name,
    NULL AS score

UNION ALL

-- ================================
-- Third Place Match
-- ================================
SELECT 
    'Third Place' AS stage,
    match_id,
    team_name,
    score
FROM thirdplacematch

UNION ALL

-- ================================
-- Tournament Final Ranking
-- ================================

SELECT 
    'Final Ranking' AS stage,
    NULL AS match_id,
    team_name,
    position AS score  -- corrected from 'ranking' to 'position'
FROM tournamentfinalranking;


-- ================================
-- Winner (final match winner)
-- ================================
-- SELECT 
--     'Winner' AS stage,
--     match_id,
--     team_name,
--     score
-- FROM finalmatch
-- WHERE match_id = (SELECT MAX(match_id) FROM finalmatch);


-- -----------------------------------------------------------------------------------------------------------------------------------------------------
SELECT * FROM AllMatches;




