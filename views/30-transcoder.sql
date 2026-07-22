-- Transcoder entity (mirrors the Livepeer subgraph `Transcoder`), reconstructed from
-- BondingManager events. Event-derived fields only — parity notes:
--   • activationRound / deactivationRound / rewardCut / feeShare: exact (from events).
--   • status: derived from the latest activation vs. deactivation, cross-checked against the
--     current round — matches the subgraph's Registered/NotRegistered semantics.
--   • lastRewardRound: the round in force when the transcoder last called reward().
--   • totalStake / totalVolume*: NOT reproduced here — the subgraph reads those via eth_call
--     (bondingManager.transcoderTotalStake), which is outside nuthatch's event-only data path.
CREATE VIEW transcoder AS
WITH ids AS (
    SELECT DISTINCT transcoder AS id FROM "bondingmanager__transcoder_update"
    UNION
    SELECT DISTINCT transcoder FROM "bondingmanager__transcoder_activated"
),
act AS (
    SELECT transcoder AS id, activationRound_dec AS activation_round, block_number AS act_block
    FROM "bondingmanager__transcoder_activated"
    QUALIFY ROW_NUMBER() OVER (PARTITION BY transcoder ORDER BY block_number DESC, log_index DESC) = 1
),
deact AS (
    SELECT transcoder AS id, deactivationRound_dec AS deactivation_round, block_number AS deact_block
    FROM "bondingmanager__transcoder_deactivated"
    QUALIFY ROW_NUMBER() OVER (PARTITION BY transcoder ORDER BY block_number DESC, log_index DESC) = 1
),
upd AS (
    SELECT transcoder AS id, rewardCut_dec AS reward_cut, feeShare_dec AS fee_share, block_number AS upd_block
    FROM "bondingmanager__transcoder_update"
    QUALIFY ROW_NUMBER() OVER (PARTITION BY transcoder ORDER BY block_number DESC, log_index DESC) = 1
),
rew AS (
    SELECT transcoder AS id, count(*) AS reward_calls, max(block_number) AS last_reward_block
    FROM "bondingmanager__reward" GROUP BY transcoder
),
cur AS (SELECT max(round_dec) AS current_round FROM "roundsmanager__new_round")
SELECT
    i.id,
    u.reward_cut,
    u.fee_share,
    a.activation_round,
    d.deactivation_round,
    r.reward_calls,
    (SELECT id FROM round WHERE start_block <= r.last_reward_block ORDER BY id DESC LIMIT 1) AS last_reward_round,
    CASE
        WHEN a.activation_round IS NOT NULL
             AND (d.deactivation_round IS NULL OR a.act_block > d.deact_block
                  OR d.deactivation_round > (SELECT current_round FROM cur))
        THEN 'Registered' ELSE 'NotRegistered'
    END AS status
FROM ids i
LEFT JOIN act a  ON a.id = i.id
LEFT JOIN deact d ON d.id = i.id
LEFT JOIN upd u  ON u.id = i.id
LEFT JOIN rew r  ON r.id = i.id;
