-- Protocol entity (mirrors the Livepeer subgraph singleton `Protocol`, id = "0").
-- PARITY NOTE: current_round and the counts below are exact (event-derived). The subgraph's
-- inflation / inflationChange / totalActiveStake fields are read via eth_call inside the mapping
-- and are therefore outside nuthatch's deterministic event-only data path — they are intentionally
-- absent here rather than approximated. (An effectful WASM annotator could add them later.)
CREATE VIEW protocol AS
SELECT
    '0'                                                                    AS id,
    (SELECT max(round_dec) FROM "roundsmanager__new_round")                AS current_round,
    (SELECT count(*) FROM transcoder WHERE status = 'Registered')          AS num_active_transcoders,
    (SELECT count(*) FROM transcoder)                                      AS total_transcoders,
    (SELECT count(*) FROM "roundsmanager__new_round")                      AS total_rounds,
    (SELECT count(DISTINCT delegator) FROM "bondingmanager__bond")         AS total_delegators,
    (SELECT count(*) FROM "pollcreator__poll_created")                     AS total_polls;
