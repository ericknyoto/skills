# Timeline

One line per dated event, oldest first: decisions, PR merges, ticket closures, Asana completions, production data
changes, and from S1 on every deploy, channel switch and incident (one line the same day). Within a day, lines with a
UTC time come first in time order; lines without a time follow in the order their sources give and are not placed in
time. The detail of each decision is in its flow file ([index.md](index.md)); live state is in [open-state.md](open-state.md).

## Before the project

- 2023-07-09 — The ChannelAdvisor stock cron runs for the last time; stock goes to CA by event since (#5984).
- 2024-03-10 — Last AN.KB (UK) order in Manobo (859 orders, December 2023 – March 2024).
- 2025-12-03 — Amazon removes the legacy inventory and price feeds (Doc A .3057).
- 2026-01-28 — Orders v0 deprecated; its read operations are removed 2027-03-27; `confirmShipment` is not deprecated (Doc A .3057; #5982).

## 2026-10

- 2026-10-20 — S0 begins (S0–S4 run 20 Oct 2026 – 1 Jan 2027).
- 2026-10-20 — Erick: build directly in `manobo-2008`, `manobo-service-api` deprecated (Doc A .36931).
- 2026-10-20 — Doc A proposes 14 channels (.37116) and crosses UK out because AN.KB had no order since 2024-03-10.
- 2026-10-27 06:10Z — PR #5990 merged: ADR 0128 (`0a9a6dc05d`).
- 2026-10-27 06:39Z — PR #5992 merged: ADR 0130 (`7447372323`).
- 2026-10-27 06:46Z — PR #5993 merged: ADR 0129 (`cdbedc6282`).
- 2026-10-27 — Erick: PO = Sarina Seigis, BA = Nitya; BRD for business, grilling for technical (Doc A .37485, .37571).
- 2026-10-27 — Erick: Doc A is the source of truth, new Asana project, GitHub map; July project `1216749791369428` superseded (Doc A .37729).
- 2026-10-27 — Erick: every business task goes to Nitya, never Sarina (Doc A .38822).
- 2026-10-27 — Erick: Amazon DPP obligations BR-1 … BR-6 stay binding (Doc A .38010).
- 2026-10-27 — Erick: map destination "S1 can start", one map per gate (Doc A .38199, .41106).
- 2026-10-27 — Erick: research agents may use production read-only (Doc A .38368).
- 2026-10-27 — Erick: canonical terms Integrator, Seller account, Fulfilment channel (Doc A .38540).
- 2026-10-27 — Erick: Asana rewritten for non-technical readers (Doc A .41362).
- 2026-10-27 — Sarina authorises the app on Nenalina EU and NA; 8 of 10 self-authorisations left (Doc A .37271).
- 2026-10-27 — #5981 outcome: product types NECKLACE/RING/BRACELET, not JEWELRY (Doc A .39998).
- 2026-10-27 — #5982 outcome: carrier codes from `amzn-base.xsd`, confirmShipment stays on v0 (Doc A .40195).
- 2026-10-27 — #5983 outcome: personalisation out of P1 scope (Doc A .40399).
- 2026-10-27 — #5980 outcome: hold an order on a missing rate; currency from the Amazon order (Doc A .40608).
- 2026-10-27 — #5984: stop ChannelAdvisor per CA profile or in code, never by removing the cron line (c6435792248).
- 2026-10-27 — #5969 routing probe: Amazon UK ships about 129 FBA orders per 30 days and none reach Manobo.
- 2026-10-27 — Amazon FBA item promotions (`PLM-…`) start appearing on orders; the CA import stores them wrongly (found 30 Oct).
- 2026-10-27 — ADR 0131 accepted (`4cf924d359`); ADR 0133 accepted (`ffd5aa4aaf`).
- 2026-10-28 03:33Z — Scope 20 confirmed on Asana 1219919783909992 (03:33Z, 03:34Z); the BA's JG phase 2 list at 03:34Z.
- 2026-10-28 05:27Z — BA: FBA orders enter Manobo only once SHIPPED (Asana 1219920153544152; Doc A .68082).
- 2026-10-28 06:51Z — BA: seller SKU, FBA = real SKU, FBM = real SKU + `-FBM` (Asana 1219919921458898; Doc A .70046).
- 2026-10-28 06:52Z — PR #5994 merged: ADR 0131 (`3b0e1164cc`, head `6440c7feda`).
- 2026-10-28 06:59Z — PR #5995 merged: ADR 0133 (`d5f55beb6f`).
- 2026-10-28 07:14Z — PR #6007 merged: ADR 0132 (`74b6517496`).
- 2026-10-28 07:18Z — BA: UK orders are imported, a UK channel stays (Asana 1219921642535113; Doc A .70555).
- 2026-10-28 07:21Z — BA: old-order PII is an After Release Task (Asana 1219922605431756; Doc A .70800).
- 2026-10-28 07:24Z — Nitya confirms scope 20 (Asana 1219919921404437).
- 2026-10-28 08:54Z — BA: `-L` only on old products (Asana 1219919921458898; Doc A .75339).
- 2026-10-28 08:56Z — BA (A9): FBA stock not used today (Asana 1219920153544088; Doc A .75339).
- 2026-10-28 08:59Z — BA: price fields A5–A7 (Asana 1219919849429744; Doc A .74487).
- 2026-10-28 09:34Z — Anja, then Nitya at 09:57Z: FBM stock = full Hamburg stock, no buffer (Asana 1219919783814613; Doc A .74043).
- 2026-10-28 19:40–19:50 Berlin — 108 stuck `R` CA downloads go to `I`; 195, 203, 204 and 205 get 486 `-L` rows each in `jng_sp_sku` (a manual fix by Erick's team, confirmed 30 Oct).
- 2026-10-28 — Morning: "Phase 1 is 16 channels" written to Doc A (.60881), Asana and the map; corrected the same day.
- 2026-10-28 — Timeline revised in a meeting of Erick, Nitya and Sahat; Nitya's artifact becomes the date source (Doc A .57223; rev 57).
- 2026-10-28 — Asana restructured: S5 Go-live DE + UAT, S6 Go-live other Nenalina, S7 deleted, "Monitoring + JG preparation" added, S8 undated.
- 2026-10-28 — ADR 0132 Decision 6 rewritten (`e6d86524a8`, `e8ce681973`; Doc A .57985); ADR 0132 accepted (`3ec734103b`).
- 2026-10-28 — ADR 0131 amended (`99c25d18de`, `6440c7feda`); Erick: "Merge begini" and "Per integrator" (Doc A .69284).
- 2026-10-28 — ADR 0134 accepted (`4c531081ee`).
- 2026-10-28 — Erick: scope = 20 Nenalina channels, confirmed by Nitya (Doc A .65324, .67265).
- 2026-10-28 — #5991 (UK orders) closed as "import" (c6460009177).
- 2026-10-28 — Erick: no ticket for the ChannelAdvisor DE import leak, "Tunggu migrasi" (#5970 c6462113723; Doc A .68504).
- 2026-10-28 — #6012 and #6013 created (Erick: "Ya, buat tiket").
- 2026-10-28 — #6006 created for the release-freeze question (Asana 1219961077776438).
- 2026-10-28 — Asana tasks completed (Erick: answered and locked): scope 20 1219919921404437, UK orders 1219921642535113, FBA only once SHIPPED 1219920153544152.
- 2026-10-28 — Erick: `-L` FBA listings get no data fix before the migration, 'Tetap tunggu' (Doc A .71715, rev 160).
- 2026-10-28 — Erick: BRD P0+P1 sign-off moves to 20 Nov as the S2 gate (Doc A .73109, rev 162).
- 2026-10-29 04:06Z — Erick closes the price task: FBM and FBA prices per sales channel, 'Ya, tutup' (Asana 1219919849429744; Doc A .78305).
- 2026-10-29 04:17Z — Erick completes the BD-21 historical-order PII task (Asana 1219922605431756).
- 2026-10-29 12:55Z — PR #6008 merged: ADR 0134 (`58eea8e9ea`).
- 2026-10-29 13:18Z — FBA-goods-returned question posted to Nitya (Asana 1219920153544278, story 1220015351242263).
- 2026-10-29 ~14:10Z — Erick confirms ADR 0138, "Ok setuju", after the refund-feed research.
- 2026-10-29 — Asana task 1219919783814613 (FBM stock) completed.
- 2026-10-29 — Refund fog graduated: grilling #6040 blocked by BRD input #6039 (coordinator, delegated).
- 2026-10-29 — #5974 closed (c6497734388); ADR 0138 approved by Erick Nyoto.
- 2026-10-30 03:41Z — PR #6041 merged: ADR 0138 (`238de6e6d8`).
- 2026-10-30 03:56Z — BRD requirement for the Amazon failure digest posted (story 1220041038186030); Erick corrects it the same day to a new Amazon Chat space (story 1220041038698373).
- 2026-10-30 04:45Z — PR #6053 merged: ADR 0139 (`b53a9b8971`), accepted by Erick at `3bbdbd64b0`.
- 2026-10-30 06:28Z — Asana after the no-shadow decision: shadow-pull task 1219919864565642 completed as not needed, BR-3 task 1220041626125348 deleted, S1 and S2 exits renamed, #6006 task narrowed.
- 2026-10-30 07:23Z — LWA secret of `Manobo-2008-Sellers` rotated; new deadline 2027-04-28 07:23Z.
- 2026-10-30 07:32Z — New LWA secret verified (EU and NA 200).
- 2026-10-30 07:34Z — #5985 closed (c6517469235).
- 2026-10-30 07:37Z — Asana LWA rotation task 1219920153548672 completed (story 1220045306266864); Doc A .90339 (rev 189).
- 2026-10-30 — Erick: no n8n in Amazon core processes; Amazon gets its own Chat space (Manager Amazon chat).
- 2026-10-30 — #5977 closed (c6514635367); #6052 graduated from it.
- 2026-10-30 — #6006 does not block #5989; #5976 unblocked from #6006 (c6514714221).
- 2026-10-30 — ADR 0140 (shadow mode) drafted from #5976 rounds 1–3 (c6515329122), PR #6055.
- 2026-10-30 — Shadow mode dropped by Erick and the BA: #5976 closed as not planned (c6516457748), PR #6055 closed unmerged, #6006's November half withdrawn (c6516463236); Doc A .88693 (rev 183), body rows rewritten (rev 188).
- 2026-10-30 — #5985 decision: rotate `Manobo-2008-Sellers` now, server env from the S1 ticket, sandbox `Manobo` left unrotated (c6516733459).
- 2026-10-30 — LWA rotation reminder set in Erick's Google Calendar for 2027-02-19 09:00 WITA; Doc A .90339 corrected to 19 Feb.
- 2026-10-30 — #5978 no longer waits on #5989 (c6517816695; Doc A .91480).
- 2026-10-30 — S1 spec #6062 published (issuecomment-6518285175).
- 2026-10-30 — Erick confirms the 28 Oct `-L` rows were his team's manual fix.
- 2026-10-30 — The coordinator reports the CA FBA promotion import error to Erick; not a map ticket.
