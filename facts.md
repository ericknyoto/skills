# Facts

Production and system facts, each with its date and source. Counts expire: re-measure with `verification.md`
before quoting one. Decisions built on these live in `decisions.md`; wrong readings of them in `traps.md`.

## Seller accounts, app and tokens

- **Two seller accounts, one refresh token each:** Nenalina EU and Nenalina NA (config keys `nenalina_eu`,
  `nenalina_na` per #5969). The EU seller id is `A1SMSLS6YOBHD5`: listings calls for it answered 200 with the EU
  token (#5981, 2026-10-27). The NA seller id is not recorded. Julie & Grace EU is not authorised (Doc A .37271).
- **Production app** `Manobo-2008-Sellers` (`amzn1.sp.solution.b7e18360-050b-49b3-a42f-fe91e3a02b3a`): Private
  developer profile, so self-authorisation only; entity Seller; RDT delegation No. Roles: Finance and Accounting,
  Inventory and Order Tracking, Direct-to-Consumer Shipping (restricted), Amazon Fulfillment, Product Listing,
  Pricing, Seller Insights, Brand Analytics. **Not** Tax Invoicing, Tax Remittance, Buyer Communication, Buyer
  Solicitation (Solution Provider Portal, read 2026-10-27). Sandbox app: `Manobo-2008`.
- Sarina authorised both Nenalina accounts on 2026-10-27; the portal then showed 8 of 10 self-authorisations left.
- LWA client secrets (#5985, portal read 2026-10-30): `Manobo-2008-Sellers` rotated 2026-10-30 07:23Z, rotation
  deadline **2027-04-28 07:23Z**; sandbox `Manobo-2008` (the one in `.env`) deadline **2027-03-22 03:24Z**. The portal
  banner and the only expiration alert belong to an unused sandbox app `Manobo` (`amzn1.sp.solution.2185aaca-…`,
  deadline 2026-10-13, left unrotated by Erick; not in `.env` or any repo). Right after "Rotate secret", the
  credentials view still shows the OLD secret until the page is reloaded, and the confirmation message showed a
  different date (2027-03-23); trust the reloaded view. New secret verified 07:32Z (EU and NA 200). Amazon's page "Rotating your app's LWA credentials" (read 2026-10-30): rotate every 180 days; the old secret
  expires 7 days after the new one is generated; only the primary account user can rotate; notice 90 days ahead; past
  the deadline SP-API calls return an error (the page does not say "suppressed"). Rotation does not invalidate
  refresh tokens (Amazon SP-API support, 2026-09-24).
- **Env var names** (local `manobo-2008/.env` only; staging and production are filled by the S1 ticket that adds
  `config/amazon.php`, under the names it fixes: #5985, 30 Oct): `AMAZON_PROD_{APP_ID,CLIENT_ID,CLIENT_SECRET}`,
  `AMAZON_PROD_REFRESH_TOKEN_NENALINA_{EU,NA}`, `AMAZON_SANDBOX_{APP_ID,CLIENT_ID,CLIENT_SECRET,REFRESH_TOKEN}`. No
  code on master reads them (`git grep` on `b53a9b8971`, 2026-10-30).
  Planned override (#5972): `AMAZON_SELLER_READ_ENDPOINT_<ACCOUNT>=production`, reads only.
- Each token works only in its region; the other region answers 403 (marketplaceParticipations, 2026-10-27).

## Marketplace ids

`GET /sellers/v1/marketplaceParticipations` with both tokens, 2026-10-27, all `isParticipating` (Doc A .44674):

| Marketplace | marketplaceId | Token | FBM channel | FBA channel |
|---|---|---|---|---|
| Amazon.de | `A1PA6795UKMFR9` | EU | AN.DL 192 | AN.DB 195 |
| Amazon.fr | `A13V1IB3VIYZZH` | EU | AF.DL 196 | AN.FB 204 |
| Amazon.it | `APJ6JRA9NG5V4` | EU | AN.IL 197 | AN.IB 203 |
| Amazon.es | `A1RKKUPIHCS9HS` | EU | AN.EL 198 | AN.EB 205 |
| Amazon.nl | `A1805IZSGTT6HS` | EU | AN.NL 201 | AN.NI 231 |
| Amazon.com.be | `AMEN7PMS3EDWL` | EU | AN.BL 199 | AN.BE 229 |
| Amazon.pl | `A1C3SOZRARQ6R3` | EU | AN.PL 200 | AN.PO 232 |
| Amazon.se | `A2NODRKZP88ZB9` | EU | AN.SL 202 | AN.SE 233 |
| Amazon.co.uk | `A1F83G8C2ARO7P` | EU | — | AN.KB 206 |
| Amazon.com | `ATVPDKIKX0DER` | NA | — | AN.UB 207 |
| Amazon.ca | `A2EUQ1WTGCTBG2` | NA | — | AN.CB 208 |
| Amazon.com.mx | `A1AM78C64UM0Y8` | NA | — | AN.MB 209 |

Also participating, no channel: IE `A28R8C7NBKEWEA`, SA `A17E79C6D8DWNP`, AE `A2VIGQ35RCS4UG`, TR `A33AVAJ2PDY3EV`.
"Non-Amazon" multi-channel-fulfilment ids, unused: EU DE `A38D8NSA03LJTC`, FR `A1ZFFQZ3HTUKT9`, IT `A62U237T8HV6N`,
ES `AFQLKURYRPEL8`, UK `AZMDEXL2RVFNN`; NA US `A2ZV50J4W1RKNI`, CA `A1MQXOICRS2Z7M`, MX `A3H6HPSLHAK3XG`.

## Nenalina channels (production replica, 2026-10-28)

`jng_sp` plus `jng_sp_orders`; orders = `COUNT(DISTINCT order_id)`, windows end 2026-10-28.

| id | Code | Fulfilment | CA profile / site | split | Orders 365 d | 30 d | Last order |
|---|---|---|---|---|---|---|---|
| 192 | AN.DL | FBM | 12047680 / 642 | 0 | 1,220 | 22 | 2026-10-27 |
| 195 | AN.DB | FBA | 12047680 / 642 | 1 | 11,230 (11,965 rows) | 356 | 2026-10-27 |
| 196 | AF.DL | FBM | 12048120 / 643 | 0 | 61 | 0 | 2026-08-08 |
| 204 | AN.FB | FBA | 12048120 / 643 | 1 | 1,392 | 73 | 2026-10-27 |
| 197 | AN.IL | FBM | 12048121 / 645 | 0 | 48 | 2 | 2026-10-02 |
| 203 | AN.IB | FBA | 12048121 / 645 | 1 | 1,322 | 71 | 2026-10-27 |
| 198 | AN.EL | FBM | 12048116 / 683 | 0 | 39 | 0 | 2026-09-11 |
| 205 | AN.EB | FBA | 12048116 / 683 | 1 | 983 | 49 | 2026-10-26 |
| 201 | AN.NL | FBM | 12048124 / 1464 | 0 | 8 | 0 | 2026-09-05 |
| 231 | AN.NI | FBA | 12048124 / 1464 | 1 | 99 | 1 | 2026-10-04 |
| 199 | AN.BL | FBM | 12048115 / 2089 | 0 | 2 | 0 | 2026-01-14 |
| 229 | AN.BE | FBA | 12048115 / 2089 | 1 | 96 | 7 | 2026-10-20 |
| 200 | AN.PL | FBM | 12048122 / 1551 | 0 | 0 | 0 | never |
| 232 | AN.PO | FBA | 12048122 / 1551 | 1 | 53 | 3 | 2026-10-25 |
| 202 | AN.SL | FBM | 12048123 / 1535 | 0 | 0 | 0 | 2024-01-04 |
| 233 | AN.SE | FBA | 12048123 / 1535 | 1 | 0 | 0 | 2025-01-10 |
| 206 | AN.KB | FBA | 12048565 / 641 | 1 | 0 | 0 | 2024-03-10 |
| 207 | AN.UB | FBA | 12048566 / 640 | 0 | 1,248 | 62 | 2026-10-26 |
| 208 | AN.CB | FBA | 12048850 / 644 | 0 | 16 | 0 | 2026-09-07 |
| 209 | AN.MB | FBA | 12048855 / 692 | 0 | 2 | 0 | 2026-08-04 |
| 191 | AN.DT (test, closing) | FBM | 12046702 / 642 | 0 | 0 | 0 | 2023-07-20 |

- All 21 rows: `active_status = 1`, `ca_used = 1`, `tb_used = 0`, `type` NULL (2026-10-28). Each country's FBM and
  FBA channel share one CA profile and site; UK, US, CA and MX are single-channel profiles.
- `ca_stock_use_alternate_sku = 1` only on 192 AN.DL; `no_order_confirmation` = 1 on every FBA row, 0 on every FBM
  row (2026-10-28). `use_amvd_logistic` = 0 on all 20 (#5973, 2026-10-27). `jng_sp.currency` is EUR even on the PL,
  SE and US rows (#5980). `jng_sp.marketplace_id` points at Manobo's own `marketplaces` table (#5969).
- Neighbours outside scope: AM.US 53 (J&G US FBA) on CA profile 12043758; FBA-IN channels AN.IS 52, AN.UI 68,
  AN.UK 118 (`ca_used = 0`), which book FBA stock as pseudo-orders (AN.UK 118 last on 2026-07-08, 20,569 in
  total, memory 2026-10-27); row 48 AN.DS, the inactive 2021–2023 direct import.

## Julie & Grace channels (phase 2)

- The sheet's tab Seller JG marks 12 channels "Active, need to migrate": AM.DE (FBM: stock, price, orders,
  returns), AM.DF, AM.UF, AM.US (FBA: stock, price, orders, returns), and order-only AM.ES, AM.EF, AM.FR, AM.FF,
  AM.IT, AM.IF, AM.NL, AM.NF. AM.UK is inactive (sheet, read 2026-10-28).
- All run on Tradebyte (`tb_used = 1`, `ca_used = 0`) except AM.US 53 on ChannelAdvisor. Orders in 365 days
  (2026-10-28): AM.DF 7,661, AM.DE 757, AM.FF 581, AM.IF 399, AM.EF 341, AM.UF 56, AM.FR 22, AM.ES 22, AM.NF 20,
  AM.IT 12, AM.NL 5, AM.US 4, AM.UK 0. J&G listings (AM.MA) also go through Tradebyte (Doc A .10265).

## ChannelAdvisor today

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
- **Routing** is `(ca_profile_id, ca_channel_id, use_external_warehouse)` and ignores `ca_used` and
  `active_status`; no match or several → info log and the order stays unexported (#5970, 2026-10-27).
- The Exported flag is set only after a successful import; a failed order is served again on every run. FBA
  orders are imported only once SHIPPED, with `shipment_date` = order date (Doc A .28418; BA, .68082).
- `RecordOrderImportErrorAction` uses `insertOrIgnore` on (source, order number, error hash): an identical
  repeat adds no row. 4,804 CA downloads sat at `process_status = R` on 2026-10-27, most on Amazon profile tokens;
  they are re-dispatched only by accident (memory ca-order-reimport-stuck-raw).
- **Stock to CA:** no cron since 2023-07-09; event-driven `ExportStockToChanneladvisorJob` (15-minute delay, per
  product family) plus daily family exports 18:30 and 00:30 Berlin. It pushes to every CA profile, ungated per
  channel. Failures appear only in its log: 17 in October 2026, last on 2026-10-21 (#5984).
- **Write-backs:** shipment confirmation via scheduler `manobo:orders-confirmation` every 30 minutes; FBA refunds
  pulled by `manobo:daily-order-refund` at 03:00 tenant time (#5984). A refund to CA carries a quantity only:
  `ChanneladvisorOrderStatusService::setOrderItemAsAdjusted` posts `{quantity}` to `…/order/item/{id}/status/Adjust`
  and CA derives the money (ADR 0131 Context). `ProcessReturnB2cToChanneladvisorListener` sends only returns
  created in Manobo, and its shipping-cost refund dispatch is commented out "temporary disabled" (code, 2026-10-28).
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
- The CA carrier map `ChanneladvisorOrderService::getShipmentCarrier` sends CA names (`DP`, `Metapack - PostNord`,
  `Bpost`, …) that are not Amazon codes (#5982).

## Amazon orders that never reach Manobo

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
  243 error rows that channel 195 logged in the 30 days to 2026-10-28 (see SKU rules).
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

## SKU rules

- **Real SKU** = `product_skus.sku` = product code (`products_model`) + `_` + size, no suffix when sizeless
  (`ProductSkuService::generate`), e.g. `0101113122_55`.
- **FBA listing = real SKU; FBM listing = real SKU + `-FBM`** (BA, 2026-10-28). Amazon.de agrees for ASIN
  B08Z7R2YCC (getListingsItem 2026-10-28): `0402620921` AMAZON_EU, our_price 29.40, FBA fulfillable 4;
  `0402620921-FBM` DEFAULT qty 1, our_price 29.50; both list_price 39.90, product type CHARM.
- `-FBM` is data, never generated: alternate SKUs per channel in `jng_sp_sku`. 23,946 rows end in `-FBM`; 21,067
  are exactly real SKU + `-FBM`; the rest use the old dash format, e.g. `335108-019-FBM` (#5978, 2026-10-28).
- **Import lookup:** `product_skus` first, then `jng_sp_sku` for the order's own channel
  (`ChanneladvisorCacheService::getObjectProductArticleBySku` → `ProductArticle::loadObjectFromSKUExternal`).
- **`-L` exception** (`order_import_errors`, CA source, last 30 days, 2026-10-28): channel 195 has 243 "Product not
  found for SKU" rows over 138 distinct SKUs, all ending in `-L` (`726099-046-L`, `0101371222_55-L`), none in
  `-FBM`; 90 of the 138 match a real SKU once `-L` is stripped. On 2026-10-28 `-L` alternate SKUs existed only on
  FBA-IN channels 52, 68 and 118. By 2026-10-30, 195, 203, 204 and 205 held 486 `-L` rows each. Each points at the same product and
  article as `product_skus` for the stripped SKU on 288 of 288 rows where that SKU exists; 198 have no
  `product_skus` row. Channels 203, 204, 205 and 207 show the same (39, 28, 45, 17 SKUs, all `-L`), and 229, 231 and
  232 one `-L` SKU each. Example orders on 195:
  `028-1496294-5276357` (`335109-021-L`), `028-3014188-7621138` (`712712-019-L`). So FBA listings carry at least
  three styles: real, real + `-L`, old dash format.
- `S` + mother product code (e.g. `S0402620921`) is the CA family parent built by
  `ChanneladvisorExportProductFamilyService`; Amazon does not know it (404, search 0 results, 2026-10-28).
- Amazon.de holds 4,714 Nenalina listings (searchListingsItems `numberOfResults`, 2026-10-27). Anja uploads new
  products to Amazon by hand and copies the ASIN into Manobo; products are never uploaded via Manobo (sheet).

## Order money in Manobo

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

## Amazon API

- **Orders v0** deprecated 2026-01-28; its read operations are removed 2027-03-27. `confirmShipment`
  (`POST /orders/v0/orders/{orderId}/shipmentConfirmation`, 2 rps, burst 10; requires `packageReferenceId`,
  `carrierCode`, `trackingNumber`, `shipDate`, `orderItems`) is not deprecated and has no v2026 equivalent
  (Doc A .3057; #5982).
- **searchOrders v2026-01-01:** 0.0056 rps, burst 20 (model; header seen 2026-10-27). `includedData` ∈ BUYER,
  RECIPIENT, PROCEEDS, EXPENSE, PROMOTION, CANCELLATION, FULFILLMENT, PACKAGES, TAX, PAYMENT, FULFILLMENT_ORDERS.
  Without FULFILLMENT the `fulfillment` block (`fulfilledBy`, status) is absent. `salesChannel.marketplaceId` and
  `fulfillment.fulfilledBy` are order-level. One call takes all 13 EU marketplace ids (2026-10-27).
  Filters (model `3677bb9d96`, 2026-10-30): `createdAfter` or `lastUpdatedAfter` families (not mixed), `fulfillmentStatuses`
  (7 values), `fulfilledBy` MERCHANT/AMAZON, up to 50 `marketplaceIds`, `maxResultsPerPage` 1–100; next pages resend every
  parameter but `maxResultsPerPage`/`includedData`; stop on a missing token, not a short page. Items come inline
  (`orderItemId`, `quantityOrdered`, `product.sellerSku`). `fulfillment.fulfillmentStatus` is the only status. **Without
  BUYER/RECIPIENT, FBM orders still return `giftMessage` (via FULFILLMENT) and `customizedUrl` (ungated)**; FBA orders
  neither (#5976). IE, SA, AE, TR: 0 orders in 365 days; NA 30 days: US 109, CA 1, MX 0, all FBA (2026-10-30).
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
- **FBA ship time is not available over GET:**
  - v2026 `packages` exist for MFN only.
  - Finances `ShipmentEvent.PostedDate` comes about 9 days after `createdTime` on DE (median 221 h).
    Assumption: this is the delivery + 7 days deferral.
  - `lastUpdatedTime` moves after shipment (on 9 of 243 orders it is later than the Manobo import).
  - Source: #5976 diff, 2026-10-30.
- **FBM `orderAliases[SELLER_ORDER_ID]` = the ChannelAdvisor order id** (= `jng_sp_orders.order_id_external`) on
  11 of 11 imported DE FBM orders. FBA aliases equal the Amazon id. Key on `orderId` (2026-10-30).
- **FBA buyer data with our roles:** AFN orders carry no buyer block, and `recipient.deliveryAddress` holds only
  city, postal code and country (sometimes region): 96 of 96 DE FBA orders, 2026-10-27; v0 `getOrderAddress` Name
  is empty. MFN orders are complete. Through CA, AN.DB has full addresses today (370 of 370 orders in 30 days),
  with Amazon relay emails and placeholder phones (Doc A .27600, .44046; example `303-6456306-1725135`).
- **Feeds:** cancel = `POST_ORDER_ACKNOWLEDGEMENT_DATA`; refund = `POST_PAYMENT_ADJUSTMENT_DATA` (AdjustedItem →
  ItemPriceAdjustments components Principal, Shipping, Tax, …), not deduplicated by Amazon (ADR 0129). The legacy
  inventory and price feeds were removed 2025-12-03; FBM quantity and price go through `patchListingsItem` or
  `JSON_LISTINGS_FEED` (Doc A .3057).
- No documented rule caps a refund at the charged amount; only Seller Forum error 18010 "refund amount for the item
  price is too high" (docs check, 2026-10-28).
- **Finances API** (`listFinancialEventsByOrderId` v0, `listTransactions` 2024-06-19) returns per-item Principal,
  Tax, Shipping and Promotion of a shipped order on demand: up to 48 h lag, 0.5 rps, needs Finance and Accounting
  (held), retention undocumented (ADR 0131). FBA refunds are not in the Orders API: Reports
  `GET_FBA_FULFILLMENT_CUSTOMER_RETURNS_DATA` or Finances (Doc A .5422).
- **Listings, Amazon.de** (#5981, 2026-10-27): product types NECKLACE, RING, BRACELET (CHARM seen 2026-10-28), not
  JEWELRY; all share version `…PcHMd1` and identical price and stock subschemas. `list_price` =
  `[{currency, value_with_tax, marketplace_id}]`, no schedule, required on non-parent listings. `purchasable_offer`
  has one entry per (marketplace, currency, audience `ALL`): `our_price[].schedule[]` = `{value_with_tax}` only;
  `discounted_price[].schedule[]` needs `start_at`, `end_at`, `value_with_tax` and an `our_price` beside it.
  `fulfillment_availability`: `AMAZON_EU` or `DEFAULT`; DEFAULT takes exactly one of `quantity` and
  `is_inventory_available`, optionally `lead_time_to_ship_max_days` (0–30), and makes `merchant_shipping_group`
  required.
- Live examples: FBA `0101141222_55` (NECKLACE) list 74.90, our 65.40, discounted 55.90 from
  2026-10-22T22:00Z to 2026-11-28T23:00Z (Berlin midnights), availability AMAZON_EU + out-of-enum `AMAZON_UK_RAFN`
  + DEFAULT qty 150; FBM `0608672622_60-FBM` (RING) list 63.00, our 55.50, DEFAULT qty 2, lead time 1 (#5981).
  `0402620921` also lists `AMAZON_DE_TBYB` and an offer for audience B2B (2026-10-28).
- Listings also carry `uvp_list_price`: 33.53 on `0402620921` beside `list_price` 39.90 (39.90 / 1.19 = 33.53).
  Assumption: it is the sheet's "List price (RRP EUR net)"; the schema was not read for it.
- **Carrier codes:** `carrierCode` comes from the `amzn-base.xsd` `CarrierCode` list (Last-Modified 2026-07-09):
  present DHL, DHL Express, DHL-Paket, Deutsche Post, PostNord, Seven Senders, BPOST, Colissimo, Swiss post, Poste
  Italiane, PostNL, Royal Mail, DPD; absent Metapack and Austrian Post. `Other` requires `carrierName` and Amazon
  cannot track it (#5982).
- getInventorySummaries returns 50 SKUs per page with `nextToken` (2026-10-27).
- **Rate limits** (rps / burst, per account-application pair; Usage Plan tables in `github.com/amzn/selling-partner-api-models`,
  read 2026-10-30; the `x-amzn-RateLimit-Limit` header can apply other values): getOrder v2026 and v0 0.5/30;
  getOrderItems v0 0.5/30; createFeed 0.0083/15; getFeed 2/15; createFeedDocument 0.5/15; getFeedDocument 0.0222/10;
  getListingsItem 5/10; patchListingsItem 5/**5**; putListingsItem 5/10; getInventorySummaries 2/2;
  listFinancialEventsByOrderId v0 0.5/30; listTransactions 2024-06-19 0.5/10; createReport 0.0167/15; getReport 2/15;
  getReportDocument 0.0167/15 (searchOrders and confirmShipment above).
- **Notifications API** delivers only to an SQS queue or an EventBridge bus in our own AWS account; no webhook. ORDER_CHANGE,
  FEED_PROCESSING_FINISHED and REPORT_PROCESSING_FINISHED all need one, so every flow polls (2026-10-30; #5977).

## Refund feed on FBA orders (documentation research, 2026-10-29)

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

## Populations

- **PII:** retention is off on all 238 channels and `pii_redaction_logs` is empty; the 20 Nenalina channels hold
  70,793 orders shipped more than 30 days ago that still carry PII (FBM 6,380, FBA 64,413, oldest mid-2023)
  (#5975, 2026-10-27). `config/sentry.php` has `breadcrumbs.sql_bindings => true` (master, 2026-10-28).
- **Personalisation:** 0 of 18,695 Amazon Nenalina orders in 12 months; only CA PrivateNotes on 1,318 FBM orders,
  one constant string (#5983, 2026-10-27).
- **Load:** CA retail for Nenalina averages 27 orders a day, peak 44; returns 613 rows per 90 days (AN.DB 358,
  AN.UB 90) (Doc A .2855, .11301, measured 2026-10-20).
- **SKUs per fulfilment channel:** `jng_sp_sku` holds 3,730 distinct SKUs on the 9 FBM channels (29,576 rows) and 2,126 on
  the 12 FBA channels (15,285 rows) (replica, 2026-10-30; #5977).
- **Failure records today** (replica, 2026-10-30; #5977): `order_import_errors` open rows: ChannelAdvisor 1,638 (566 in 30
  days), MS Direct 1,156, Tradebyte 5,490, all reported (resolved rows are deleted after the push);
  `channeladvisor_order_ship_failures` 0 rows; `order_status_update_rejections` 133 MS Direct rows open; production
  `failed_jobs` 2,923 rows in 30 days. Horizon's LongWaitDetected mail (it.team@julie-grace.com) covers only queue
  `general`; job exceptions reach Sentry as handled warnings.

## Code anchors

Accurate on 2026-10-28: manobo-2008 master `74b6517496`, manobo-service-api `edd3b67`. `Manobo2/Domain/AmazonSeller`
and `config/amazon.php` do not exist yet.

| What | Where |
|---|---|
| CA order download and routing | `Manobo2/Domain/Shared/ChanneladvisorExchange/Service/ChanneladvisorDownloadOrderService.php::downloadNewOrders` |
| CA order import, shipment ids, carrier map | `…/ChanneladvisorExchange/Service/ChanneladvisorOrderService.php` (`generateShipmentId`, `generateShipmentIdForSplitQuantity`, `getShipmentCarrier`) |
| CA refund / cancel (quantity only) | `…/ChanneladvisorExchange/Service/ChanneladvisorOrderStatusService.php::setOrderItemAsAdjusted` |
| Returns to CA, shipping refund (off) | `Manobo2/Domain/SalesOrder/Channeladvisor/Listener/ProcessReturnB2cToChanneladvisorListener.php` |
| SKU lookup | `…/ChanneladvisorExchange/Service/ChanneladvisorCacheService.php::getObjectProductArticleBySku` |
| Real SKU | `Manobo2/Services/ProductSkuService.php::generate` |
| CA family parent `S…` | `…/ChanneladvisorExchange/Service/ChanneladvisorExportProductFamilyService.php` |
| Item promotions / tax | `Manobo2/Domain/SalesOrder/Channeladvisor/Action/SavePromotionsItemLevelAction.php`, `Manobo2/Domain/Order/Action/UpdateTaxAmountAction.php` |
| Import error ledger | `Manobo2/Domain/SalesOrder/Action/RecordOrderImportErrorAction.php` |
| `ca_used`/`tb_used` derived on save | `Manobo2/Domain/Shared/SalesChannel/Action/SaveSalesChannelDetailAction.php` |
| FBA refund pull | `Manobo2/Domain/ChannelAdvisor/Command/OrderRefundFromSalesChanneladvisorFbaCommand.php` |
| Currency conversion | `helpers/functions-2.php` (`convertCurrency`), `cron/daily-exchange-rate.php` |
| CA new-order read (service-api) | `app/Manobo/Service/Impl/v3/ChanneladvisorOrderApiService.php::getNewOrders` |

## Prices per sales channel (verified 2026-10-29, code + replica)

- The sales-channel price page (`modules/products-pricing/controller.php:391-411` → `SalesChannelCatalogPriceService::savePrices`)
  writes `sales_channel_catalog_prices` (one row per `jng_sp_catalog_id`). The price columns of `jng_sp_catalog` itself
  (`price`, `price_uvp`, `price_new`, `price_foreign*`) are **zero on every ChannelAdvisor Amazon channel**: do not read them.
- Columns: `price_uvp`, `price_retail`, `price_retail_promotion` + `promotion_date_start/end`, `price_selling*`, each with a
  `_foreign` twin in the channel's country currency (`countries.currency` via `jng_sp.countries_iso_code_2`: 206 GB→GBP,
  207 US→USD, 208 CA→CAD, 209 MX→MXN, 200/232 PLN, 202/233 SEK; `jng_sp.currency` is EUR everywhere and is not the
  effective currency). A blank foreign value is derived from EUR with the `exchange-rate` app_config value (EUR→GBP 0.837037,
  EUR→USD 1.112038 on 2026-10-28) plus pretty-price rounding (`PriceService.php:394-420`); foreign UVP comes from
  `product_uvp_countries` (`ProductUvpService.php:119-160`).
- Population (replica 2026-10-29): 192 AN.DL 1,548 products with EUR UVP + retail; 195 AN.DB 1,455; 206 AN.KB 74 with GBP
  foreign values; 207 AN.UB 5 with USD; 0 promotion prices/dates on all four.
- ChannelAdvisor receives from this table only RRP + SellingPrice on save (`ProductPriceEventSubscriber.php:39-50` →
  `UpdateProductPriceAction.php:23-30`, PUT `v3/integrator/channeladvisor/product/price`; `ChanneladvisorWrapperService.php:980-1016`);
  SellingPrice = running promotion price else retail. Promo dates go only through the family export, whose
  `profile-id-for-upload` list (8 profiles) excludes the DE/UK/US profiles 12047680, 12048565, 12048566.
- BA mapping (Asana 1219919849429744, 28 Oct): Amazon `list_price` ← UVP; `our_price` ← Normal Price → Retail Price;
  `discounted_price` ← Promotion Price → Retail Price + dates. Open: FBM = FBA price (separate rows today), `_foreign` columns
  for UK/US (asked 29 Oct). Not verified: how Rithum maps RRP/SellingPrice to Amazon fields; whether the PUTs succeed.

## Seller Central return settings, FBM orders (screenshot from Erick, 2026-10-30)

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

### Return-settings terms and the SP-API surface for FBM returns (research 2026-10-30)

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
