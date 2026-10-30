# Orders import

The Amazon order stream and how an order is routed (ADR 0130), SKU resolution on import, order money and currency
in Manobo (#5980), Amazon orders that never reach Manobo, and the ChannelAdvisor import as it runs today. The
`shipment_id` scheme and the raw item money table are ADR 0131, kept with the refunds that need them:
[cancel-and-refund.md](cancel-and-refund.md#adr-0131-shipment-id-and-raw-item-money). Channel ids and routing keys:
[channels-and-routing.md](channels-and-routing.md); SKU formats and the `-L` SKUs: [prices-and-listings.md](prices-and-listings.md#sku-formats);
FBM/FBA per flow: [ADR 0138](cancel-and-refund.md#adr-0138-flows-per-fulfilment-channel); code anchors: [sources/github.md](../sources/github.md#code-anchors).

## Decisions

### ADR 0130 one order stream per seller account

One searchOrders stream per seller account over all its marketplaces in config; route by (`amazon_seller_account`,
`amazon_marketplace_id`, `use_external_warehouse` 1 = FBA / 0 = FBM) under a UNIQUE index; unrouted orders go to the
failure table, never skipped silently; one `lastUpdatedAfter` watermark per account, resumable pages, 90-minute run
lock; ≥ 3 minutes between runs.
- **Status:** Accepted 2026-10-27 (delegated); PR #5992 merged 2026-10-27 06:39Z (`7447372323`)
- **Where:** #5969 c6435347742; Doc A .47814

### 5980 currency from the order and missing rates

Recommendation: order mapping holds an order when a rate is missing or ≤ 0, and takes the currency from the Amazon
order, never `jng_sp.currency`.
- **Who, when:** research agent, checked by Erick, 2026-10-27
- **Where:** #5980; `research/currency-pairs`; Doc A .40608

### FBA orders enter only once shipped

FBA orders enter Manobo only once SHIPPED, as with ChannelAdvisor; no new rule.
- **Who, when:** the BA, 2026-10-28; Asana task due 2026-11-20, completed 28 Oct (Erick: answered and locked)
- **Where:** Asana 1219920153544152 (05:27Z); Doc A .68082; map #5967

### UK orders are imported

UK: import the orders, keep a UK channel. How Finance and Warehouse handle UK orders stays open ([open-state](../open-state.md#asana-business-questions)).
- **Who, when:** the BA, 2026-10-28
- **Where:** Asana 1219921642535113 (07:18Z); Doc A .70555

### 5991 UK orders ticket closed as import

#5991 (UK orders) closed as "import" by the scope decision.
- **Who, when:** map session, 2026-10-28
- **Where:** #5991 c6460009177

### 5970 no ticket for the ChannelAdvisor DE leak

No separate operational ticket for today's ChannelAdvisor DE import leak ("Tunggu migrasi"); its numbers feed #5978
and #5976; the service-api `nextLink` gap stays a follow-up candidate, unticketed. Do not re-raise unless asked.
- **Who, when:** Erick, 2026-10-28
- **Where:** #5970 c6462113723; Doc A .68504

## Facts

### The Amazon order stream

- **searchOrders v2026-01-01:** 0.0056 rps, burst 20 (model; header seen 2026-10-27). `includedData` ∈ BUYER,
  RECIPIENT, PROCEEDS, EXPENSE, PROMOTION, CANCELLATION, FULFILLMENT, PACKAGES, TAX, PAYMENT, FULFILLMENT_ORDERS.
  Without FULFILLMENT the `fulfillment` block (`fulfilledBy`, status) is absent. `salesChannel.marketplaceId` and
  `fulfillment.fulfilledBy` are order-level. One call takes all 13 EU marketplace ids (2026-10-27).
  Filters (model `3677bb9d96`, 2026-10-30): `createdAfter` or `lastUpdatedAfter` families (not mixed), `fulfillmentStatuses`
  (7 values), `fulfilledBy` MERCHANT/AMAZON, up to 50 `marketplaceIds`, `maxResultsPerPage` 1–100; next pages resend every
  parameter but `maxResultsPerPage`/`includedData`; stop on a missing token, not a short page. Items come inline
  (`orderItemId`, `quantityOrdered`, `product.sellerSku`). `fulfillment.fulfillmentStatus` is the only status. What FBM
  orders still return without BUYER/RECIPIENT: [data-protection.md](data-protection.md#pii-in-amazon-order-data).
  IE, SA, AE, TR: 0 orders in 365 days; NA 30 days: US 109, CA 1, MX 0, all FBA (2026-10-30).
- **FBM `orderAliases[SELLER_ORDER_ID]` = the ChannelAdvisor order id** (= `jng_sp_orders.order_id_external`) on
  11 of 11 imported DE FBM orders. FBA aliases equal the Amazon id. Key on `orderId` (2026-10-30).
- **FBA ship time is not available over GET:**
  - v2026 `packages` exist for MFN only.
  - Finances `ShipmentEvent.PostedDate` comes about 9 days after `createdTime` on DE (median 221 h).
    Assumption: this is the delivery + 7 days deferral.
  - `lastUpdatedTime` moves after shipment (on 9 of 243 orders it is later than the Manobo import).
  - Source: #5976 diff, 2026-10-30.
- FBA buyer data with our roles (no buyer block on AFN orders): [data-protection.md](data-protection.md#pii-in-amazon-order-data).

### Order money

- What Amazon's `proceeds` hold, their signs and VAT, and what the buyer paid: [cancel-and-refund.md](cancel-and-refund.md#order-money-on-amazon).
- Per CA-imported Amazon item Manobo keeps the unit price (`price`, `price_selling`, `price_selling_foreign` and
  currency), the promotion per piece in `jng_sp_orders_item_services` (`SavePromotionsItemLevelAction`),
  `price_selling_after_service`, and the order's shipping total. `tax_amount` is Manobo's own computation
  (`UpdateTaxAmountAction`); CA's `TaxPrice` is never read. Order `302-2119838-0613968` (DE FBM, EUR): 89.50 −
  13.43 = 76.07; Manobo tax 12.14 against 12.15 from 76.07 × 19/119 (ADR 0131 Context, verified 2026-10-28).
- `tax_amount = 0` in the 3 months to 2026-10-27: 5 of 1,414 AN.DB rows, 0 of 69 AN.DL rows; always 0 on US (#5971).
- In 12 months, all 17,846 Nenalina `order_id` values are 19-character Amazon ids without suffix; at most 15
  items and 15 units per order; none of 5,454,266 `shipment_id` values ends in `AZ` (#5971, 2026-10-27).
- `order_id` repeats across seller accounts: 13 Amazon order ids sit in both AM.DF (58) and AN.DB (195), 12 months
  (#5971).
- **Currency:** a channel's currency comes from `countries.currency` of its country, never `jng_sp.currency`;
  the CA import converts from the order's own `Currency`; `convertCurrency` returns 0 on a missing pair (#5980).
- **Rates:** `app_config` key `exchange-rate`, replaced whole each day by host cron `cron/daily-exchange-rate.php`
  from apilayer; a failed base silently drops its pairs and the failure email cannot fire (#5980). 2026-10-26: 756
  pairs, none zero, EUR↔USD/PLN/SEK present. 2026-10-28: 757 pairs (refreshed 2026-10-27 09:05), `GBP2EUR`
  1.194085, `MXN2EUR` 0.0482, `CAD2EUR` 0.63914 present.
- The Finances API fallback for money of orders imported before capture: [cancel-and-refund.md](cancel-and-refund.md#amazon-cancel-and-refund-feeds).

### SKU resolution on import

- **Import lookup:** `product_skus` first, then `jng_sp_sku` for the order's own channel
  (`ChanneladvisorCacheService::getObjectProductArticleBySku` → `ProductArticle::loadObjectFromSKUExternal`).
- The SKU styles the lookup must cover (real, `-FBM`, `-L`, old dash format): [prices-and-listings.md](prices-and-listings.md#sku-formats).

### Amazon orders that never reach Manobo

searchOrders v2026, orders created since 2026-09-27 06:18Z, matched on `jng_sp_orders.order_id`, misses looked
up in `order_import_errors` (#5969 probe 2026-10-27; table on #5978):

| Marketplace, fulfilment | Shipped on Amazon | In Manobo | Missing | "Product not found for SKU" | Other import error | No trace |
|---|---|---|---|---|---|---|
| DE FBA | 573 | 354 (+1 under AM.DF) | 218 | 201 | 10 | 7 |
| ES FBA | 84 | 52 | 32 | 7 | 25 | 0 |
| US FBA | 88 | 64 | 24 | 24 | 0 | 0 |
| IT FBA | 86 | 69 | 17 | 15 | 1 | 1 |
| FR FBA | 83 | 69 | 14 | 8 | 4 | 2 |
| PL FBA | 3 | 1 | 2 | 1 | 0 | 1 |
| DE FBM | 20 | 20 | 0 | – | – | – |
| UK FBA | 129 (+4 cancelled, 2 pending) | 0 | 129 | 0 | 0 | 129 |

- "Other import error" is always "Name / Billing Address / Shipping Address / Shipping City contains unknown
  characters". Cancelled and pending orders never enter Manobo by design, so they are left out.
- The often-quoted **211** is the DE missing orders with an unresolved CA import error (201 + 10). It is not the
  243 error rows that channel 195 logged in the 30 days to 2026-10-28 (see [SKU formats](prices-and-listings.md#sku-formats)).
- UK: AN.KB's last order is 2024-03-10 (859 orders, December 2023 – March 2024). UK is the second-largest
  Nenalina EU marketplace in the window.
- Unexplained: DE FBA order `028-5344066-8747504` (Nenalina EU) sits under J&G channel AM.DF (58) with two rows
  and a midnight order date.
- **DE after the 2026-10-28 re-dispatch** (manual diff for #5976, 2026-10-30; window created 2026-10-14 to
  2026-10-28Z):
  - FBA: 243 of 245 shipped orders are in 195, and 2 are missing (`-L` SKUs still unmapped, downloads still `R`).
    FBM: 9 of 9. Extras: 0.
  - The cause: on 2026-10-28 between 19:40 and 19:50 Berlin, 108 stuck `R` downloads went to `I`, and 195, 203, 204
    and 205 now hold 486 `-L` rows each in `jng_sp_sku` (replica recount 2026-10-30; Erick confirmed on 2026-10-30 that his team
    made the change: a manual fix, not an automated process). 79 of the 243 orders came in that batch, so 81 had been missing before
    it.
  - 2 further orders were imported with the `-L` item silently dropped: error status "Imported" plus "Product not
    found for SKU".
  - Note: `w2-de-dry-diff` in `~/.config/Claude/side-session-notes/local_0f6cedbf-c406-4622-afe2-5b8dae0215c5/`.

### ChannelAdvisor import today

- **Order download:** host crontab `*/10 * * * *` (Europe/Berlin), `cron/job-producer-download-orders-from-integrator.php`,
  one `DownloadOrdersFromChanneladvisorJob` per CA profile on `high-priority`: 23 profiles, 13 Nenalina. The same
  line dispatches Tradebyte. The job has `tries = 1` and is not `ShouldBeUnique` (#5984, 2026-10-27).
- **One page only:** `manobo-service-api` `ChanneladvisorOrderApiService::getNewOrders` reads
  `v1/Orders?exported=false` once and never follows `@odata.nextLink` (code at service-api `edd3b67`, read
  2026-10-28). The DE profile 12047680 returned exactly 100 unexported orders on every sampled run (2026-10-13,
  -20, -26, -27), all FBA, the set turning over; Stilnest 90–93, US 83–85, ES 64–65 were near full (#5970).
- **What the import keeps** (code, master `238de6e6d8`, #5976): row creation time = `jng_sp_orders.import_date` (Berlin,
  no `created_at`); the seller SKU is never stored (only Manobo's `article_number`); `article_reference_number` holds CA's
  item id; on split channels every unit row repeats the order's `order_price_vk` and `shipping_costs` (code reading).
- How the download routes an order to a channel: [channels-and-routing.md](channels-and-routing.md#channeladvisor-routing-today).
- The Exported flag is set only after a successful import; a failed order is served again on every run. FBA
  orders are imported only once SHIPPED, with `shipment_date` = order date (Doc A .28418; BA, .68082).
- `RecordOrderImportErrorAction` uses `insertOrIgnore` on (source, order number, error hash): an identical
  repeat adds no row. 4,804 CA downloads sat at `process_status = R` on 2026-10-27, most on Amazon profile tokens;
  they are re-dispatched only by accident (memory ca-order-reimport-stuck-raw).

## Traps

### "The UK channel is dead"

**Believed:** Doc A (2026-10-20) crossed UK out because AN.KB had no order since 2024-03-10; the Sales documents
said "I think turned off".
**True:** Amazon UK ships about 129 FBA orders per 30 days on the Nenalina EU account, and none reach Manobo or
`order_import_errors`. The flow stopped on the ChannelAdvisor side; Manobo just never saw it.
**Caught** by the #5969 routing probe, 2026-10-27. **Manobo's order table is no evidence of what Amazon sells —
count with searchOrders before calling a marketplace dead.**

### "Amazon has orders Manobo lacks, so the import is broken"

**Partly wrong.** FBA orders reach Manobo only once SHIPPED, by design (ChannelAdvisor today, confirmed by the BA).
Pending, Unshipped and Cancelled orders are absent on purpose. **Compare SHIPPED orders only.** The largest real
gaps were DE FBA (218 of 573 shipped orders missing on 2026-10-27, mostly unmapped `-L` SKUs) and all of UK.
After the `-L` mapping and the re-dispatch on 2026-10-28, DE FBA is missing 2 of 245 (see the facts above). FBM arrives at
UNSHIPPED. An order-level presence check misses **partial imports**: an "Imported" error row with "Product not
found for SKU" means that item was dropped.

Money traps that matter for refunds (Amazon's `promotion` and `tax` blocks; "Manobo does not keep promotion amounts")
are in [cancel-and-refund.md](cancel-and-refund.md#traps).

### "Manobo's promotion amounts are Amazon's gross discount"

**Believed** from the FBM example `302-2119838-0613968` (13.43 = 11.29 × 1.19).
**True** only for FBM. On FBA orders (item promotions `PLM-…`, from 2026-10-27) the `voucher` row holds Amazon's
**net** discount, and Manobo applies it as gross. `price_selling_after_service` is then too high by the VAT share
of the discount (12 window orders, up to 9.14 EUR). On 3 or more orders that carry both a shipping and an item
discount, only the `free-shipping` row is stored and the item discount is lost (up to 20.16 EUR).
**Caught** by the #5976 diff, 2026-10-30. Compare money as `ITEM − DISCOUNT + TAX` from `proceeds`, never `ITEM`
alone, which is net.

### "Finances PostedDate is the FBA ship time"

It is not on DE: median 221 h after `createdTime`, and absent for the newest orders. Assumption: delivery + 7
days reserve. Caught in the #5976 diff, 2026-10-30. No GET call gives an FBA ship time; the shipment report needs
a `createReport` POST.

### "order_id identifies one Amazon order"

Not across seller accounts (13 ids sit in both AM.DF and AN.DB), and not as one row: split channels hold one row
per unit. Scope matching to one seller account and count `DISTINCT order_id`.

### "searchOrders returns fulfilment data"

Not without `includedData=FULFILLMENT`; the block is simply absent (smoke test, 2026-10-27).

## How to verify

SQL through the replica wrapper, SP-API through the GET script: [verification.md](../verification.md).

**Is an Amazon order in Manobo?** `SELECT jng_sp_id, shipment_id, order_date FROM jng_sp_orders WHERE order_id IN
('…')` — then check the `jng_sp_id` belongs to the right seller account (`order_id` repeats across accounts).
If absent: `SELECT order_number, created_at, resolved_at, JSON_EXTRACT(payload,'$.errors') FROM
order_import_errors WHERE source = 'channeladvisor' AND order_number IN ('…')`.

**ChannelAdvisor SKU errors per channel** (the `-L` counts): [prices-and-listings.md](prices-and-listings.md#how-to-verify).

**Exchange-rate pairs** (add any pair the same way):

```sql
SELECT updated_at, JSON_LENGTH(value), JSON_EXTRACT(value,'$.USD2EUR'), JSON_EXTRACT(value,'$.GBP2EUR'),
       JSON_EXTRACT(value,'$.MXN2EUR'), JSON_EXTRACT(value,'$.CAD2EUR')
FROM app_config WHERE `key` = 'exchange-rate';
```

**Orders, counts only:** `GET /orders/2026-01-01/orders?marketplaceIds={13 ids}&createdAfter=…&includedData=FULFILLMENT`;
each next page sends `paginationToken` **plus the original `createdAfter`**, else 400. Last OK 2026-10-27. A 30-day
EU pull took 13 pages.

## Open

Live state is in [open-state.md](../open-state.md); the lines that touch this flow:

- Unticketed on the map: order mapping v2026 (waits for #5988), updates to an already imported order, the re-import
  trigger for an Amazon order whose import failed, how Finance and Warehouse handle UK orders: [map](../open-state.md#map-tickets).
- The S1 spec #6062 leaves the order pull and the `shipment_id` scheme out: [S1 spec](../open-state.md#s1-spec-6062).
- Known-unfixed: the CA FBA promotion import, the exchange-rate cron, the AM.DF order and the stuck `R` downloads:
  [known-unfixed](../open-state.md#known-unfixed-no-issue-yet).
