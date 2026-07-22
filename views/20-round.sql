-- Round entity (mirrors the Livepeer subgraph `Round`).
-- One row per protocol round, from RoundsManager.NewRound. Fully event-derived.
CREATE VIEW round AS
SELECT
    round_dec                       AS id,
    "round"                         AS round_hex,
    block_number                    AS start_block,
    block_timestamp                 AS start_timestamp,
    blockHash                       AS block_hash,
    lead(block_number) OVER (ORDER BY round_dec) AS next_round_start_block
FROM "roundsmanager__new_round"
QUALIFY ROW_NUMBER() OVER (PARTITION BY round_dec ORDER BY block_number DESC, log_index DESC) = 1;
