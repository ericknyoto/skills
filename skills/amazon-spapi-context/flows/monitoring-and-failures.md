# Monitoring and failures

How Amazon flows run and fail: the SP-API transport, throttling and rate limits (ADR 0129), failure tables per
stage, Sentry alarms, the watchdog, the supervisor and queues, the operations digest and the Amazon Google Chat space
(ADR 0139, #5977), and Erick's rule that keeps n8n out of the core flows. The import error ledger
(`RecordOrderImportErrorAction`) as ChannelAdvisor uses it today: [orders-import.md](orders-import.md#channeladvisor-import-today).

## Decisions

### ADR 0129 one SP-API transport

One `SellingPartnerApi` transport with an `SpApiOperation` enum; Redis token bucket per (seller account,
operation), wait ≤ 10 s else `SellingPartnerThrottled`; retry only via `$when` (idempotent ops: 429/5xx/connection,
max 3); `createFeed` never replayed on timeout/5xx → `SellingPartnerOutcomeUnknown`; feeds as `amazon_seller_feeds`
rows polled by a self-re-dispatching job. Client shape, credential modes, `amazon-seller` log channel, endpoint
guard and `includedData=FULFILLMENT` are recorded only in #5972.
- **Status:** Accepted 2026-10-27 (delegated); PR #5993 merged 2026-10-27 06:46Z (`cdbedc6282`)
- **Where:** #5972 c6435263857; Doc A .46035

### ADR 0139 failures alarms and supervisor

Failures recorded per stage: an Amazon order that never entered Manobo → existing `order_import_errors` with source
`amazon:<seller account>` (hourly n8n sheet unchanged); every failure after import → new `amazon_seller_failures` in
`Domain\AmazonSeller` (flow, reason enum, subject `jng_sp_orders_id`/SKU/feed id, Amazon code + message ≤ 500 chars,
occurrences, resolved at/by; no payload or PII). Reasons terminal (park the subject until a person resolves it:
outcome unknown, rejected, ambiguous item, not served, refund already refunded) or transient (next sweep retries).
IT alarms = Sentry `error` events per kind; operations get a daily digest and an immediate post for money-path
terminal rows in a dedicated Amazon Google Chat space (name per BRD; "Order N8N" stays for MS Direct), posted by
Manobo directly to the space's incoming webhook (config/env), no n8n (Erick: "Harusnya jarang diubah. Jadi dari
Manobo saja."); Amazon import errors join the existing hourly n8n sheet push unchanged, no new workflow
(coordinator's reading on Erick's delegation, reported to him as an assumption). Config on #5977 only:
`supervisor-amazon-seller` with queues `amazon-seller` then `amazon-seller-listings`, `retryUntil` +
`maxExceptions = 1`, 15-minute watchdog, daily duplicate check, order pull 5 min, shipment confirmation 15 min,
cancellation feed 30 min.
- **Status:** **Accepted** 2026-10-30 (approved by Erick Nyoto, commit `3bbdbd64b0`; Q1–Q9 and round 2 delegated,
  answered by the coordinator; Chat-space default corrected by Erick the same day); branch
  `5977-adr-amazon-seller-failures` (head `3bbdbd64b0`, transport settled 30 Oct; option (d) "everything in
  `order_import_errors`" added as rejected at Erick's request); PR #6053 merged to master 2026-10-30 04:45Z (`b53a9b8971`)
- **Where:** #5977 c6514635367; Doc A: coordinator logs it; Doc A .84988 (Accepted, PR #6053 merged b53a9b8971)

### No n8n in Amazon core processes

**No n8n in Amazon core processes**: order pull, confirmShipment, cancellation and refund feeds, stock, price and FBA
imports run 100% in Manobo; n8n only for notifications and similar, and every plan to use n8n is confirmed with Erick
first. "Order N8N" Chat space stays for MS Direct orders; Amazon gets its own space.
- **Who, when:** Erick, 2026-10-30
- **Where:** Manager Amazon chat 30 Oct; Asana story 1220041038698373; map #5967 Notes; #5977 c6514635367

## Facts

### Transport and rate limits

- **Rate limits** (rps / burst, per account-application pair; Usage Plan tables in `github.com/amzn/selling-partner-api-models`,
  read 2026-10-30; the `x-amzn-RateLimit-Limit` header can apply other values): getOrder v2026 and v0 0.5/30;
  getOrderItems v0 0.5/30; createFeed 0.0083/15; getFeed 2/15; createFeedDocument 0.5/15; getFeedDocument 0.0222/10;
  getListingsItem 5/10; patchListingsItem 5/**5**; putListingsItem 5/10; getInventorySummaries 2/2;
  listFinancialEventsByOrderId v0 0.5/30; listTransactions 2024-06-19 0.5/10; createReport 0.0167/15; getReport 2/15;
  getReportDocument 0.0167/15 (searchOrders in [orders-import.md](orders-import.md#the-amazon-order-stream),
  confirmShipment in [shipment-confirmation.md](shipment-confirmation.md#facts)).
- **Notifications API** delivers only to an SQS queue or an EventBridge bus in our own AWS account; no webhook. ORDER_CHANGE,
  FEED_PROCESSING_FINISHED and REPORT_PROCESSING_FINISHED all need one, so every flow polls (2026-10-30; #5977).

### Failure records today

- **Failure records today** (replica, 2026-10-30; #5977): `order_import_errors` open rows: ChannelAdvisor 1,638 (566 in 30
  days), MS Direct 1,156, Tradebyte 5,490, all reported (resolved rows are deleted after the push);
  `channeladvisor_order_ship_failures` 0 rows; `order_status_update_rejections` 133 MS Direct rows open; production
  `failed_jobs` 2,923 rows in 30 days. Horizon's LongWaitDetected mail (it.team@julie-grace.com) covers only queue
  `general`; job exceptions reach Sentry as handled warnings.

## Traps

None recorded for this flow yet; the cross-cutting ones are in [traps.md](../traps.md).

## How to verify

No saved query for the failure counts; run them through the replica wrapper in
[verification.md](../verification.md#production-replica).

## Open

Live state is in [open-state.md](../open-state.md); the lines that touch this flow:

- Who receives the daily Amazon failure digest and the immediate refund/cancel alert (BRD requirement, no answer
  yet): [Deadlines ahead](../open-state.md#deadlines-ahead).
- The S1 spec #6062 covers `amazon_seller_failures`, alarms, watchdog, digest and the supervisor: [S1 spec](../open-state.md#s1-spec-6062).
- Unticketed on the map: an Admin Tool page for Amazon failure rows; the re-import trigger for an Amazon order whose
  import failed: [map](../open-state.md#map-tickets).
