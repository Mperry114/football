-- Main role: 30 to 92
CREATE TEMP FUNCTION primary_rating(skill INT64) AS (
  CAST(30 + ROUND(skill * 0.5) + FLOOR(RAND() * 13) AS INT64)
);
-- Other roles: 10 to 60
CREATE TEMP FUNCTION secondary_rating(skill INT64) AS (
  CAST(10 + ROUND(skill * 0.3) + FLOOR(RAND() * 21) AS INT64)
);


with player as (
  select *
  from `football-512314.templates.player_details`
)

, score_assigner as (
  -- Strikers
  select *
    , 'Striker' s_role
    , primary_rating(skill)   i_attack
    , secondary_rating(skill) i_passing
    , secondary_rating(skill) i_tackling
    , secondary_rating(skill) i_goalkeeping
  from (select * from player order by rand() limit 40)
  union all
  -- Midfielder
  select *
    , 'Midfielder' s_role
    , secondary_rating(skill) i_attack
    , primary_rating(skill)   i_passing
    , secondary_rating(skill) i_tackling
    , secondary_rating(skill) i_goalkeeping
  from (select * from player order by rand() limit 80)
  union all
  -- Defenders
  select *
    , 'Defender' s_role
    , secondary_rating(skill) i_attack
    , secondary_rating(skill) i_passing
    , primary_rating(skill)   i_tackling
    , secondary_rating(skill) i_goalkeeping
  from (select * from player order by rand() limit 80)
  union all
  -- Goal Keepers
  select *
    , 'Goalkeeper' s_role
    , secondary_rating(skill) i_attack
    , secondary_rating(skill) i_passing
    , secondary_rating(skill) i_tackling
    , primary_rating(skill)   i_goalkeeping
from (select * from player order by rand() limit 20)
)

select distinct row_number() over() player_id
  , *
from score_assigner
