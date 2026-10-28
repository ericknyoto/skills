# Open state

**As of 2026-10-28, about 08:00 UTC.** The fastest-staling file here; everything time-sensitive is confined to it.
Re-verify with `verification.md` before acting on a line.

## Decisions taken late on 2026-10-28

- `-L` FBA listings: **no data fix before the migration** (Erick, 'Tetap tunggu'). The 138 DE FBA `-L` SKUs stay as input to #5978 (comment issuecomment-6463784061); the BA was asked on Asana 1219919921458898 what `-L` means, who created the listings, and whether they map to the real SKU (comment 07:58Z). Answer pending. Doc A .71715 (rev 160).

- Asana Business-decisions tasks **completed on 28 Oct** (Erick: answered and locked): scope 20 channels 1219919921404437, UK orders = import 1219921642535113, FBA orders only once SHIPPED 1219920153544152. Still open there: buyer address/Tax Invoicing, listing ownership + `-L`, PIC per department, PII (before go-live), FBA warehouse, FBM buffer, BIL, price fields, returns, cutover window, release freeze, UK/US GBP/USD price fields, success measures.

- Asana A9 task 1219920153544088 got a second question on 28 Oct 08:36Z (mention): may the FBA stock import go live before the peak, separately from the January go-live? Sarina decides. Not yet in Doc A (open question, not a decision).

- **BRD sign-off moved to 20 Nov as the S2 gate** (Erick, 28 Oct): S1 code needs no business answer; by 9 Nov only Frank's go decision and the Tax Invoicing answer (Asana 1219919849816117, due 6 Nov) are required. Asana: BRD task 1219919921548797 due 20 Nov in section S1; S0-exit task retitled; listing-ownership 1219919921458898 and PIC 1219920153543831 are "Blocks S2", due 20 Nov. #5989 move requested from the map session. Brief doc and Doc A being updated.

## Pull requests

- **#6008** (ADR 0134, branch `5973-adr-amazon-channel-config`, head `4c531081ee`): open. Mergeable but blocked —
  review required, and the "Entire Gates" check failed (not investigated); the branch is behind master. It was
  to merge after #6007, which has merged. Erick merges.
- Merged on 2026-10-28, in this order: #5994 (ADR 0131, head `6440c7feda`) 06:52Z, #5995 (ADR 0133) 06:59Z,
  #6007 (ADR 0132) 07:14Z. #5990, #5992, #5993 merged on 2026-10-27.

## Map #5967 — 13 of 26 tickets closed

Blockers from GitHub issue dependencies, read 2026-10-28:

| # | Kind | Question | Blocked by |
|---|---|---|---|
| 5974 | grilling | Write-flow gating by fulfilment channel (FBM-only, FBA-only flows) | nothing open: **next to grill** |
| 5977 | grilling | Monitoring per flow: failure table, notifications, queues, cadence | #5974 |
| 5976 | grilling | Shadow mode: comparison table and diff report during peak | #6006 |
| 5978 | grilling | SKU mapping table and the DE reconciliation report | #5986, #5989 |
| 5979 | grilling | FBA stock import: target warehouse, Amazon as source of truth | #5987, #5989 |
| 6012 | grilling | Price flow: Manobo price fields → `list_price`/`purchasable_offer`, write mechanism | #5978, #6013 |
| 5985 | task | Rotate the LWA client secret; store it in staging and production | — |
| 5986 | BRD input | Listing ownership after Rithum (A3); the SKU half is answered | — |
| 5987 | BRD input | Which warehouse holds FBA stock; is Amazon's figure the truth (A9) | — |
| 5988 | BRD input | FBA buyer name and address, or request the Tax Invoicing role now (A11) | — |
| 5989 | BRD input | BRD P0+P1 signed off: the S0 exit gate | #5986, #5987, #5988, #6013 |
| 6006 | BRD input | Release-freeze exception for the go-live weeks; is the November shadow pull a release | — |
| 6013 | BRD input | Price fields (UVP, selling, promo), FBM = FBA, UK/US GBP/USD flows | — |

Unticketed fog on the map ("Not yet specified"): order mapping v2026 (waits for #5988), the confirmShipment
carrier map, refund feed values and the FBA refund source, the runbook of the 11–15 Jan week across both tokens,
the months-long ChannelAdvisor overlap, updates to an already imported order, UK and US FBA stock flows, and how
Finance and Warehouse handle UK orders.

## Asana business questions

All assigned to Nitya, none completed. Project `1219919921535476`, section Business decisions.

| Task | Question (short) | Due | State |
|---|---|---|---|
| 1219919849816117 | FBA orders without buyer address: accept, or request Tax Invoicing now | 2026-11-06 | Nitya asked a colleague 10-27 who uses FBA name/street; no answer |
| 1219919921404437 | Confirm scope 20 in the BRD | 2026-11-06 | confirmed 10-28 07:24Z; still open |
| 1219919921458898 | Listing ownership after Rithum; SKU format | 2026-11-06 | SKU format answered 10-28; ownership open |
| 1219920153543831 | PIC per department; who contacts Rithum | 2026-11-06 | asked 10-27; no answer |
| 1219921642535113 | UK orders: import, ignore or report (BD-20) | 2026-11-06 | "import" 10-28 07:18Z; Finance/Warehouse handling open |
| 1219922605431756 | Redact PII of 70,793 old orders now or from go-live (BD-21) | 2026-12-18 (was 11-06; task renamed "Before go-live (After Release Task)") | 10-28 07:21Z: "BA will inform users to mark the PII field in the sales-channel setting; part of the ART task". ART = After Release Task: decided with Sarina before go-live, post-release task if agreed; not blocking S1 (Erick, 28 Oct). Doc A .72438 |
| 1219920153544088 | Which warehouse holds FBA stock; Amazon as truth | 2026-11-20 | Nitya asked for the FC list 10-27; no answer |
| 1219920153544152 | FBA orders from Unshipped or only once shipped | 2026-11-20 | answered 10-28: only once shipped |
| 1219919783814613 | FBM stock = full Hamburg stock or minus buffer | 2026-12-04 | Nitya's understanding "no buffer" awaits confirmation |
| 1219919864498676 | Build International Listings active; copies DE quantity? | 2026-12-04 | no comment |
| 1219919849429744 | UVP, selling and promo fields; FBM price = FBA? (#6013) | 2026-12-04 | no comment |
| 1219920153544278 | Returns opened on Amazon: who records them; shipping refund? | 2026-12-04 | no comment |
| 1219961077776438 | Release-freeze exception for 4–8 and 11–15 Jan (#6006) | 2026-12-04 | no comment |
| 1219919783909992 | UK/US FBA stock + price flows and GBP/USD fields | 2026-12-04 | flows confirmed 10-28; price fields open |
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

- **6 Nov 2026, S0 exit** (Asana milestone `1219919783880756`): Frank's go, BRD P0+P1 signed (#5989), scope
  approved. Erick owes "Close the technical decisions for the foundation" (`1219919783869671`) and the LWA secret
  rotation (`1219920153548672`, #5985).
- **9 Nov 2026:** S1 starts if the map destination holds.

## Known-unfixed, no issue yet

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
