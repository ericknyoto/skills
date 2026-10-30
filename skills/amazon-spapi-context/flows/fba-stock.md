# FBA stock

Reading FBA stock from Amazon into Manobo (the FBA stock import serves FBA only:
[ADR 0138](cancel-and-refund.md#adr-0138-flows-per-fulfilment-channel)) and the inventory API. Which SKU a stock row
belongs to rests on the SKU mapping (#5978): [prices-and-listings.md](prices-and-listings.md#sku-formats). Scope: UK
and US get FBA stock ([scope decision](governance-and-timeline.md#scope-is-20-nenalina-channels)).

## Decisions

### A9 FBA stock not used today

A9: 'not a problem, we're not using FBA stock at the moment'; the warehouse list still waits for Andreas; the early
go-live question is unanswered. (Part of the BA's partial answer of 28 Oct; its `-L` half is in
[prices-and-listings.md](prices-and-listings.md#l-suffix-only-on-old-products).)
- **Who, when:** the BA, 2026-10-28
- **Where:** Asana 1219920153544088 (08:56Z); Doc A .75339

## Facts

- getInventorySummaries returns 50 SKUs per page with `nextToken` (2026-10-27). Rate limit 2/2:
  [monitoring-and-failures.md](monitoring-and-failures.md#transport-and-rate-limits).
- The FBA-IN channels AN.IS 52, AN.UI 68 and AN.UK 118 book FBA stock as pseudo-orders:
  [channels-and-routing.md](channels-and-routing.md#nenalina-channels-production-replica-2026-10-28).

## Traps

None recorded for this flow yet; the cross-cutting ones are in [traps.md](../traps.md).

## How to verify

**FBA stock of a SKU** (SP-API GET script in [verification.md](../verification.md#sp-api-read-only)):
`GET /fba/inventory/v1/summaries?details=true&granularityType=Marketplace&granularityId={mp}&marketplaceIds={mp}&sellerSkus={sku}`
(50 per page). Last OK 2026-10-28.

## Open

- #5979 (FBA stock import: target warehouse, Amazon as source of truth; S2 gate) blocked by #5987 (which warehouse
  holds FBA stock, A9) and #5989: [map](../open-state.md#map-tickets).
- Asana 1219920153544088 (warehouse; early FBA-import go-live before the peak, Sarina decides): [Asana](../open-state.md#asana-business-questions).
- Unticketed on the map: UK and US FBA stock flows: [map](../open-state.md#map-tickets).
