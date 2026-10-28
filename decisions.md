# Decisions index

One row per decision, in its current state. "Where" names every place it is recorded: the ADR file and PR, the
GitHub ticket and its resolution comment id (`#5970 c6435901334` = `issuecomment-6435901334`), the Doc A log row
(`.NNNN` = `mzse2z3z5sh.NNNN`), the Asana task. "Delegated" means Erick handed the grilling answers to the
coordinator session and accepted the result. Statuses checked 2026-10-28 with `gh pr view` and the ADR files on
`origin/master`. What a decision rests on lives in `facts.md`; what is still open lives in `open-state.md`.

## Architecture decision records

| ADR | Decision | Status | Where |
|---|---|---|---|
| 0128 | All Amazon Seller code in one domain `Manobo2/Domain/AmazonSeller` (not `Shared/ApiExchange`); Vendor/EDI excluded; SalesOrder never imports it; credentials per seller account via `config/amazon.php`; endpoint follows the app environment, production override for reads only; integrator enum case stays `amazon` | Accepted 2026-10-27 (Erick, delegated); PR #5990 merged 2026-10-27 06:10Z (`0a9a6dc05d`) | #5968 c6434758901; Doc A .41634 |
| 0129 | One `SellingPartnerApi` transport with an `SpApiOperation` enum; Redis token bucket per (seller account, operation), wait ≤ 10 s else `SellingPartnerThrottled`; retry only via `$when` (idempotent ops: 429/5xx/connection, max 3); `createFeed` never replayed on timeout/5xx → `SellingPartnerOutcomeUnknown`; feeds as `amazon_seller_feeds` rows polled by a self-re-dispatching job. Client shape, credential modes, `amazon-seller` log channel, endpoint guard and `includedData=FULFILLMENT` are recorded only in #5972 | Accepted 2026-10-27 (delegated); PR #5993 merged 2026-10-27 06:46Z (`cdbedc6282`) | #5972 c6435263857; Doc A .46035 |
| 0130 | One searchOrders stream per seller account over all its marketplaces in config; route by (`amazon_seller_account`, `amazon_marketplace_id`, `use_external_warehouse` 1 = FBA / 0 = FBM) under a UNIQUE index; unrouted orders go to the failure table, never skipped silently; one `lastUpdatedAfter` watermark per account, resumable pages, 90-minute run lock; ≥ 3 minutes between runs | Accepted 2026-10-27 (delegated); PR #5992 merged 2026-10-27 06:39Z (`7447372323`) | #5969 c6435347742; Doc A .47814 |
| 0131 | `shipment_id` = `<amazonOrderId>AZ`, split channels `<amazonOrderId>AZ<p>N<n>`; `order_id` = Amazon id; `order_id_external`, `xml_file` NULL; raw item money in `amazon_seller_order_items` (`proceeds`, `quantityOrdered`, `unitPrice`; written once; natural keys; no buyer blocks); reads add `PROCEEDS`, `PROMOTION`, `TAX`. Amended 28 Oct: only `proceeds` carries money, Finances API is the fallback for orders imported before capture, and table + suffix are a per-integrator pattern | Accepted 2026-10-27 (`4cf924d359`), amended 2026-10-28 (`99c25d18de`, `6440c7feda`); PR #5994 merged 2026-10-28 06:52Z (`3b0e1164cc`) | #5971 c6435899870; Doc A .50028, .66078, .69284 |
| 0132 | Nullable `jng_sp.integrator` (`channeladvisor`/`tradebyte`/`amazon`) with `ca_used`/`tb_used` as CHECK-guarded mirrors; the CA download skips and marks Exported an order routed to a non-CA channel; cross-importer dedup on `order_id` within one seller account under a Redis lock; write-backs follow the channel's integrator at write time, CA-imported orders included (item found by getOrder SKU + quantity, ambiguity → failure table); a switch is one batch action per CA profile whose only hard precondition is Rithum stock/price sync off, with no drained gate and a switch-time record of open CA orders | Accepted 2026-10-28 (`3ec734103b`); PR #6007 merged 2026-10-28 07:14Z (`74b6517496`) | #5970 c6435901334; Doc A .50867, .57985, .61615 |
| 0133 | Amazon buyer PII only in `PiiFieldMap` columns, which BR-1 redacts; no PII in any `AmazonSeller` store, log, feed row, money table, shadow or failure table, job payload or cache (test-enforced); retention per channel is a business switch, with no forced validation and no gate; FBA requests neither BUYER nor RECIPIENT until #5988; Amazon `errors[]` logged as code + message; Sentry `sql_bindings` off and Nightwatch checked before the first PII read (BR-3, S1) | Accepted 2026-10-27 (`ffd5aa4aaf`; Q1 answered by Erick, Q2–Q6 delegated); PR #5995 merged 2026-10-28 06:59Z (`d5f55beb6f`) | #5975 c6435827564 (closed by Erick); Doc A .49003 (said Proposed), .71195 (merged) |
| 0134 | Amazon Seller channels are plain `JngSp` rows (`type` NULL), defined by `amazon_seller_account` NOT NULL (both `amazon_*` columns set together, CHECK), carried by Amazon only when `integrator = amazon`; Amazon code reads only listed `jng_sp` columns and `config/amazon.php`; subclass/`equals()`, `jng_sp_id`/`JngSpIdHelper`, `package_prefix`/`name`, `use_amvd_logistic`, `marketplace_id`/Marketplace and `jng_sp.currency` banned as discriminators by an architecture test; existing `Amazon*` subclasses and dead row 48 untouched | Accepted 2026-10-28 (`4c531081ee`); **PR #6008 open** | #5973 c6436092475; Doc A .52459, .61995 |

ADR 0131's body was edited after acceptance and before merge, although `docs/adr/README.md` prescribes
append-only errata. Erick accepted that as is ("Merge begini", 2026-10-28, coordinator ledger); no erratum block.

## Map tickets and research without an ADR

| Date | Decision or outcome | By | Where |
|---|---|---|---|
| 2026-10-27 | Product types are NECKLACE/RING/BRACELET, not JEWELRY; a price write sends the listing's own `productType`; `list_price` has no schedule | research agent, checked by Erick | #5981; `research/jewelry-list-price`; Doc A .39998 |
| 2026-10-27 | `carrierCode` = the last-mile carrier's exact `amzn-base.xsd` code; Metapack is never a code; `Other` + `carrierName` only for codeless carriers; own map keyed on shipment provider id; confirmShipment stays on v0 | research agent, checked by Erick | #5982; `research/amazon-carrier-codes`; Doc A .40195 |
| 2026-10-27 | Personalisation stays out of the P1 order-mapping scope (none in production) | research agent, checked by Erick | #5983; `5983-research-amazon-personalisation-prod`; Doc A .40399 |
| 2026-10-27 | Recommendation: order mapping holds an order when a rate is missing or ≤ 0, and takes the currency from the Amazon order, never `jng_sp.currency` | research agent, checked by Erick | #5980; `research/currency-pairs`; Doc A .40608 |
| 2026-10-27 | Stopping ChannelAdvisor for Nenalina at S8 goes per CA profile or in code, never by removing the cron line | ticket session (read-only prod, granted by Erick) | #5984 c6435792248 |
| 2026-10-28 | ADR 0132 Decision 6 rewritten (Q9): drained precondition dropped; batch switch per CA profile, DE twice (AN.DL then AN.DB in 4–8 Jan); Rithum stock/price off is the only hard precondition | coordinator, delegated; then Erick accepted the ADR | commits `e6d86524a8`, `e8ce681973`; Doc A .57985 |
| 2026-10-28 | No separate operational ticket for today's ChannelAdvisor DE import leak ("Tunggu migrasi"); its numbers feed #5978 and #5976; the service-api `nextLink` gap stays a follow-up candidate | Erick | #5970 c6462113723; Doc A .68504 |
| 2026-10-28 | Raw-money table stays per integrator; the next direct integrator (Shopify) owns its own table and suffix; a shared refund flow generalises the port, not the storage | Erick ("Per integrator") | ADR 0131 Consequences, `6440c7feda`; Doc A .69284 |
| 2026-10-28 | Price flow gets a grilling ticket #6012 (blocked by #5978, #6013) and a BRD-input ticket #6013 that links Asana 1219919849429744 and 1219919783909992 | Erick ("Ya, buat tiket") | #6012, #6013 |
| 2026-10-28 | Release-freeze question becomes BRD-input ticket #6006, blocking shadow-mode design #5976 | map session, at the coordinator's request | #6006; Asana 1219961077776438 |
| 2026-10-28 | #5991 (UK orders) closed as "import" by the scope decision | map session | #5991 c6460009177 |

## Scope, timeline and governance

| Date | Decision | By | Where |
|---|---|---|---|
| 2026-10-20 | Build directly in `manobo-2008` (Laravel 11, PHP 8.4); `manobo-service-api` deprecated | Erick | Doc A .36931; ADR 0128 |
| 2026-10-27 | PO = Sarina Seigis, BA = Nitya; business decisions via BRD (BA with PO), technical decisions via tech-lead grilling without BRD | Erick | Doc A .37485, .37571 |
| 2026-10-27 | Tracking: Doc A = source of truth; new Asana project for business and sprints; GitHub map for technical; July project `1216749791369428` superseded | Erick | Doc A .37729 |
| 2026-10-27 | Every business task is assigned to Nitya, never Sarina; Nitya reaches out to Sarina | Erick | Doc A .38822 |
| 2026-10-27 | Amazon DPP obligations BR-1 … BR-6 stay binding for the new domain | Erick | Doc A .38010; ADR 0133 |
| 2026-10-27 | Map destination "S1 can start"; one map per gate, the next destination is S2 | Erick | Doc A .38199, .41106; #5967 |
| 2026-10-27 | Research agents may use production read-only (SP-API EU/NA tokens, replica); findings on `research/*` branches, no PR | Erick | Doc A .38368 |
| 2026-10-27 | Canonical terms Integrator, Seller account, Fulfilment channel | Erick | Doc A .38540; `GLOSSARY.md` |
| 2026-10-27 | Asana rewritten for non-technical readers: business questions grouped by the sprint they block, technical detail only on GitHub | Erick | Doc A .41362 |
| 2026-10-27 | App authorised on Nenalina EU and NA; J&G EU not needed for phase 1 (since 28 Oct the JG tokens are a task in the JG preparation section) | Sarina (authorisation), Erick (check) | Doc A .37271; Asana 1219960974323506 |
| 2026-10-28 | Timeline revised: UAT inside the DE go-live week 4–8 Jan; other Nenalina 11–15 Jan; monitoring to 15 Feb; JG phase 2 from 15 Feb; CA decommission after the JG gate; Nitya's artifact becomes the timeline source of truth | Erick, Nitya, Sahat (meeting) | Doc A .57223; Nitya's artifact rev 57 |
| 2026-10-28 | Asana restructured: S5 = Go-live DE + UAT, S6 = Go-live other Nenalina, S7 deleted, new section "Monitoring + JG preparation", S8 undated | Erick (coordinator executed) | Asana sections (read 2026-10-28) |
| 2026-10-28 | **Scope = 20 Nenalina channels per the sheet**, only AN.DT closed; UK and US get FBA stock and price (GBP/USD); MX and CA orders and returns. Supersedes the 20 Oct proposal of 14 (.37116) and the morning's 16 (.60881) | Erick; confirmed by Nitya | Doc A .65324, .67265; Asana 1219919783909992 (03:33Z, 03:34Z), 1219919921404437 (07:24Z); map #5967 Notes |

## Business answers from the BA

| Date | Answer | Where |
|---|---|---|
| 2026-10-28 | FBA orders enter Manobo only once SHIPPED, as with ChannelAdvisor; no new rule | Asana 1219920153544152 (05:27Z); Doc A .68082; map #5967 |
| 2026-10-28 | Seller SKU: FBA = real SKU, FBM = real SKU + `-FBM`. The listing-ownership half is unanswered | Asana 1219919921458898 (06:51Z); Doc A .70046; #5986 c6463275311 |
| 2026-10-28 | UK: import the orders, keep a UK channel | Asana 1219921642535113 (07:18Z); Doc A .70555 |
| 2026-10-28 | Old-order PII: the BA will have users tick the PII field in the sales-channel setting, as an After Release Task (ART): decided with Sarina before go-live; if agreed, a post-release task enables PII redaction per channel and the developer verifies the process; not blocking S1 (Erick, 28 Oct) | Asana 1219922605431756 (07:21Z); Doc A .70800 |
| 2026-10-28 | JG phase 2 = 12 channels: AM.DE (FBM), AM.DF/AM.UF/AM.US (FBA), 8 ES/FR/IT/NL order-only. AM.US stays on her list although Doc A recommends closing it; the JG BRD decides | Asana 1219919783909992 (03:34Z); Doc A .67265 |
