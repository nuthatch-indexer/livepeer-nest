-- Top 20 transcoders by reward() calls. Parity: reward_cut / fee_share / activation_round /
-- deactivation_round must match BondingManager.getTranscoder(id) at the pinned tip.
SELECT id, reward_cut, fee_share, activation_round, deactivation_round, status
FROM transcoder
ORDER BY reward_calls DESC NULLS LAST, id
LIMIT 20;
