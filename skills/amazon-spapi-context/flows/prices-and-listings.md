# Prices and listings

Seller SKU formats and the SKU mapping (#5978, #5986), listing ownership, the listings on Amazon (product types,
`list_price`, `purchasable_offer`, `fulfillment_availability`), prices per sales channel and the UVP/selling/promo
fields (#6012, #6013), and personalisation (#5983). The price push serves FBM and FBA:
[ADR 0138](cancel-and-refund.md#adr-0138-flows-per-fulfilment-channel). How the order import looks a SKU up:
[orders-import.md](orders-import.md#sku-resolution-on-import). Code anchors: [sources/github.md](../sources/github.md#code-anchors).

## Decisions

### 5981 product types and price writes

Product types are NECKLACE/RING/BRACELET, not JEWELRY; a price write sends the listing's own `productType`;
`list_price` has no schedule.
- **Who, when:** research agent, checked by Erick, 2026-10-27
- **Where:** #5981; `research/jewelry-list-price`; Doc A .39998

### 5983 personalisation out of P1 scope

Personalisation stays out of the P1 order-mapping scope (none in production).
- **Who, when:** research agent, checked by Erick, 2026-10-27
- **Where:** #5983; `5983-research-amazon-personalisation-prod`; Doc A .40399

### 6012 and 6013 price flow tickets

Price flow gets a grilling ticket #6012 (blocked by #5978, #6013) and a BRD-input ticket #6013 that links Asana
1219919849429744 and 1219919783909992.
- **Who, when:** Erick ("Ya, buat tiket"), 2026-10-28
- **Where:** #6012, #6013

### A5 to A7 price field mapping

Price fields (A5–A7), from the Manobo sales-channel price page: `list_price` ← UVP; `purchasable_offer.our_price` ←
Normal Price → Retail Price; `purchasable_offer.discounted_price` ← Promotion Price → Retail Price with Start/End
Date. FBM price = FBA price was answered 29 Oct: separate rows, may differ (Erick; Asana 1219919849429744 completed;
Amazon.de 0402620921 showed 29.40 FBA vs 29.50 FBM). Still open: the GBP/USD source (candidate: the Foreign Price
columns), asked 29 Oct on 1219919783909992.
- **Who, when:** the BA, 2026-10-28
- **Where:** Asana 1219919849429744 (08:59Z, screenshot asset 1219967631945095); Doc A .74487; #6013 issuecomment-6487445189

### A7 FBM and FBA price per sales channel

FBM vs FBA price (A7): each sales channel (AN.DL, AN.DB) sends its own `sales_channel_catalog_prices` row, so they
may differ; no linking rule. The BA field mapping (A5–A6) is locked. Asana task completed; GBP/USD confirmation stays
on the UK/US task.
- **Who, when:** Erick ('Ya, tutup'), 2026-10-29; Asana task due 2026-12-04, completed 29 Oct
- **Where:** Asana 1219919849429744 (closing comment 04:06Z); Doc A .78305 (rev 166); #6013 issuecomment-6487625824

### Seller SKU format

Seller SKU: FBA = real SKU, FBM = real SKU + `-FBM`. The listing-ownership half is unanswered.
- **Who, when:** the BA, 2026-10-28
- **Where:** Asana 1219919921458898 (06:51Z); Doc A .70046; #5986 c6463275311

### L suffix only on old products

Partial, a fact not a decision: the `-L` alternate SKU is used only on old products; other alternate-SKU formats for
FBM and FBA may appear later, so the SKU mapping (#5978) must rest on the alternate-SKU table, not a fixed suffix
rule. Ownership half still open. (The A9 half of the same answer: [fba-stock.md](fba-stock.md#a9-fba-stock-not-used-today).)
- **Who, when:** the BA, 2026-10-28
- **Where:** Asana 1219919921458898 (08:54Z); Doc A .75339

### L listings get no data fix before the migration

`-L` FBA listings: **no data fix before the migration** (Erick, 'Tetap tunggu'). The 138 DE FBA `-L` SKUs stay as
input to #5978 (comment issuecomment-6463784061). The BA's answer on what `-L` means is pending:
[open-state](../open-state.md#asana-business-questions).
- **Who, when:** Erick, late on 2026-10-28
- **Where:** #5978 issuecomment-6463784061; Doc A .71715 (rev 160)

### 5978 waits only on 5986

#5978 (SKU mapping, DE reconciliation report) no longer waits on the BRD sign-off #5989, only on #5986: the S1 exit
(Asana 1219919983244087) includes the DE SKU reconciliation report, and S1 ends the day #5989 is due (20 Nov); #5978
is grilled inside S1 once #5986 is answered.
- **Who, when:** Erick, 2026-10-30
- **Where:** #5978 c6517816695; map #5967 Destination; Doc A .91480

## Facts

### SKU formats

- **Real SKU** = `product_skus.sku` = product code (`products_model`) + `_` + size, no suffix when sizeless
  (`ProductSkuService::generate`), e.g. `0101113122_55`.
- **FBA listing = real SKU; FBM listing = real SKU + `-FBM`** (BA, 2026-10-28). Amazon.de agrees for ASIN
  B08Z7R2YCC (getListingsItem 2026-10-28): `0402620921` AMAZON_EU, our_price 29.40, FBA fulfillable 4;
  `0402620921-FBM` DEFAULT qty 1, our_price 29.50; both list_price 39.90, product type CHARM.
- `-FBM` is data, never generated: alternate SKUs per channel in `jng_sp_sku`. 23,946 rows end in `-FBM`; 21,067
  are exactly real SKU + `-FBM`; the rest use the old dash format, e.g. `335108-019-FBM` (#5978, 2026-10-28).
- **`-L` exception** (`order_import_errors`, CA source, last 30 days, 2026-10-28): channel 195 has 243 "Product not
  found for SKU" rows over 138 distinct SKUs, all ending in `-L` (`726099-046-L`, `0101371222_55-L`), none in
  `-FBM`; 90 of the 138 match a real SKU once `-L` is stripped. On 2026-10-28 `-L` alternate SKUs existed only on
  FBA-IN channels 52, 68 and 118. By 2026-10-30, 195, 203, 204 and 205 held 486 `-L` rows each. Each points at the same product and
  article as `product_skus` for the stripped SKU on 288 of 288 rows where that SKU exists; 198 have no
  `product_skus` row. Channels 203, 204, 205 and 207 show the same (39, 28, 45, 17 SKUs, all `-L`), and 229, 231 and
  232 one `-L` SKU each. Example orders on 195:
  `028-1496294-5276357` (`335109-021-L`), `028-3014188-7621138` (`712712-019-L`). So FBA listings carry at least
  three styles: real, real + `-L`, old dash format. Who added the 486 rows, and what it did to the DE import gap:
  [orders-import.md](orders-import.md#amazon-orders-that-never-reach-manobo).
- `S` + mother product code (e.g. `S0402620921`) is the CA family parent built by
  `ChanneladvisorExportProductFamilyService`; Amazon does not know it (404, search 0 results, 2026-10-28).
- Amazon.de holds 4,714 Nenalina listings (searchListingsItems `numberOfResults`, 2026-10-27). Anja uploads new
  products to Amazon by hand and copies the ASIN into Manobo; products are never uploaded via Manobo (sheet).

### Listings on Amazon.de

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
- The write path for FBM quantity and price (`patchListingsItem` or `JSON_LISTINGS_FEED`): [fbm-stock.md](fbm-stock.md#facts).

- **All-listings report, Amazon.de, 2026-11-01** (`GET_MERCHANT_LISTINGS_ALL_DATA`, report 2406960020758, pulled by a
  standalone script with the Nenalina EU token; #5986 issuecomment-6557537148; persistent summary
  `~/.config/Claude/side-session-notes/local_0f6cedbf-c406-4622-afe2-5b8dae0215c5/5978-de-listings-summary-2026-11-01.md`):
  4,714 seller SKUs = FBA (AMAZON_EU) 2,644 + FBM (DEFAULT) 2,070; Active 2,865 (FBA 1,871, FBM 994), Inactive 1,834,
  Incomplete 15. FBM: 2,045 of 2,070 end in `-FBM` (25 sizeless codes). FBA: 2,058 are the real SKU in the current
  format `NNNNNNNNNN[_SS]`; **`-L` is a second FBA convention**, 495 of 496 `-L` rows are FBA (377 Active), on old
  dash-format SKUs (389), current codes (93) and letter-prefix codes (14). Other formats: 39 old dash without suffix,
  54 six-digit, 10 nine-digit, 18 Amazon-generated `XX-XXXX-XXXX`; 3 `-FBM` SKUs are fulfilled by Amazon.
  **Match against Manobo (replica, read-only):** 3,953 exact (2,379 on the DE channel's `jng_sp_sku`, 1,546 on
  `product_skus`, 28 on another channel's `jng_sp_sku`), 1 after stripping `-L`, 760 no match; **every Active listing
  matches exactly**, all 760 unmatched are Inactive (745) or Incomplete (15), 733 of them a product code without its
  size (old offers, not checked per ASIN). Manobo side without a listing (active `jng_sp_catalog` rows, expected SKU =
  channel `jng_sp_sku` else `product_skus`): FBM channel 192: 705 of 2,419 have no FBM listing (1,425 no Active one);
  FBA channel 195: 90 of 2,212 have no FBA listing (397 no Active one). Not verified: listing ownership (not in the
  report), the business meaning of `-L`, replica lag. API calls: LWA token POST, createReport POST, getReport GET ×2,
  getReportDocument GET, document download; no feeds.

- **All-listings reports, every marketplace, 2026-11-01** (16 `GET_MERCHANT_LISTINGS_ALL_DATA` reports, one per marketplace
  from `getMarketplaceParticipations`; workbook `5978-amazon-all-marketplaces-vs-manobo-2026-11-01.xlsx` in
  `~/.config/Claude/side-session-notes/local_0f6cedbf-c406-4622-afe2-5b8dae0215c5/`, 5 sheets incl. "SKU x marketplace"):
  the EU account lists 13 Amazon marketplaces, **SA, AE and TR included** (0, 0 and 1 listing; no Manobo channel), plus
  8 non-Amazon/MCF entries; NA = US, CA, MX. Totals 31,856 listings (FBA 17,716 / FBM 14,140), 7,823 distinct seller
  SKUs, 30,081 exact matches, 429 after normalisation, 1,346 no match, **51 Active listings without a Manobo match**
  (GB 6, US 44, FR 1). Per marketplace: DE 4,714; FR 3,919 (report has no ASIN column); IT 3,920; ES 3,925; NL 3,918;
  BE 3,762; PL 3,168; **SE 1** although Manobo's SE catalogs (202 FBM 3,000 rows, 233 FBA 2,270) are full; IE 0;
  GB 4,140 with **2,248 FBM listings while Manobo has only the FBA channel 206** and GB-only suffixes `-UK`, `-PAR`,
  `-PAR-UK`, `PAR` (423 `-UK` SKUs match only after the suffix is stripped; `-PAR` = sizeless codes, assumed variation
  parents); US 187 (44 Active unmatched: 6-digit / sizeless codes and their `-L` variants); CA 180 and MX 21 with
  Amazon placeholder SKUs `Amazon.Found.<ASIN>`; channels 208 CA and 209 MX have no catalog rows, 207 US has 5. Manobo
  SKUs without an Active listing: FBM channels 12,739 (catalog-active) / 17,397 (all rows), FBA 5,717 / 6,603. Report
  layouts differ per marketplace (18–31 columns, German headers on EU, English on NA): map columns by header name.
  Amazon returned the same DE document as the morning pull. 68 API calls, no 429. Not verified: listing ownership,
  the meaning of `-L` / `-UK` / `-PAR`, why Amazon.se has 1 listing, replica lag.

### Prices per sales channel (verified 2026-10-29, code + replica)

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
  `discounted_price` ← Promotion Price → Retail Price + dates. FBM/FBA price: separate rows, may differ (Erick, 29 Oct). Open: `_foreign` columns
  for UK/US (asked 29 Oct). Not verified: how Rithum maps RRP/SellingPrice to Amazon fields; whether the PUTs succeed.

### Personalisation

- **Personalisation:** 0 of 18,695 Amazon Nenalina orders in 12 months; only CA PrivateNotes on 1,318 FBM orders,
  one constant string (#5983, 2026-10-27).

## Traps

### "FBA uses the real SKU, so the mapping is real SKU vs real SKU + -FBM"

**Believed:** the BA's rule of 2026-10-28, true for the sampled product.
**True:** every DE FBA "Product not found for SKU" in the last 30 days is a `-L` SKU, and old dash-format SKUs
exist too. A mapping table must cover all three styles, and `-L` explains most of today's DE import gap.
**Caught** by the replica check of 2026-10-28, posted on #5978.

### "FBM and FBA have the same price"

**Planned around** in the #5978 question ("when FBM and FBA prices are equal") and Doc A .27879 (one price
pushed to both SKUs if workshop question Q14 says so).
**True:** the one pair checked differs today: `0402620921` 29.40 (FBA) vs `0402620921-FBM` 29.50, same list
price. **Caught** by getListingsItem, 2026-10-28. The business answer is still open (#6013).

### "The listings use product type JEWELRY"

**Believed** in the #5981 question and Doc A (.5920).
**True:** NECKLACE, RING, BRACELET and CHARM. A patch sends the listing's own `summaries[].productType`.

### "S0402620921 is an Amazon SKU"

It is the ChannelAdvisor family parent shown in a CA catalogue screenshot; Amazon answers 404. A ChannelAdvisor
screen is not Amazon evidence: confirm on Amazon with getListingsItem (2026-10-28).

## How to verify

SP-API GET script and replica wrapper: [verification.md](../verification.md). EU seller `A1SMSLS6YOBHD5`, DE `A1PA6795UKMFR9`.

| Purpose | Request | Last OK |
|---|---|---|
| One listing | `GET /listings/2021-08-01/items/{seller}/{urlencoded sku}?marketplaceIds={mp}&includedData=summaries,attributes,offers,fulfillmentAvailability,issues` — 404 `NOT_FOUND` = no such SKU | 2026-10-28 |
| Find a SKU / count listings | `GET /listings/2021-08-01/items/{seller}?marketplaceIds={mp}&identifiers={sku}&identifiersType=SKU&includedData=summaries`; with `pageSize=20` and no identifiers → `numberOfResults` | 2026-10-28 |
| Product type schema | `GET /definitions/2020-09-01/productTypes/{TYPE}?marketplaceIds={mp}&requirements=LISTING&locale=de_DE`, then fetch `schema.link` (pre-signed, 0.4–0.5 MB) | 2026-10-27 |

**ChannelAdvisor SKU errors per channel** (`order_import_errors.payload` holds `errors[]` and a `reference`
"Download ID/CA Order ID: <download id>/<CA id>"; ran 2026-10-28, about 5 s):

```sql
WITH e AS (
  SELECT oie.id, d.jng_sp_id,
         TRIM(SUBSTRING_INDEX(j.err, 'Product not found for SKU:', -1)) COLLATE utf8mb4_general_ci sku
  FROM order_import_errors oie
  JOIN JSON_TABLE(oie.payload, '$.errors[*]' COLUMNS (err VARCHAR(500) COLLATE utf8mb4_general_ci PATH '$')) j
  JOIN jng_sp_download d ON d.jng_sp_download_id = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(
         JSON_UNQUOTE(JSON_EXTRACT(oie.payload,'$.reference')),': ',-1),'/',1) AS UNSIGNED)
  WHERE oie.source = 'channeladvisor' AND oie.created_at >= NOW() - INTERVAL 30 DAY
    AND j.err LIKE '%Product not found for SKU:%')
SELECT jng_sp_id, COUNT(*) err_rows, COUNT(DISTINCT sku) distinct_skus,
       COUNT(DISTINCT CASE WHEN sku LIKE '%-L' THEN sku END) l_suffix,
       COUNT(DISTINCT CASE WHEN sku LIKE '%-FBM' THEN sku END) fbm_suffix,
       COUNT(DISTINCT CASE WHEN sku IN (SELECT sku FROM product_skus) THEN sku END) in_product_skus,
       COUNT(DISTINCT CASE WHEN sku IN (SELECT sku FROM jng_sp_sku) THEN sku END) in_any_jng_sp_sku
FROM e GROUP BY jng_sp_id;
```

To test the `-L` strip on one channel, add `d AS (SELECT DISTINCT sku FROM e WHERE jng_sp_id = 195)` and count
`JOIN product_skus ps ON ps.sku = LEFT(d.sku, CHAR_LENGTH(d.sku) - 2)`; `jng_sp_sku` has `jng_sp_id`, `sku`,
`products_id`, `articles_id`.

## Open

Live state is in [open-state.md](../open-state.md); the lines that touch this flow:

- #5986 (listing ownership after Rithum, A3), #5978 (SKU mapping and DE reconciliation report), #6012 (price flow),
  #6013 (waits on the UK/US `_foreign` confirmation): [map](../open-state.md#map-tickets).
- Asana 1219919921458898 (ownership, the `-L` question), 1219919783909992 (UK/US GBP/USD fields), 1219919864498676
  (Build International Listings): [Asana](../open-state.md#asana-business-questions).
