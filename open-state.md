# Open state

**As of 2026-10-30, about 05:00 UTC.** The fastest-staling file here; everything time-sensitive is confined to it.
Re-verify with `verification.md` before acting on a line.

## Decisions taken late on 2026-10-28

- `-L` FBA listings: **no data fix before the migration** (Erick, 'Tetap tunggu'). The 138 DE FBA `-L` SKUs stay as input to #5978 (comment issuecomment-6463784061); the BA was asked on Asana 1219919921458898 what `-L` means, who created the listings, and whether they map to the real SKU (comment 07:58Z). Answer pending. Doc A .71715 (rev 160).

- Asana Business-decisions tasks **completed**: 28 Oct (Erick: answered and locked) scope 20 channels 1219919921404437, UK orders = import 1219921642535113, FBA orders only once SHIPPED 1219920153544152; 29 Oct: FBM stock without buffer 1219919783814613, price mapping + FBM/FBA per channel 1219919849429744, historical PII 1219922605431756 (Erick himself, 04:17Z: After Release Task). Still open there: buyer address/Tax Invoicing, listing ownership + `-L`, PIC per department, FBA warehouse, BIL,  returns, cutover window, release freeze, UK/US GBP/USD price fields, success measures.

- Asana A9 task 1219920153544088 got a second question on 28 Oct 08:36Z (mention): may the FBA stock import go live before the peak, separately from the January go-live? Sarina decides. Not yet in Doc A (open question, not a decision).

- **BRD sign-off moved to 20 Nov as the S2 gate** (Erick, 28 Oct): dates and Asana ids under "Deadlines ahead" below; Doc A .73109 (rev 162); map #5967 Destination names the S2-gate tickets (four since 29 Oct, see the map table).

## Pull requests

- #6053 (ADR 0139, Accepted) merged 2026-10-30 04:45Z (`b53a9b8971`).
- #6055 (ADR 0140, shadow mode) closed unmerged 2026-10-30: Erick and the BA dropped shadow mode the same day. Branch `5976-adr-amazon-shadow-mode` kept at `49b5e2f386`. No Amazon ADR PR is open.
- #6041 (ADR 0138, Accepted) merged 2026-10-30 03:41Z (`238de6e6d8`).
- #6008 (ADR 0134) merged 2026-10-29 12:55Z (`58eea8e9ea`).
- Merged on 2026-10-28, in this order: #5994 (ADR 0131, head `6440c7feda`) 06:52Z, #5995 (ADR 0133) 06:59Z,
  #6007 (ADR 0132) 07:14Z. #5990, #5992, #5993 merged on 2026-10-27.

## Map #5967 — 16 of 29 tickets closed

Blockers from GitHub issue dependencies, read 2026-10-30 (#5985 closed that day: LWA rotation, issuecomment-6517469235; #5976 closed that day, then ruled out of scope: no shadow mode, issuecomment-6516457748; #5977 the same day: issuecomment-6514635367; #5974 on 29 Oct: issuecomment-6497734388):

| # | Kind | Question | Blocked by |
|---|---|---|---|
| 6040 | grilling | Refund flows: FBA refund pull source, already-refunded guard, per-unit feed values, does the adjustment feed accept FBA orders (S2 gate: closes before 23 Nov) | #6039 |
| 5978 | grilling | SKU mapping table and the DE reconciliation report (S2 gate: closes before 23 Nov, not before S1) | #5986, #5989 |
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

All assigned to Nitya; 6 completed (see above). Project `1219919921535476`, section Business decisions.

| Task | Question (short) | Due | State |
|---|---|---|---|
| 1219919849816117 | FBA orders without buyer address: accept, or request Tax Invoicing now | 2026-11-06 | Nitya asked a colleague 10-27 who uses FBA name/street; no answer |
| 1219919921404437 | Confirm scope 20 in the BRD | 2026-11-06 | confirmed 10-28 07:24Z; still open |
| 1219919921458898 | Listing ownership after Rithum; SKU format | 2026-11-20 | SKU format answered 10-28; 08:54Z: `-L` only on old products, other alternate formats may come; ownership and `-L` mapping open |
| 1219920153543831 | PIC per department; who contacts Rithum | 2026-11-06 | asked 10-27; no answer |
| 1219921642535113 | UK orders: import, ignore or report (BD-20) | 2026-11-06 | "import" 10-28 07:18Z; Finance/Warehouse handling open |
| 1219922605431756 | Redact PII of 70,793 old orders now or from go-live (BD-21) | 2026-12-18 (was 11-06; task renamed "Before go-live (After Release Task)") | **completed by Erick 29 Oct 04:17Z** (intentional: After Release Task, decided with Sarina before go-live, no closing comment on Asana). Previous state: 10-28 07:21Z "BA will inform users to mark the PII field in the sales-channel setting; part of the ART task"; not blocking S1 (Erick, 28 Oct). Doc A .72438 |
| 1219920153544088 | Which warehouse holds FBA stock; Amazon as truth | 2026-11-20 | FC list asked 10-27; 10-28 08:56Z 'not a problem, FBA stock not used today', warehouse waits for Andreas; early go-live question unanswered |
| 1219920153544152 | FBA orders from Unshipped or only once shipped | 2026-11-20 | answered 10-28: only once shipped |
| 1219919783814613 | FBM stock = full Hamburg stock or minus buffer | 2026-12-04 | **answered and completed 29 Oct**: full stock, no buffer (Anja + Nitya 10-28) |
| 1219919864498676 | Build International Listings active; copies DE quantity? | 2026-12-04 | no comment |
| 1219919849429744 | UVP, selling and promo fields; FBM price = FBA? (#6013) | 2026-12-04 | **completed 29 Oct**: mapping locked; FBM/FBA = separate rows, may differ (Erick) |
| 1219920153544278 | Returns opened on Amazon: who records them; shipping refund? (#6039) | 2026-12-04 | 29 Oct 13:18Z (IT, @Nitya, story 1220015351242263): FBA goods sent back to Hamburg (13 in 12 months; ChannelAdvisor accepted the refund for 7) stay refunded automatically with an already-refunded check, or CS refunds in Seller Central? No answer |
| 1219961077776438 | Release-freeze exception for 4–8 and 11–15 Jan (#6006) | 2026-12-04 | 30 Oct 06:28Z (IT, @Nitya, story `1220042985779007`): the November shadow-pull half (stories `1220040996798747`, `1220041582460983`) is withdrawn, no shadow mode; notes narrowed. Remaining, due 4 Dec: the go-live-weeks exception (or an earlier end of Christmas business) and whether the S4 real test orders (21 Dec–1 Jan) count as a release. Nitya's 04:38Z question (data straight into Central? FBM/FBA?) answered as moot |
| 1219919783909992 | UK/US FBA stock + price flows and GBP/USD fields | 2026-12-04 | flows confirmed 10-28; 29 Oct: asked to confirm the `_foreign` price columns (GBP/USD already held for 74 UK / 5 US products) feed Amazon with the DE mapping; a wrong 'EUR only' comment was corrected the same day |
| 1219919983346126 | Cutover window, sync pause, hypercare length | 2026-12-18 | no comment |
| 1219920153543863 | Success measures; future of the 20 non-Amazon Rithum channels | 2026-11-20 | no comment |

## Pending for Nitya beyond those tasks

- Her question, relayed by Erick on 2026-10-28: what is the "S1 BRD", and is a BRD needed for technical-only
  work? No answer recorded yet (coordinator ledger).
- The sheet's "(manually)" note on AN.KB and AN.UB: which part stays manual is open in her artifact.
- Monitoring measures for the JG gate (0 duplicates, 0 oversells, no open failures) are proposed, not approved;
  the gate owner is "not decided yet".
- AM.US: Doc A recommends closing it (4 orders a year); her JG list keeps it. The JG BRD decides.
- Cosmetic, her side: the S7 row of her artifact lists AN.KB, AN.MB and AN.CB twice.

## Doc A housekeeping

- Rev 157, 39 log rows (last `.70046`). **Not yet logged:** the UK "import" answer, the PII answer and the
  scope confirmation of 07:24Z (Asana rows above).
- Stale text to annotate whenever someone edits Doc A: each trap in `traps.md` names the row carrying the old
  belief; in addition `.61615`, `.66078` and `.69284` say a PR is open, and `.13900` says the crontab is unknown
  (#5984 answered it).
- Comment thread `5ecc379a-ca64` (J&G question on `.435`) is open; the text answers it, no reply posted.

## ChannelAdvisor DE leak

Decided 2026-10-28: wait for the migration (`decisions.md`). Do not re-raise unless asked. The service-api
single-page read stays a follow-up candidate, unticketed.

## Julie & Grace phase 2

Section "Monitoring + JG preparation" `1219961007589210`: JG BRD and new estimate (Nitya, due 2027-02-12,
`1219961077375828`); JG tokens, EU plus NA only if AM.US stays (due 2027-01-29, `1219960974323506`); JG go-live
(due 2027-04-09, `1219960974364987`); one month of Nenalina monitoring (due 2027-02-15, `1219961212395356`).
Phase 2 gets its own BRD and its own wayfinder map; nothing for it is ticketed on GitHub yet.

## Deadlines ahead

- **6 Nov 2026, S0 exit** (Asana milestone `1219919783880756`): Frank's go, scope approved, and the Tax Invoicing
  answer (#5988, Asana `1219919849816117`; Amazon's role approval takes weeks). The BRD sign-off is no longer here. Erick owes "Close the technical decisions for the foundation" (`1219919783869671`) and the LWA secret
  rotation (`1219920153548672`, #5985; done on GitHub 30 Oct 07:34Z).
- **9 Nov 2026:** S1 starts if the map destination holds; S1 waits on no business answer (Erick, 28 Oct), only Frank's go.
- **20 Nov 2026:** BRD P0+P1 sign-off (#5989, Asana `1219919921548797`), the gate for the S2 build starting 23 Nov.
  - S1 section, 30 Oct 06:28Z (no shadow mode): "Shadow order pull live in production" `1219919864565642` completed as not needed (story `1220043125747003`, @Nitya); the BR-3 task `1220041626125348` (created earlier that day) DELETED, its obligation back on `1219919783910025` (DPP obligations, due 4 Dec, story `1220043191951545`): Sentry `sql_bindings` off and Nightwatch checked before the first production SP-API read that returns PII, now the go-live order import. S1 exit `1219919983244087` renamed "SP-API client, channel switch and monitoring built; DE SKU reconciliation report ready"; S2 exit `1219919864236215` renamed "FBA stock visible in Manobo". Doc A: log row `.88693` (rev 183) + body rows .7171/.21596/.8380/.8656 rewritten (rev 188).
  - BRD requirement posted on that task 30 Oct 03:56Z (IT, @Nitya, story `1220041038186030`): who receives the daily 06:00 Amazon failure digest and the immediate refund/cancel failure alert; first comment named "Order N8N" as the default; corrected the same day by Erick (story `1220041038698373`): a NEW dedicated Google Chat space for Amazon, name and members per BRD. Standing rule from Erick (30 Oct): Amazon core flows run in Manobo only, no n8n; n8n only for notifications and similar, and every n8n plan is confirmed with Erick first. No answer yet.
  Listing ownership `1219919921458898` and PIC `1219920153543831` are "Blocks S2", due 20 Nov.
- **20 Feb 2027:** LWA rotation reminder (#5985): sandbox `Manobo-2008` is due 2027-03-22, `Manobo-2008-Sellers`
  2027-04-28; every copy of a secret is updated within 7 days. Erick owes the Ops calendar entry.

## Known-unfixed, no issue yet

- The ChannelAdvisor import stores Amazon FBA item promotions (`PLM-…`, since 2026-10-27) as if the net discount were
  gross, or drops the item discount when a shipping discount is present: 15 of 258 DE items in the #5976 diff, Manobo too
  high by up to 20.16 EUR per order (`traps.md`). Reported to Erick by the coordinator, 30 Oct; not a map ticket.
- `DownloadOrdersFromChanneladvisorJob::handle()` writes the full CA refresh token into the error log on failure
  (#5984 side finding).
- The exchange-rate cron's silent partial refresh (`facts.md` → Order money; #5980 recommends a fix).
- Rotated production `marketplaces.type` values (B2B invoice sender) and the dead row-48 direct import, whose
  `folder_name` the Admin Tool still reads: both #5973 cleanup candidates.
- `GLOSSARY.md` on master (JngSp entry) still calls ADR 0132 "Proposed".
- ADR 0111's stale Context line about literal secrets awaits an erratum (#5968; unscheduled).
- The AM.DF order of the Nenalina EU account and the stuck `R` downloads (`facts.md`): not investigated, and no bulk
  action without approval.
- A Manobo ↔ Shopify direct project, also dropping ChannelAdvisor, exists per Erick; nothing for it in manobo-2008
  yet (coordinator ledger, 2026-10-28).
- `ProcessChannelAdvisorRefundOrdersAction` (the CA FBA refund pull) looks orders up by `order_id` with no channel or
  seller-account scope, and drops the refund of an item already marked returned with a log line only (#5974 side
  finding; listed in #6040 as behaviour not to copy).
- Follow-up candidate after the BA answers #6039: a fulfilment check on `ProcessReturnB2cToChanneladvisorListener`
  during the ChannelAdvisor overlap (ADR 0138 rule 7 leaves it unchanged).
