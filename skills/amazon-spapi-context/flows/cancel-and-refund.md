# Cancel and refund

Which flows serve FBM or FBA (ADR 0138, the rule table for every flow), the `shipment_id` scheme and the raw item
money that refunds rest on (ADR 0131), the cancel and refund feeds, the already-refunded guard and refunds on FBA
orders (#6040, #6039), and returns: ChannelAdvisor today, Seller Central return settings, SP-API returns reports.
`createFeed` is never replayed: [ADR 0129](monitoring-and-failures.md#adr-0129-one-sp-api-transport). Code anchors:
[sources/github.md](../sources/github.md#code-anchors).

## Decisions

### ADR 0138 flows per fulfilment channel

One rule table (enum of flows in `Domain\AmazonSeller`, unit-tested per case): order import + updates, refund feed,
price push = FBM and FBA; confirmShipment, cancellation feed, stock push = FBM; FBA stock import, FBA refund pull =
FBA. Fulfilment channel from the channel's `use_external_warehouse` only; one gate at dispatch and in `handle()`,
after the ADR 0132 integrator check. Refund feed not fulfilment-gated: only for returns recorded in Manobo, after a
mandatory already-refunded lookup (FBM and FBA; designed in #6040). Single-order request a flow does not serve →
failure row `fulfilment_channel_not_served`, no retry; channel-walking flows just skip. Form rule:
`no_order_confirmation` = 1 exactly when FBA on Amazon Seller channels. ChannelAdvisor paths unchanged.
- **Status:** **Accepted** (approved by Erick Nyoto, 29 Oct; Q1–Q9 delegated, Q1 changed to refund feed = both, "keep
  today's model"; decision confirmed "Ok setuju" ~14:10Z after the refund-feed research; fallback to FBM-only if
  Amazon rejects FBA order ids); PR #6041 merged to master 2026-10-30 03:41Z (`238de6e6d8`)
- **Where:** #5974 c6497734388; Doc A: coordinator logs it

### ADR 0131 shipment id and raw item money

`shipment_id` = `<amazonOrderId>AZ`, split channels `<amazonOrderId>AZ<p>N<n>`; `order_id` = Amazon id;
`order_id_external`, `xml_file` NULL; raw item money in `amazon_seller_order_items` (`proceeds`, `quantityOrdered`,
`unitPrice`; written once; natural keys; no buyer blocks); reads add `PROCEEDS`, `PROMOTION`, `TAX`. Amended 28 Oct:
only `proceeds` carries money, Finances API is the fallback for orders imported before capture, and table + suffix
are a per-integrator pattern.
- **Status:** Accepted 2026-10-27 (`4cf924d359`), amended 2026-10-28 (`99c25d18de`, `6440c7feda`); PR #5994 merged
  2026-10-28 06:52Z (`3b0e1164cc`)
- **Where:** #5971 c6435899870; Doc A .50028, .66078, .69284

### ADR 0131 edited before merge without erratum

ADR 0131's body was edited after acceptance and before merge, although `docs/adr/README.md` prescribes
append-only errata. Erick accepted that as is ("Merge begini", 2026-10-28, coordinator ledger); no erratum block.
- **Who, when:** Erick, 2026-10-28
- **Where:** coordinator ledger

### ADR 0131 raw-money table per integrator

Raw-money table stays per integrator; the next direct integrator (Shopify) owns its own table and suffix; a shared
refund flow generalises the port, not the storage.
- **Who, when:** Erick ("Per integrator"), 2026-10-28
- **Where:** ADR 0131 Consequences, `6440c7feda`; Doc A .69284

### 6040 refund fog graduated

Refund fog graduated: grilling #6040 (FBA refund pull source, already-refunded guard, per-unit values, adjustment
feed on FBA orders; S2 gate) blocked by BRD input #6039 (Asana 1219920153544278), which also blocks #5989;
FBA-goods-returned-to-Hamburg question posted to Nitya on that task.
- **Who, when:** coordinator, delegated (#5974 Q6, Q9), 2026-10-29
- **Where:** #6039, #6040; Asana story 1220015351242263; map #5967

## Facts

### Order money on Amazon

- **Item money is only in `proceeds`:** `proceedsTotal` and `breakdowns[]` typed ITEM, SHIPPING, GIFT_WRAP,
  COD_FEE, OTHER, TAX, DISCOUNT, each a line-total `subtotal`; `detailedBreakdowns` only on TAX and DISCOUNT.
  `promotion.breakdowns[]` holds only `promotionId`; `tax` holds `taxCalculationBreakdowns[].reportingScheme` and
  `taxCollections[].{model, responsibleParty}` (`orders_2026-01-01.json`, checked 2026-10-28).
- **Signs and VAT in the item `proceeds`** (240+ DE items, 2026-10-30):
  - `ITEM` is **net of VAT**.
  - `DISCOUNT` is a positive **net** amount that is subtracted.
  - `TAX` is the VAT after the discount.
  - `proceedsTotal = ITEM + SHIPPING + TAX − DISCOUNT`. What the buyer paid for the item = `ITEM − DISCOUNT(ITEM) +
    TAX(ITEM)`, and that equals Manobo `price_selling_after_service × qty` on 243 of 258 items.
  - `product.price.unitPrice` carries DE VAT even when the buyer paid destination VAT (FBM cross-border).
- What Manobo keeps per CA-imported item, and currency: [orders-import.md](orders-import.md#order-money).

### Amazon cancel and refund feeds

- **Feeds:** cancel = `POST_ORDER_ACKNOWLEDGEMENT_DATA`; refund = `POST_PAYMENT_ADJUSTMENT_DATA` (AdjustedItem →
  ItemPriceAdjustments components Principal, Shipping, Tax, …), not deduplicated by Amazon (ADR 0129).
- No documented rule caps a refund at the charged amount; only Seller Forum error 18010 "refund amount for the item
  price is too high" (docs check, 2026-10-28).
- **Finances API** (`listFinancialEventsByOrderId` v0, `listTransactions` 2024-06-19) returns per-item Principal,
  Tax, Shipping and Promotion of a shipped order on demand: up to 48 h lag, 0.5 rps, needs Finance and Accounting
  (held), retention undocumented (ADR 0131). FBA refunds are not in the Orders API: Reports
  `GET_FBA_FULFILLMENT_CUSTOMER_RETURNS_DATA` or Finances (Doc A .5422).

### ChannelAdvisor today

- **Write-backs (refunds):** FBA refunds pulled by `manobo:daily-order-refund` at 03:00 tenant time (#5984). A refund
  to CA carries a quantity only: `ChanneladvisorOrderStatusService::setOrderItemAsAdjusted` posts `{quantity}` to
  `…/order/item/{id}/status/Adjust` and CA derives the money (ADR 0131 Context). `ProcessReturnB2cToChanneladvisorListener`
  sends only returns created in Manobo, and its shipping-cost refund dispatch is commented out "temporary disabled"
  (code, 2026-10-28). Shipment confirmation: [shipment-confirmation.md](shipment-confirmation.md#facts).
- **FBA gating today** (code master `58eea8e9ea` + replica, 2026-10-29): shipment and cancel confirmations skip FBA
  only through the generic checkbox `no_order_confirmation` (1 → `AutoConfirmOrderJob`, closed locally): 1 on all 12
  Nenalina FBA rows, 0 on all 9 FBM rows. The return listener has **no** fulfilment check: an internal return ("Returned
  via Manobo" CS bin-in, "Returned via MC") on an FBA order goes to CA as an Adjust. 365 days: FBM 217 internal returns;
  FBA 3,949 "Returned via CA" (the pull) and 13 internal (goods sent to Hamburg; CA accepted 7, `confirm_return = 1`).
  Finances API on those 13: one refund on 12, none on 1, none doubled. The pull updates only items still in a sent
  status, so an Amazon refund on an item already returned in Manobo is dropped with a log line (#5974; ADR 0138).
- CA Adjust: one adjustment in flight per order (a concurrent one gets 400 and succeeds on retry); an order created
  2026-05-08 answered 404 by October, cause unproven; CA's error `code` differs per request, so classify by
  message (memory channeladvisor-adjust-api-facts, 2026-10-19).

### Refund feed on FBA orders (documentation research, 2026-10-29)

- `POST_PAYMENT_ADJUSTMENT_DATA` (Order Adjustment feed): Amazon's documentation is **silent** on the fulfilment
  channel. The feed-type page and the refund walkthrough (https://developer-docs.amazon.com/sp-api/docs/submit-a-feed,
  re-read 29 Oct) list the eligibility checks as: order exists, inside the refund window, item refundable, not already
  refunded. No FBA/MFN restriction, no numeric error code; the failure text is "Error attempting to issue refund for
  order". `OrderAdjustment.xsd` (reasons incl. `CustomerReturn`, `GeneralAdjustment`) carries no restriction either.
- Rithum/ChannelAdvisor `POST Orders(id)/Adjust` docs (KB0018002, KB0017989) say refunds are "communicated back to the
  marketplace" but never name the Amazon feed used. A 2013 CA staff forum reply says Amazon handles FBA refunds itself
  (dated, low trust). Seller Central help pages need a login and were not read.
- Production evidence (session #5974, Finances API): 12 of 13 internal returns on FBA orders in 12 months show exactly
  one Amazon refund, several on the day of the MC return, so CA Adjust does refund FBA orders through some path.
- Status: **open fact** on #6040. Decision (#5974, ADR 0138): refund feed runs for both channels with the
  already-refunded guard; if Amazon rejects FBA order ids, the rule falls back to FBM-only and CS refunds in Seller
  Central from the failure row. A proof before go-live needs a controlled real order (Erick + Finance go); the sandbox
  cannot answer it.

### Seller Central return settings, FBM orders (screenshot from Erick, 2026-10-30)

Seller Central → Manage Returns → Return Settings, Nenalina account, rows Belgium to Spain visible (Sweden to US not yet seen):

| Marketplaces | Return authorisation | Prepaid return labels | Label type | RMA number |
|---|---|---|---|---|
| DE, FR, IT, ES | In Policy (Amazon): auto-authorised | Enrolled | Amazon Prepaid (exempt items: unpaid label) | Amazon |
| BE, IE, NL, PL | In Policy (Amazon): auto-authorised | not enrolled | Unpaid label (buyer pays postage) | Amazon |
| CA, MX, SA | Manual (Seller): someone must act on each request in Seller Central | not enrolled | Unpaid label | Amazon |

What it means for the migration (coordinator assessment, 2026-10-30):
- Applies to seller-fulfilled (FBM) returns only; FBA returns are handled by Amazon end to end and are read through
  the FBA returns report / Finances API (see above).
- Amazon authorises the return, issues the RMA and (DE/FR/IT/ES) the prepaid label itself, so the direct integration
  needs no return-authorisation or label write. Manobo's part stays what it is today: goods arrive in Hamburg → return
  recorded in Manobo → refund via the adjustment feed (ADR 0138 rule, #5974). No decision in ADR 0128–0139 changes; no S1 item.
- Input to #6039 / Asana 1219920153544278 (BA): Manobo learns of an FBM return only when the parcel arrives, unless the
  BA wants return requests visible earlier. Unchecked: SP-API has seller-fulfilled returns reports
  (`GET_XML_RETURNS_DATA_BY_RETURN_DATE`), and Amazon charges the seller for prepaid labels; both to verify by a
  research ticket only if the BA asks for it. The outbound-shipping refund question stays with the BA.
- Manual (Seller) authorisation on CA/MX/SA is an operations duty in Seller Central today (CA 1 order and SA 0 in the last
  365 days, so negligible); the US and UK rows were not in the screenshot and matter more (US 109 orders in 30 days).

#### Return-settings terms and the SP-API surface for FBM returns (research 2026-10-30)

Verified by the coordinator on https://developer-docs.amazon.com/sp-api/docs/report-type-values-returns and
/notification-type-values (30 Oct): seller-fulfilled returns are **read-only reports**, `GET_XML_RETURNS_DATA_BY_RETURN_DATE`
and `GET_FLAT_FILE_RETURNS_DATA_BY_RETURN_DATE` (return request date, RMA ID, label details incl. `label_to_be_paid_by`,
`return_type`, ASIN, reason code; up to 60 days per report; roles "Inventory and Order Tracking" + "Direct to Consumer
Shipping (Restricted)"); FBA returns use `GET_FBA_FULFILLMENT_CUSTOMER_RETURNS_DATA`. No Returns API, no return feed and
no `*RETURN*` notification type for seller-fulfilled orders (External Fulfillment Returns API is a separate programme).

Worker-cited from Seller Central help (sellercentral.amazon.de G200828040, G202072200, G200708210, G201725690, en-DE;
not re-read by the coordinator):
- **In Policy (Amazon)**: Amazon authorises every in-policy request itself; out-of-policy and exempt-category requests
  still go to the seller for manual review within **24 hours** (what happens after a missed deadline: not verified).
  **Manual (Seller)**: the seller authorises every request.
- **Amazon Prepaid label**: Amazon issues the label; the cost is deducted from the seller account when the carrier
  first scans the parcel (DE carriers DHL, DPD, DHL Connect; buyer chooses). Buyer-fault returns: the seller deducts
  the label cost from the refund, or files a SAFE-T claim if Amazon already refunded. **Unpaid label**: label with the
  seller's address, buyer pays postage.
- **RMA = Amazon**: Amazon generates the RMA number (alternative: Seller); the buyer sees it on the RMA slip and the
  label; the seller gets it in the return e-mail and the returns report.
- **Exempt items**: Handmade, flowers, hazmat, heavy/bulky, non-returnable by law, and SKUs above EUR 500 exempted by
  the seller through an upload template (HIGH_PRICE). Their label is "Unpaid label" or "Seller Prepaid" (seller uploads
  a label within 2 days).
- The seller learns of a return by e-mail, on Manage Returns, and in the returns report.

Design consequence (coordinator, 30 Oct): no return write path exists or is needed in `Domain\AmazonSeller`; an
"expected returns" read would be one more report type on the report-pull path the FBA returns read already needs, only
if the BA asks for it (#6039). Label cost and buyer-fault deductions are amounts in the adjustment feed, i.e. BRD
questions on #6039, not architecture.

## Traps

### "Amazon's promotion and tax blocks carry money"

**Believed:** ADR 0131 as accepted on 2026-10-27 named `proceeds`, `promotion` and `tax` as the money to capture.
**True:** in Orders v2026-01-01 only `proceeds` holds amounts; `promotion` holds ids, `tax` a reporting scheme.
**Caught** by reading `orders_2026-01-01.json` on 2026-10-28; ADR 0131 was amended (`99c25d18de`) before merge.

### "Manobo does not keep promotion amounts"

**Believed** in the #5971 question and Doc A (.16420, .18130): Manobo stores `tax_amount = 0` and only converted
prices, so refunds lack the original amounts.
**True:** Manobo stores the item promotion per piece and the price after promotion. What it lacks is Amazon's tax
figure (`tax_amount` is Manobo's own calculation), and `tax_amount = 0` is rare on DE and normal on US. What Manobo
has never done is send refund money: a refund to ChannelAdvisor carries a quantity only.
**Caught** in the #5971 grilling (tax) and the ADR 0131 investigation of 2026-10-28 (promotions, quantity-only).

### "A refund cannot exceed the charged amount"

**Believed** during the ADR 0131 raw-money review (2026-10-28) as a reason to keep Amazon's own amounts.
**True:** Amazon's documentation has no such rule; only a Seller Forum error 18010 exists. ADR 0131 does not rest
on it — the table stays because only Amazon's numbers equal what the buyer paid.
**Caught** by the documentation check, 2026-10-28 (Doc A .66078).

### "FBA refunds are Amazon's alone, so the refund feed can be FBM-only"

**Believed** in the #5974 question and its round-1 recommendation (2026-10-29): a Manobo return on an FBA order can
only cause a double refund, so block it.
**True:** buyers send FBA goods to Hamburg about once a month (13 in 12 months); the Manobo return then triggers the
refund through ChannelAdvisor, often as the buyer's only refund, and no order was refunded twice (Finances API).
FBM-only would have stopped those refunds. ADR 0138 keeps the refund feed for both, behind an already-refunded check.
Manobo's own tables cannot show a double refund: the FBA pull drops a refund for an item already returned.
**Caught** by the replica and Finances check, 2026-10-29; decided by the coordinator ("keep today's model").

### "Returns refund the shipping cost to ChannelAdvisor"

The #5984 resolution lists `RefundShippingCostToChanneladvisorJob` as dispatched on return; in the listener that
dispatch is commented out (see ChannelAdvisor today above, checked in code 2026-10-28). Read the listener, not
the ticket, before designing the refund flow.

The FBA promotion import error (net discount stored as gross) is an import trap: [orders-import.md](orders-import.md#manobos-promotion-amounts-are-amazons-gross-discount).

## How to verify

**Refunds Amazon made on an order** (SP-API GET script in [verification.md](../verification.md#sp-api-read-only)):
`GET /finances/v0/orders/{amazonOrderId}/financialEvents?MaxResultsPerPage=100`: count
`payload.FinancialEvents.RefundEventList[]` and its `ShipmentItemAdjustmentList[]` (`PostedDate`, `SellerSKU`,
Principal); no buyer block. 0.5 rps: sleep 2 s between orders. Last OK 2026-10-29.

Returns per origin on the Nenalina channels (replica, 2026-10-29), the base for "is this refund already made":
`SELECT sp.use_external_warehouse, r.return_comment_customer, COUNT(*) FROM jng_sp_orders_items_return r JOIN
jng_sp_orders_items i USING (jng_sp_orders_items_id) JOIN jng_sp_orders o USING (jng_sp_orders_id) JOIN jng_sp sp ON
sp.jng_sp_id = o.jng_sp_id WHERE o.jng_sp_id IN (…20 ids…) AND r.return_time >= NOW() - INTERVAL 365 DAY GROUP BY 1, 2`.
`confirm_return = 1` on an internal return means CA accepted its Adjust.

## Open

Live state is in [open-state.md](../open-state.md); the lines that touch this flow:

- #6040 (refund flows, S2 gate) blocked by #6039 (returns opened on Amazon, shipping refund, FBA goods sent back to
  Hamburg; Asana 1219920153544278): [map](../open-state.md#map-tickets), [Asana](../open-state.md#asana-business-questions).
- Known-unfixed: `ProcessChannelAdvisorRefundOrdersAction` lookup without channel scope; the fulfilment check on
  `ProcessReturnB2cToChanneladvisorListener` during the overlap: [known-unfixed](../open-state.md#known-unfixed-no-issue-yet).
