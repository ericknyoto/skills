# Channels and routing

Seller accounts, the app, marketplace ids, the Nenalina and Julie & Grace channels, the integrator per channel and
its switch (ADR 0132), Amazon Seller channel identity (ADR 0134), populations. Order routing: ADR 0130 in
[orders-import.md](orders-import.md#adr-0130-one-order-stream-per-seller-account); FBM/FBA per flow:
[ADR 0138](cancel-and-refund.md#adr-0138-flows-per-fulfilment-channel); credentials: [data-protection.md](data-protection.md#credentials);
SP-API transport and rate limits (ADR 0129): [monitoring-and-failures.md](monitoring-and-failures.md#adr-0129-one-sp-api-transport).

## Decisions

### ADR 0128 one AmazonSeller domain

All Amazon Seller code in one domain `Manobo2/Domain/AmazonSeller` (not `Shared/ApiExchange`); Vendor/EDI
excluded; SalesOrder never imports it; credentials per seller account via `config/amazon.php`; endpoint follows the
app environment, production override for reads only; integrator enum case stays `amazon`.
- **Status:** Accepted 2026-10-27 (Erick, delegated); PR #5990 merged 2026-10-27 06:10Z (`0a9a6dc05d`)
- **Where:** #5968 c6434758901; Doc A .41634

### ADR 0132 one integrator per sales channel

Nullable `jng_sp.integrator` (`channeladvisor`/`tradebyte`/`amazon`) with `ca_used`/`tb_used` as CHECK-guarded
mirrors; the CA download skips and marks Exported an order routed to a non-CA channel; cross-importer dedup on
`order_id` within one seller account under a Redis lock; write-backs follow the channel's integrator at write time,
CA-imported orders included (item found by getOrder SKU + quantity, ambiguity → failure table); a switch is one
batch action per CA profile whose only hard precondition is Rithum stock/price sync off, with no drained gate and a
switch-time record of open CA orders.
- **Status:** Accepted 2026-10-28 (`3ec734103b`); PR #6007 merged 2026-10-28 07:14Z (`74b6517496`)
- **Where:** #5970 c6435901334; Doc A .50867, .57985, .61615

### ADR 0132 Decision 6 batch switch per CA profile

ADR 0132 Decision 6 rewritten (Q9): drained precondition dropped; batch switch per CA profile, DE twice (AN.DL then
AN.DB in 4–8 Jan); Rithum stock/price off is the only hard precondition.
- **Who, when:** coordinator, delegated; then Erick accepted the ADR; 2026-10-28
- **Where:** commits `e6d86524a8`, `e8ce681973`; Doc A .57985

### 5984 stop ChannelAdvisor per CA profile

Stopping ChannelAdvisor for Nenalina at S8 goes per CA profile or in code, never by removing the cron line.
- **Who, when:** ticket session (read-only prod, granted by Erick), 2026-10-27
- **Where:** #5984 c6435792248

### ChannelAdvisor export gate per profile

Manobo's stock export to ChannelAdvisor (event job per product family + daily 18:30/00:30 exports) and its price export
(RRP + SellingPrice on save) skip a CA profile whose channels all carry integrator `amazon`. The same gate is the
"stop per profile" of the S8 decommission (#5984). Why: both exports hit every profile ungated, so after a switch the only
safety is Rithum's DE sync being off by hand; the gate closes the case where it is switched back on. Built in the S3 spec
(with DE prices and the FBM stock patch), not a map ticket. The switch itself stays a manual command (#6075); S1 neither
automates it nor cuts the CA connection.
- **Who, when:** Erick ("setuju"), 2026-10-30, on the coordinator's analysis
- **Where:** Doc A .99433; to be carried into the S3 spec; map #5967 Decisions line owed by the next Wayfinder session
- Facts behind it: [fbm-stock.md](fbm-stock.md#facts), [prices-and-listings.md](prices-and-listings.md#facts)

### ADR 0134 channels configured by columns

Amazon Seller channels are plain `JngSp` rows (`type` NULL), defined by `amazon_seller_account` NOT NULL (both
`amazon_*` columns set together, CHECK), carried by Amazon only when `integrator = amazon`; Amazon code reads only
listed `jng_sp` columns and `config/amazon.php`; subclass/`equals()`, `jng_sp_id`/`JngSpIdHelper`,
`package_prefix`/`name`, `use_amvd_logistic`, `marketplace_id`/Marketplace and `jng_sp.currency` banned as
discriminators by an architecture test; existing `Amazon*` subclasses and dead row 48 untouched.
- **Status:** Accepted 2026-10-28 (`4c531081ee`); PR #6008 merged 2026-10-29 12:55Z (`58eea8e9ea`)
- **Where:** #5973 c6436092475; Doc A .52459, .61995

### App authorised on Nenalina EU and NA

App authorised on Nenalina EU and NA; J&G EU not needed for phase 1 (since 28 Oct the JG tokens are a task in the JG
preparation section).
- **Who, when:** Sarina (authorisation), Erick (check), 2026-10-27
- **Where:** Doc A .37271; Asana 1219960974323506

### No architecture tests for now

The source-scan tests for ADR 0128 §1 (nothing outside the domain references `Domain\AmazonSeller`) and ADR 0134 §4
(no `JngSpIdHelper`, `->equals(`, `package_prefix`, `marketplace_id`, `Marketplace` model, `->currency`) are dropped from
PR #6088: "too rigid for now". The rules stay binding and are held by code review; ADR 0134 gets an erratum (§4 names the
test twice), #6064's acceptance criterion and spec #6062 Testing Decisions are struck. The `currency_code` convention
(Q6) stays as a review rule. The coordinator's recommendation (keep, token-based matching) was not taken.
- **Who, when:** Erick, 2026-10-30
- **Where:** Doc A .97616; PR #6088; ADR 0134 erratum (docs PR); #6064 and #6062 edits by the S1 session

### The form keeps the `amazon` option

The sales-channel form keeps `amazon` in its integrator select (spec #6062 §E, confirmed "Tetap ikutin sesuai spec di
awal"). While `AMAZON_SELLER_SWITCH_ENABLED` is off, form and command both refuse `amazon`; once it is on for the go-live
weeks, both can move a channel. Only the command (#6075) adds the dry run, the Rithum attestation and the open-orders
record; a form change is covered by the audit log only. Runbook consequence: cutovers go through the command, the form
is for keys and corrections, and the env switch stays on only during the go-live window.
- **Who, when:** Erick, 2026-10-30 (in the S1 implementation session)
- **Where:** Doc A .100529; #6065, #6075 and the spec unchanged

### Integrator column save rules (#6065)

`integrator` is a required (`present`) field on the sales-channel save: a stale form opened before the deploy fails
loudly with a "reload the page" message instead of saving NULL and silently taking a channel off ChannelAdvisor. The
form rule "reject `amazon` while `AMAZON_SELLER_SWITCH_ENABLED` is false" ships with #6075 (moved from spec §E), and the
S1 parent PR is not marked ready before #6075 is in. The save runs in a `DB::transaction` with the selling-price refresh
job dispatched through `DB::afterCommit()` (CODING_STANDARDS: multi-write Actions use a transaction). The coordinator's
30 Oct waiver "no transaction, integrator written last" was wrong and is withdrawn: the review of PR #6089 found that on the
insert path a failed integrator write left the new row while the page re-rendered as "new", so a second save created a
duplicate channel. The CHECK also restricts `integrator` to the three ADR 0132 §1 values; seeders that set a flag set the
integrator too (seven JSON-fixture seeders fixed).
- **Who, when:** coordinator on Erick's delegation, 2026-10-30 (S1 session Q7–Q9, #6065 / PR #6089)
- **Where:** PR #6089 body and docblocks; #6075 acceptance criteria; #6074 note on the factory default (`integrator` NULL)

### Currency is `currency_code` inside the Amazon Seller domain

The ADR 0134 architecture test bans `->currency` anywhere in `Domain\AmazonSeller` (a source scan cannot tell a sales
channel from another object), which is stricter than the ADR's "on a sales channel". Accepted on 30 Oct, then the test itself was dropped the same day (see "No architecture tests for now"); the convention that
the domain's own currency columns and properties are named `currency_code` stays, held by review (ISO 4217, Amazon's `currencyCode`; ADR 0131
already says "currency code"), so S2's order currency never trips the test. No ADR change.
- **Who, when:** coordinator on Erick's delegation, 2026-10-30 (S1 session Q6, #6064 / PR #6088)
- **Where:** the architecture test's docblock; PR #6088

### S1 spec additions to ADR 0132 and 0134

The S1 spec adds four rules that no ADR states:
1. `AMAZON_SELLER_SWITCH_ENABLED` (default false; false in production until the go-live weeks) makes the switch
   command and the sales-channel form refuse `integrator = amazon`.
2. The form rejects a channel that has a ChannelAdvisor channel id when its integrator is neither `channeladvisor`
   nor `amazon`: the skip rule would otherwise acknowledge its ChannelAdvisor orders and nothing would import them.
3. `integrator`, `amazon_seller_account` and `amazon_marketplace_id` join `JngSp`'s audit allow-list.
4. The keys of the 20 channels are filled through the form, from a runbook table (#6073), not by a command.
- **Who, when:** Erick ("Setuju"), 2026-10-30
- **Where:** #6062 sections E and F, Further Notes; tickets #6065, #6072, #6073, #6075

## Facts

### Seller accounts and app

- **Two seller accounts, one refresh token each:** Nenalina EU and Nenalina NA (config keys `nenalina_eu`,
  `nenalina_na` per #5969). The EU seller id is `A1SMSLS6YOBHD5`: listings calls for it answered 200 with the EU
  token (#5981, 2026-10-27). The NA seller id is not recorded. Julie & Grace EU is not authorised (Doc A .37271).
- **Production app** `Manobo-2008-Sellers` (`amzn1.sp.solution.b7e18360-050b-49b3-a42f-fe91e3a02b3a`): Private
  developer profile, so self-authorisation only; entity Seller; RDT delegation No. Roles: Finance and Accounting,
  Inventory and Order Tracking, Direct-to-Consumer Shipping (restricted), Amazon Fulfillment, Product Listing,
  Pricing, Seller Insights, Brand Analytics. **Not** Tax Invoicing, Tax Remittance, Buyer Communication, Buyer
  Solicitation (Solution Provider Portal, read 2026-10-27). Sandbox app: `Manobo-2008`.
- Sarina authorised both Nenalina accounts on 2026-10-27; the portal then showed 8 of 10 self-authorisations left.
- Each token works only in its region; the other region answers 403 (marketplaceParticipations, 2026-10-27).

### Marketplace ids

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

### Nenalina channels (production replica, 2026-10-28)

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
- **All `jng_sp` rows**, replica 2026-10-30, the base of the ADR 0132 backfill:
  - 238 rows: 29 with `ca_used = 1` (become `channeladvisor`), 130 with `tb_used = 1` (become `tradebyte`), 79 with
    neither (become NULL), none with both.
  - Every `ca_used = 1` row has a CA channel id, and no `ca_used = 0` row has one, so the skip rule moves no routing
    on deploy.
  - `jng_sp_orders`: 5,462,237 rows, a non-unique `order_id` index (it serves the ADR 0132 guard) and a UNIQUE
    `shipment_id`.
  - `order_import_errors.source` is `varchar(50)`.
- Neighbours outside scope: AM.US 53 (J&G US FBA) on CA profile 12043758; FBA-IN channels AN.IS 52, AN.UI 68,
  AN.UK 118 (`ca_used = 0`), which book FBA stock as pseudo-orders (AN.UK 118 last on 2026-07-08, 20,569 in
  total, memory 2026-10-27); row 48 AN.DS, the inactive 2021–2023 direct import.

### Julie and Grace channels (phase 2)

- The sheet's tab Seller JG marks 12 channels "Active, need to migrate": AM.DE (FBM: stock, price, orders,
  returns), AM.DF, AM.UF, AM.US (FBA: stock, price, orders, returns), and order-only AM.ES, AM.EF, AM.FR, AM.FF,
  AM.IT, AM.IF, AM.NL, AM.NF. AM.UK is inactive (sheet, read 2026-10-28).
- All run on Tradebyte (`tb_used = 1`, `ca_used = 0`) except AM.US 53 on ChannelAdvisor. Orders in 365 days
  (2026-10-28): AM.DF 7,661, AM.DE 757, AM.FF 581, AM.IF 399, AM.EF 341, AM.UF 56, AM.FR 22, AM.ES 22, AM.NF 20,
  AM.IT 12, AM.NL 5, AM.US 4, AM.UK 0. J&G listings (AM.MA) also go through Tradebyte (Doc A .10265).

### ChannelAdvisor routing today

- **Routing** is `(ca_profile_id, ca_channel_id, use_external_warehouse)` and ignores `ca_used` and
  `active_status`; no match or several → info log and the order stays unexported (#5970, 2026-10-27). The CA
  download itself: [orders-import.md](orders-import.md#channeladvisor-import-today); the CA stock export: [fbm-stock.md](fbm-stock.md#facts).
- Where `ca_used`/`tb_used` are derived on save, and the other code anchors: [sources/github.md](../sources/github.md#code-anchors).

### Populations

- **Load:** CA retail for Nenalina averages 27 orders a day, peak 44; returns 613 rows per 90 days (AN.DB 358,
  AN.UB 90) (Doc A .2855, .11301, measured 2026-10-20).
- **SKUs per fulfilment channel:** `jng_sp_sku` holds 3,730 distinct SKUs on the 9 FBM channels (29,576 rows) and 2,126 on
  the 12 FBA channels (15,285 rows) (replica, 2026-10-30; #5977).

## Traps

### "Setting ca_used = 0 stops ChannelAdvisor for a channel"

**True:** the CA download routes on `(ca_profile_id, ca_channel_id, use_external_warehouse)` and ignores `ca_used`
and `active_status`; only ADR 0132's skip rule, not yet built, will stop it. The CA stock export pushes to every
profile regardless, so Rithum itself must switch stock and price sync off (#5970).

### "Removing the cron line stops ChannelAdvisor for Nenalina"

**True:** one host-cron line downloads all 23 CA profiles and Tradebyte, so stopping goes per profile or in code.
The CA stock cron script looks live in `cron/` but has not run since 2023-07-09; stock goes by event (#5984).

### Columns that look like Amazon identity and are not

`jng_sp.marketplace_id` points at Manobo's `marketplaces` table, whose types are rotated in production (29 "Amazon
NL" is typed `AmazonUSJGMarketplace`). `use_amvd_logistic` and `salesChannelIsAmazon()` mean Amazon **Vendor**.
`jng_sp.currency` is EUR on US, PL and SE. `package_prefix`, channel ids and subclasses are banned by ADR 0134.
Amazon identity is `amazon_seller_account`, `amazon_marketplace_id` and `use_external_warehouse`, once built.

### "Julie & Grace sells through ChannelAdvisor"

The Sales documents and the first project form said so. J&G retail is Tradebyte (`tb_used = 1`) on every channel
but AM.US, which has 4 orders a year. Phase 2 replaces Tradebyte for Amazon, not ChannelAdvisor.

The scope count (16 vs 20 channels) is a cross-cutting trap: [traps.md](../traps.md#phase-1-is-16-channels-per-the-sheet).

## How to verify

Run SQL through the replica wrapper in [verification.md](../verification.md#production-replica).

**Channels** (the channel table above):

```sql
SELECT jng_sp_id, package_prefix, name, ca_profile_id, ca_channel_id, use_external_warehouse uew,
       active_status, ca_used, tb_used, split_orders, ca_stock_use_alternate_sku, no_order_confirmation, type
FROM jng_sp WHERE ca_used = 1 AND (package_prefix LIKE 'AN.%' OR package_prefix LIKE 'AF.%' OR package_prefix LIKE 'AM.%')
ORDER BY jng_sp_id;
```

**Orders per channel.** Split channels hold one row per unit, so count `DISTINCT order_id` (AN.DB, 365 days to
2026-10-28: 11,965 rows, 11,230 orders):

```sql
SELECT o.jng_sp_id,
       COUNT(DISTINCT CASE WHEN o.order_date >= CURDATE() - INTERVAL 365 DAY THEN o.order_id END) orders_365d,
       COUNT(DISTINCT CASE WHEN o.order_date >= CURDATE() - INTERVAL 30 DAY THEN o.order_id END) orders_30d,
       MAX(o.order_date) last_order
FROM jng_sp_orders o WHERE o.jng_sp_id IN (191,192,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,229,231,232,233)
GROUP BY o.jng_sp_id;
```

**Marketplaces of a token** (SP-API GET script in [verification.md](../verification.md#sp-api-read-only)):
`GET /sellers/v1/marketplaceParticipations` (EU token: 18 entries, 13 Amazon + 5 MCF; NA token: 6 entries, 3 Amazon + 3 MCF;
all `isParticipating`). Last OK 2026-10-30 through the S1 transport (#6064); the Amazon ids match `config/amazon.php`.
Amazon's `countryCode` for the UK is `GB` (Amazon.co.uk and the Non-Amazon UK entry): the config key "UK" is a label and
the code compares by marketplace id, so any later mapping by country code must use `GB`.

## Open

Live state is in [open-state.md](../open-state.md); the lines that touch this flow:

- S1 spec #6062 (integrator column and switch, channel keys for the 20 channels): [S1 spec](../open-state.md#s1-spec-6062).
- The sheet's "(manually)" note on AN.KB and AN.UB: [Pending for Nitya](../open-state.md#pending-for-nitya-beyond-those-tasks).
- Unticketed: the runbook of the 11–15 Jan week across both tokens, the months-long ChannelAdvisor overlap: [map](../open-state.md#map-tickets).
- Rotated `marketplaces.type` values and dead row 48: [known-unfixed](../open-state.md#known-unfixed-no-issue-yet).
- Julie & Grace phase 2 tasks: [open-state](../open-state.md#julie-and-grace-phase-2).
