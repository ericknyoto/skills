# FBM stock

Pushing FBM stock from Manobo to Amazon (the stock push serves FBM only:
[ADR 0138](cancel-and-refund.md#adr-0138-flows-per-fulfilment-channel)) and how ChannelAdvisor does it today. The
listing fields a quantity write uses (`fulfillment_availability`) are in
[prices-and-listings.md](prices-and-listings.md#listings-on-amazonde); SKU counts per fulfilment channel in
[channels-and-routing.md](channels-and-routing.md#populations).

## Decisions

### FBM stock is the full Hamburg stock

FBM stock to Amazon = full available Hamburg stock, no buffer; Anja confirmed today's practice (no reserve except a
manual one at Christmas); the Christmas reserve is discussed outside this migration. Asana task completed 29 Oct.
- **Who, when:** the BA, 2026-10-28; Asana task due 2026-12-04, completed 29 Oct
- **Where:** Asana 1219919783814613 (Anja 09:34Z, Nitya 09:57Z); Doc A .74043 (rev 163)

### CA export gate per profile

The CA stock export skips profiles whose channels are all `amazon` (Erick, 30 Oct; S3 spec):
[channels-and-routing.md](channels-and-routing.md#channeladvisor-export-gate-per-profile).

## Facts

- **Stock to CA:** no cron since 2023-07-09; event-driven `ExportStockToChanneladvisorJob` (15-minute delay, per
  product family) plus daily family exports 18:30 and 00:30 Berlin. It pushes to every CA profile, ungated per
  channel. Failures appear only in its log: 17 in October 2026, last on 2026-10-21 (#5984).
- The legacy inventory and price feeds were removed 2025-12-03; FBM quantity and price go through `patchListingsItem`
  or `JSON_LISTINGS_FEED` (Doc A .3057). Rate limits: [monitoring-and-failures.md](monitoring-and-failures.md#transport-and-rate-limits).
- Stopping the CA stock push at the switch needs Rithum's stock sync off: [channels-and-routing.md](channels-and-routing.md#setting-ca_used--0-stops-channeladvisor-for-a-channel).

## Traps

None recorded for this flow yet. The CA stock cron that looks live and is not:
[channels-and-routing.md](channels-and-routing.md#removing-the-cron-line-stops-channeladvisor-for-nenalina).

## How to verify

- One listing with `fulfillmentAvailability`: [prices-and-listings.md](prices-and-listings.md#how-to-verify).
- CA stock failures log: [Production host](../verification.md#production-host).

## Open

- #6052 (FBM stock push: trigger, write mechanism, SKUs and marketplaces written; S2 gate) blocked by #5978:
  [map](../open-state.md#map-tickets).
