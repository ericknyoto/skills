# Open state

**As of 2026-10-30, about 09:30 UTC** (S1 spec added; the rest as of about 05:00 UTC). The fastest-staling file here; everything time-sensitive is confined to it.
Re-verify with `verification.md` before acting on a line. Only live state stays here: a line that is settled moves
to [timeline.md](timeline.md) and to the Decisions of its flow file.

**Who updates what:** map, ticket and PR lines: Wayfinder sessions. Asana, Doc A and BRD lines: the coordinator.

## Pull requests

No Amazon ADR PR is open. Merges and closures, with commits: [timeline.md](timeline.md).

## S1 spec 6062

- Published 2026-10-30 with `to-spec` (label `ready-for-agent`), linked from map #5967 (issuecomment-6518285175).
- **Ticketed 2026-10-30, nothing implemented.** Erick approved the breakdown, the test seams and the six added
  decisions (recorded in the flow files). Implementation waits for Erick's go for S1.
  - **Tickets:** #6064–#6077, all sub-issues of #6062 with native blocked-by edges; listed in #6062
    issuecomment-6519040956.
  - **Frontier:** #6064 (skeleton), #6065 (integrator column), #6066 (BR-3).
  - **HITL:** #6067 (server credentials) and #6073 (the 20 keys); their production steps follow the parent deploy.
  - **Branching:** parent `6062-amazon-seller-s1-foundation` → children `6062-<ticket>-<slug>` → one PR to `master`.
    #6066 is the exception: Erick: "Boleh", read as BR-3 shipping early from its own branch straight to `master`.
- **Covers:** the SP-API transport, the feeds primitive, `config/amazon.php` and its env names (local names kept;
  new: `AMAZON_SELLER_GOOGLE_CHAT_WEBHOOK_URL`, `AMAZON_SELLER_SWITCH_ENABLED`), the connection check, the integrator
  column and switch (skip rule, duplicate guard, switch command), the channel keys for the 20 channels (filled by form;
  AN.DT none), the flow rule table and gate, `amazon_seller_failures`, alarms, watchdog, digest, the supervisor, BR-3.
- **Left out on purpose:** the SKU mapping table's design (#5978 → #5986), the DE reconciliation report, the order
  pull, and the `shipment_id` scheme with `amazon_seller_order_items`. Doc A's backlog row (.21248) puts the last two
  in S1; the spec defers them to the order-import spec, pending Erick.
- Updated 2026-10-30: `balance => false` on the supervisor ([decision](flows/monitoring-and-failures.md#supervisor-balance-false)).
- **Still open for Erick:** the Doc A backlog deferral above (`shipment_id` scheme and raw-money table out of S1). It
  was not part of his "Setuju".

## Map tickets

Map #5967: 16 of 29 tickets closed. Blockers from GitHub issue dependencies, read 2026-10-30 (closures in
[timeline.md](timeline.md)):

| # | Kind | Question | Blocked by |
|---|---|---|---|
| 6040 | grilling | Refund flows: FBA refund pull source, already-refunded guard, per-unit feed values, does the adjustment feed accept FBA orders (S2 gate: closes before 23 Nov) | #6039 |
| 5978 | grilling | SKU mapping table and the DE reconciliation report (S1 exit includes the report: grilled inside S1 once #5986 is answered, closes before 23 Nov at the latest; #5989 blocker removed 30 Oct, c6517816695) | #5986 |
| 5979 | grilling | FBA stock import: target warehouse, Amazon as source of truth (S2 gate: closes before 23 Nov) | #5987, #5989 |
| 6012 | grilling | Price flow: Manobo price fields → `list_price`/`purchasable_offer`, write mechanism (S2 gate: closes before 23 Nov) | #5978, #6013 |
| 6052 | grilling | FBM stock push: trigger (event vs sweep, cadence), write mechanism (patchListingsItem vs JSON_LISTINGS_FEED), SKUs and marketplaces written (S2 gate: closes before 23 Nov; graduated from #5977, 30 Oct) | #5978 |
| 5986 | BRD input | Listing ownership after Rithum (A3); the SKU half is answered | — |
| 5987 | BRD input | Which warehouse holds FBA stock; is Amazon's figure the truth (A9) | — |
| 5988 | BRD input | FBA buyer name and address, or request the Tax Invoicing role now (A11) | — |
| 5989 | BRD input | BRD P0+P1 signed off: the S2 build gate, due 20 Nov (moved off S0 by Erick, 28 Oct; GitHub title and body updated) | #5986, #5987, #5988, #6013, #6039 |
| 6006 | BRD input | Release-freeze exception for the go-live weeks and the S4 real test orders (retitled 30 Oct; the November shadow-pull half withdrawn when shadow mode was dropped, c6516463236) | — |
| 6013 | BRD input | Price fields (UVP, selling, promo), FBM = FBA, UK/US GBP/USD flows. Price half answered (Asana 1219919849429744 completed 29 Oct); waits only on the UK/US `_foreign` confirmation (1219919783909992) | — |
| 6039 | BRD input | Returns opened on Amazon, shipping refund, and who refunds FBA goods sent back to Hamburg (Asana 1219920153544278) | — |

Map Destination names five S2-gate tickets since 30 Oct: #5978, #5979, #6012, #6040, #6052. No ticket that gates S1 (9 Nov) is open since #5985 closed (30 Oct 07:34Z, c6517469235); every open grilling ticket waits on BRD inputs (#5976 closed 30 Oct).

Unticketed fog on the map ("Not yet specified"): order mapping v2026 (waits for #5988), the confirmShipment
carrier map, the runbook of the 11–15 Jan week across both tokens,
the months-long ChannelAdvisor overlap, updates to an already imported order, the re-import trigger for an Amazon order whose
import failed (the poll's watermark moves past it; added 30 Oct), UK and US FBA stock flows, how
Finance and Warehouse handle UK orders, and an Admin Tool page for Amazon failure rows if resolving by command stops scaling (#5977).

## Asana business questions

All assigned to Nitya; 6 completed (their answers are in the flow files' Decisions, the completions in
[timeline.md](timeline.md)). Project `1219919921535476`, section Business decisions. Open tasks:

| Task | Question (short) | Due | State |
|---|---|---|---|
| 1219919849816117 | FBA orders without buyer address: accept, or request Tax Invoicing now | 2026-11-06 | Nitya asked a colleague 10-27 who uses FBA name/street; no answer |
| 1219919921404437 | Confirm scope 20 in the BRD | 2026-11-06 | confirmed 10-28 07:24Z; task completed 10-28 08:30Z |
| 1219919921458898 | Listing ownership after Rithum; SKU format | 2026-11-20 | SKU format answered 10-28; 08:54Z: `-L` only on old products, other alternate formats may come; ownership and `-L` mapping open |
| 1219920153543831 | PIC per department; who contacts Rithum | 2026-11-06 | asked 10-27; no answer |
| 1219921642535113 | UK orders: import, ignore or report (BD-20) | 2026-11-06 | "import" 10-28 07:18Z; task completed 10-28 08:30Z; Finance/Warehouse handling still open in the BRD |
| 1219920153544088 | Which warehouse holds FBA stock; Amazon as truth | 2026-11-20 | FC list asked 10-27; 10-28 08:56Z 'not a problem, FBA stock not used today', warehouse waits for Andreas; early go-live question unanswered |
| 1219919864498676 | Build International Listings active; copies DE quantity? | 2026-12-04 | no comment |
| 1219920153544278 | Returns opened on Amazon: who records them; shipping refund? (#6039) | 2026-12-04 | 29 Oct 13:18Z (IT, @Nitya, story 1220015351242263): FBA goods sent back to Hamburg (13 in 12 months; ChannelAdvisor accepted the refund for 7) stay refunded automatically with an already-refunded check, or CS refunds in Seller Central? No answer |
| 1219961077776438 | Release-freeze exception for 4–8 and 11–15 Jan (#6006) | 2026-12-04 | 30 Oct 06:28Z (IT, @Nitya, story `1220042985779007`): the November shadow-pull half (stories `1220040996798747`, `1220041582460983`) is withdrawn, no shadow mode; notes narrowed. Remaining, due 4 Dec: the go-live-weeks exception (or an earlier end of Christmas business) and whether the S4 real test orders (21 Dec–1 Jan) count as a release. Nitya's 04:38Z question (data straight into Central? FBM/FBA?) answered as moot |
| 1219919783909992 | UK/US FBA stock + price flows and GBP/USD fields | 2026-12-04 | flows confirmed 10-28; 29 Oct: asked to confirm the `_foreign` price columns (GBP/USD already held for 74 UK / 5 US products) feed Amazon with the DE mapping; a wrong 'EUR only' comment was corrected the same day |
| 1219919983346126 | Cutover window, sync pause, hypercare length | 2026-12-18 | no comment |
| 1219920153543863 | Success measures; future of the 20 non-Amazon Rithum channels | 2026-11-20 | no comment |

- Asana A9 task 1219920153544088 got a second question on 28 Oct 08:36Z (mention): may the FBA stock import go live
  before the peak, separately from the January go-live? Sarina decides. Not yet in Doc A (open question, not a decision).
- `-L` FBA listings: the BA was asked on Asana 1219919921458898 what `-L` means, who created the listings, and whether
  they map to the real SKU (comment 07:58Z, 28 Oct). Answer pending.

## Pending for Nitya beyond those tasks

- Her question, relayed by Erick on 2026-10-28: what is the "S1 BRD", and is a BRD needed for technical-only
  work? No answer recorded yet (coordinator ledger).
- The sheet's "(manually)" note on AN.KB and AN.UB: which part stays manual is open in her artifact.
- Monitoring measures for the JG gate (0 duplicates, 0 oversells, no open failures) are proposed, not approved;
  the gate owner is "not decided yet".
- AM.US, close or keep: the JG BRD decides ([JG phase 2 decision](flows/governance-and-timeline.md#jg-phase-2-is-12-channels)).
- Cosmetic, her side: the S7 row of her artifact lists AN.KB, AN.MB and AN.CB twice.

## Doc A housekeeping

- Rev 192 (2026-10-30), last log row `.91480`. **Not yet logged as their own rows:** the UK "import" answer and the
  scope confirmation of 28 Oct 07:24Z (Asana rows above); the PII answer has `.72438`.
- Stale text to annotate whenever someone edits Doc A: each trap (in `traps.md` and in the flow files' Traps
  sections) names the row carrying the old belief; in addition `.61615`, `.66078` and `.69284` say a PR is open, and
  `.13900` says the crontab is unknown (#5984 answered it).
- Comment thread `5ecc379a-ca64` (J&G question on `.435`) is open; the text answers it, no reply posted.

## Julie and Grace phase 2

Section "Monitoring + JG preparation" `1219961007589210`: JG BRD and new estimate (Nitya, due 2027-02-12,
`1219961077375828`); JG tokens, EU plus NA only if AM.US stays (due 2027-01-29, `1219960974323506`); JG go-live
(due 2027-04-09, `1219960974364987`); one month of Nenalina monitoring (due 2027-02-15, `1219961212395356`).
Phase 2 gets its own BRD and its own wayfinder map; nothing for it is ticketed on GitHub yet.

## Deadlines ahead

- **6 Nov 2026, S0 exit** (Asana milestone `1219919783880756`): Frank's go, scope approved, and the Tax Invoicing
  answer (#5988, Asana `1219919849816117`; Amazon's role approval takes weeks). The BRD sign-off is no longer here.
  Erick owes "Close the technical decisions for the foundation" (`1219919783869671`). The LWA secret rotation
  (`1219920153548672`, #5985) is done: [data-protection.md](flows/data-protection.md#5985-lwa-secrets).
- **9 Nov 2026:** S1 starts if the map destination holds; S1 waits on no business answer (Erick, 28 Oct), only Frank's go.
- **20 Nov 2026:** BRD P0+P1 sign-off (#5989, Asana `1219919921548797`), the gate for the S2 build starting 23 Nov.
  - BRD requirement posted on that task 30 Oct 03:56Z (IT, @Nitya, story `1220041038186030`): who receives the daily
    06:00 Amazon failure digest and the immediate refund/cancel failure alert; first comment named "Order N8N" as the
    default; corrected the same day by Erick (story `1220041038698373`): a NEW dedicated Google Chat space for Amazon,
    name and members per BRD. No answer yet. The n8n rule behind it: [monitoring-and-failures.md](flows/monitoring-and-failures.md#no-n8n-in-amazon-core-processes).
  Listing ownership `1219919921458898` and PIC `1219920153543831` are "Blocks S2", due 20 Nov.
- **4 Dec 2026:** DPP obligations task `1219919783910025` (story `1220043191951545`): Sentry `sql_bindings` off and
  Nightwatch checked before the first production SP-API read that returns PII, now the go-live order import.
- **19 Feb 2027:** LWA rotation reminder (#5985), in Erick's Google Calendar (09:00 WITA, set 30 Oct): sandbox
  `Manobo-2008` is due 2027-03-22, `Manobo-2008-Sellers` 2027-04-28; every copy of a secret is updated within 7 days.

## Known-unfixed, no issue yet

- The ChannelAdvisor import stores Amazon FBA item promotions (`PLM-…`, since 2026-10-27) as if the net discount were
  gross, or drops the item discount when a shipping discount is present: 15 of 258 DE items in the #5976 diff, Manobo too
  high by up to 20.16 EUR per order ([orders-import trap](flows/orders-import.md#manobos-promotion-amounts-are-amazons-gross-discount)).
  Reported to Erick by the coordinator, 30 Oct; not a map ticket.
- `DownloadOrdersFromChanneladvisorJob::handle()` writes the full CA refresh token into the error log on failure
  (#5984 side finding).
- The exchange-rate cron's silent partial refresh ([orders-import.md](flows/orders-import.md#order-money); #5980 recommends a fix).
- Rotated production `marketplaces.type` values (B2B invoice sender) and the dead row-48 direct import, whose
  `folder_name` the Admin Tool still reads: both #5973 cleanup candidates.
- `GLOSSARY.md` on master (JngSp entry) still calls ADR 0132 "Proposed".
- ADR 0111's stale Context line about literal secrets awaits an erratum (#5968; unscheduled).
- The AM.DF order of the Nenalina EU account and the stuck `R` downloads ([orders-import.md](flows/orders-import.md#amazon-orders-that-never-reach-manobo)):
  not investigated, and no bulk action without approval.
- A Manobo ↔ Shopify direct project, also dropping ChannelAdvisor, exists per Erick; nothing for it in manobo-2008
  yet (coordinator ledger, 2026-10-28).
- `ProcessChannelAdvisorRefundOrdersAction` (the CA FBA refund pull) looks orders up by `order_id` with no channel or
  seller-account scope, and drops the refund of an item already marked returned with a log line only (#5974 side
  finding; listed in #6040 as behaviour not to copy).
- Follow-up candidate after the BA answers #6039: a fulfilment check on `ProcessReturnB2cToChanneladvisorListener`
  during the ChannelAdvisor overlap (ADR 0138 rule 7 leaves it unchanged).
