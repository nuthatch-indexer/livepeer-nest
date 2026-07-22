-- Protocol singleton. Parity: current_round must equal RoundsManager.currentRound() and
-- num_active_transcoders must equal BondingManager.getTranscoderPoolSize() at the pinned tip.
SELECT id, current_round, num_active_transcoders, total_transcoders, total_rounds
FROM protocol;
