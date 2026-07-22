-- Poll entity (mirrors the Livepeer subgraph `Poll`), joining the factory-discovered Poll
-- children back to their creation event. Vote tallies are event-derived (poll__vote); the
-- stake-weighted outcome the subgraph computes needs bonded-stake at poll-end (eth_call), so
-- only raw vote counts are reproduced here.
CREATE VIEW poll AS
SELECT
    pc.poll                         AS id,
    pc.block_number                 AS created_block,
    pc.endBlock_dec                 AS end_block,
    pc.quorum                       AS quorum,
    pc.quota                        AS quota,
    count(v.voter)                  AS total_votes,
    count(DISTINCT v.voter)         AS distinct_voters
FROM "pollcreator__poll_created" pc
LEFT JOIN "poll__vote" v ON lower(v.address) = lower(pc.poll)
GROUP BY pc.poll, pc.block_number, pc.endBlock_dec, pc.quorum, pc.quota;
