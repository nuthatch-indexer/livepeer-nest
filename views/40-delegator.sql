-- Delegator entity (mirrors the Livepeer subgraph `Delegator`).
-- PARITY NOTE: bonded_amount is the snapshot carried by the delegator's most recent Bond event.
-- Subsequent Unbond/Rebond/WithdrawStake mutate the true balance and are NOT folded in here — a
-- faithful running balance needs delta accumulation across four event types (a follow-up view).
-- delegate_address / start_round are exact.
CREATE VIEW delegator AS
SELECT
    b.delegator                     AS id,
    b.newDelegate                   AS delegate_address,
    b.bondedAmount                  AS bonded_amount,
    b.bondedAmount_dec              AS bonded_amount_dec,
    b.block_number                  AS last_bond_block,
    (SELECT id FROM round WHERE start_block <= b.block_number ORDER BY id DESC LIMIT 1) AS start_round
FROM "bondingmanager__bond" b
QUALIFY ROW_NUMBER() OVER (PARTITION BY b.delegator ORDER BY b.block_number DESC, b.log_index DESC) = 1;
