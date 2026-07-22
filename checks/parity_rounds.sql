-- Round progression sanity: rounds are contiguous and monotonic from the Arbitrum genesis round.
-- Parity: the max id must equal RoundsManager.currentRound(); count(*) = distinct rounds seen.
SELECT count(*) AS rounds, min(id) AS first_round, max(id) AS current_round
FROM round;
