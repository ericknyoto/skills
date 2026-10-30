# Shipment confirmation

confirmShipment on Orders v0, carrier codes (#5982) and the cadence of the confirmation. confirmShipment serves FBM
only: [ADR 0138](cancel-and-refund.md#adr-0138-flows-per-fulfilment-channel). Its cadence (shipment confirmation
15 min, config recorded on #5977) and the failure path: [ADR 0139](monitoring-and-failures.md#adr-0139-failures-alarms-and-supervisor).
Code anchors: [sources/github.md](../sources/github.md#code-anchors).

## Decisions

### 5982 carrier codes

`carrierCode` = the last-mile carrier's exact `amzn-base.xsd` code; Metapack is never a code; `Other` + `carrierName`
only for codeless carriers; own map keyed on shipment provider id; confirmShipment stays on v0.
- **Who, when:** research agent, checked by Erick, 2026-10-27
- **Where:** #5982; `research/amazon-carrier-codes`; Doc A .40195

## Facts

- **Orders v0** deprecated 2026-01-28; its read operations are removed 2027-03-27. `confirmShipment`
  (`POST /orders/v0/orders/{orderId}/shipmentConfirmation`, 2 rps, burst 10; requires `packageReferenceId`,
  `carrierCode`, `trackingNumber`, `shipDate`, `orderItems`) is not deprecated and has no v2026 equivalent
  (Doc A .3057; #5982).
- **Carrier codes:** `carrierCode` comes from the `amzn-base.xsd` `CarrierCode` list (Last-Modified 2026-07-09):
  present DHL, DHL Express, DHL-Paket, Deutsche Post, PostNord, Seven Senders, BPOST, Colissimo, Swiss post, Poste
  Italiane, PostNL, Royal Mail, DPD; absent Metapack and Austrian Post. `Other` requires `carrierName` and Amazon
  cannot track it (#5982).
- **ChannelAdvisor today:** shipment confirmation via scheduler `manobo:orders-confirmation` every 30 minutes (#5984).
  FBA orders are skipped only through `no_order_confirmation`: [cancel-and-refund.md](cancel-and-refund.md#channeladvisor-today).
- The CA carrier map `ChanneladvisorOrderService::getShipmentCarrier` sends CA names (`DP`, `Metapack - PostNord`,
  `Bpost`, …) that are not Amazon codes (#5982).

## Traps

### "Metapack and Seven Senders go out as carrierCode Other"

**Believed** in Doc A's flow table (.4945) and backlog (.22389), which still say so.
**True:** send the last-mile carrier's code; Metapack is label software; `Other` only for a carrier without a code
(Austrian Post), and Amazon cannot track it. **Caught** by #5982.

## How to verify

No flow-specific recipe recorded yet. Research write-up: `docs/research/amazon-carrier-codes.md` on branch
`research/amazon-carrier-codes` ([sources/github.md](../sources/github.md#research-branches)).

## Open

- Unticketed on the map: the confirmShipment carrier map: [map](../open-state.md#map-tickets).
