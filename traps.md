# Traps — conclusions that were wrong, and why

Each entry was believed somewhere (Doc A, a ticket, an ADR draft, a status line, memory) and later corrected.
They are cheap to repeat. Read this before quoting a scope, a status or a number. The figures behind each
correction live in `facts.md`.

## "Phase 1 is 16 channels, per the sheet"

**Believed** on the morning of 2026-10-28 and written to Doc A (.60881), Asana and the map: 16 = 2 DE + 14 EU,
MX and CA closed, UK pending, US AN.UB "inactive in the sheet".
**True:** the Sales Channel List sheet marks 20 Nenalina channels "Active, need to migrate"; only AN.DT is
inactive. The 16 and "AN.UB/AN.KB inactive" came from Nitya's timeline artifact before she updated it.
**Caught** the same day: Erick named the sheet the reference, the coordinator read it (20 active), and Nitya
confirmed 20 in Asana (1219919783909992). Doc A .65324 records the correction. **Read the sheet itself, and name
the document a number came from.**

## "The UK channel is dead"

**Believed:** Doc A (2026-10-20) crossed UK out because AN.KB had no order since 2024-03-10; the Sales documents
said "I think turned off".
**True:** Amazon UK ships about 129 FBA orders per 30 days on the Nenalina EU account, and none reach Manobo or
`order_import_errors`. The flow stopped on the ChannelAdvisor side; Manobo just never saw it.
**Caught** by the #5969 routing probe, 2026-10-27. **Manobo's order table is no evidence of what Amazon sells —
count with searchOrders before calling a marketplace dead.**

## "A refund cannot exceed the charged amount"

**Believed** during the ADR 0131 raw-money review (2026-10-28) as a reason to keep Amazon's own amounts.
**True:** Amazon's documentation has no such rule; only a Seller Forum error 18010 exists. ADR 0131 does not rest
on it — the table stays because only Amazon's numbers equal what the buyer paid.
**Caught** by the documentation check, 2026-10-28 (Doc A .66078).

## "Manobo does not keep promotion amounts"

**Believed** in the #5971 question and Doc A (.16420, .18130): Manobo stores `tax_amount = 0` and only converted
prices, so refunds lack the original amounts.
**True:** Manobo stores the item promotion per piece and the price after promotion. What it lacks is Amazon's tax
figure (`tax_amount` is Manobo's own calculation), and `tax_amount = 0` is rare on DE and normal on US. What Manobo
has never done is send refund money: a refund to ChannelAdvisor carries a quantity only.
**Caught** in the #5971 grilling (tax) and the ADR 0131 investigation of 2026-10-28 (promotions, quantity-only).

## "Amazon's `promotion` and `tax` blocks carry money"

**Believed:** ADR 0131 as accepted on 2026-10-27 named `proceeds`, `promotion` and `tax` as the money to capture.
**True:** in Orders v2026-01-01 only `proceeds` holds amounts; `promotion` holds ids, `tax` a reporting scheme.
**Caught** by reading `orders_2026-01-01.json` on 2026-10-28; ADR 0131 was amended (`99c25d18de`) before merge.

## "FBA uses the real SKU, so the mapping is real SKU vs real SKU + `-FBM`"

**Believed:** the BA's rule of 2026-10-28, true for the sampled product.
**True:** every DE FBA "Product not found for SKU" in the last 30 days is a `-L` SKU, and old dash-format SKUs
exist too. A mapping table must cover all three styles, and `-L` explains most of today's DE import gap.
**Caught** by the replica check of 2026-10-28, posted on #5978.

## "FBM and FBA have the same price"

**Planned around** in the #5978 question ("when FBM and FBA prices are equal") and Doc A .27879 (one price
pushed to both SKUs if workshop question Q14 says so).
**True:** the one pair checked differs today: `0402620921` 29.40 (FBA) vs `0402620921-FBM` 29.50, same list
price. **Caught** by getListingsItem, 2026-10-28. The business answer is still open (#6013).

## "That ADR is Proposed" / "that PR is open"

**Believed** on 2026-10-28 by the coordinator ledger, memory and Doc A: ADR 0133 Proposed (it was accepted on
2026-10-27, `ffd5aa4aaf`), PRs #5994, #5995 and #6007 open (merged 06:52–07:14Z that day). Doc A rows .49003,
.50867, .52459 still say Proposed; the map still says ADR 0133 is not merged.
**True:** status lags in every copy. Read the ADR file on `origin/master` and `gh pr view`; see `decisions.md`.
**Caught** while building this skill, 2026-10-28.

## "The listings use product type JEWELRY"

**Believed** in the #5981 question and Doc A (.5920).
**True:** NECKLACE, RING, BRACELET and CHARM. A patch sends the listing's own `summaries[].productType`.

## "Metapack and Seven Senders go out as carrierCode `Other`"

**Believed** in Doc A's flow table (.4945) and backlog (.22389), which still say so.
**True:** send the last-mile carrier's code; Metapack is label software; `Other` only for a carrier without a code
(Austrian Post), and Amazon cannot track it. **Caught** by #5982.

## "Amazon has orders Manobo lacks, so the import is broken"

**Partly wrong.** FBA orders reach Manobo only once SHIPPED, by design (ChannelAdvisor today, confirmed by the BA).
Pending, Unshipped and Cancelled orders are absent on purpose. **Compare SHIPPED orders only.** The largest real
gaps are DE FBA (218 of 573 shipped orders missing, mostly unmapped SKUs) and all of UK.

## "Setting `ca_used = 0` stops ChannelAdvisor for a channel"

**True:** the CA download routes on `(ca_profile_id, ca_channel_id, use_external_warehouse)` and ignores `ca_used`
and `active_status`; only ADR 0132's skip rule, not yet built, will stop it. The CA stock export pushes to every
profile regardless, so Rithum itself must switch stock and price sync off (#5970).

## "Removing the cron line stops ChannelAdvisor for Nenalina"

**True:** one host-cron line downloads all 23 CA profiles and Tradebyte, so stopping goes per profile or in code.
The CA stock cron script looks live in `cron/` but has not run since 2023-07-09; stock goes by event (#5984).

## "Returns refund the shipping cost to ChannelAdvisor"

The #5984 resolution lists `RefundShippingCostToChanneladvisorJob` as dispatched on return; in the listener that
dispatch is commented out (`facts.md` → ChannelAdvisor today, checked in code 2026-10-28). Read the listener, not
the ticket, before designing the refund flow.

## Columns that look like Amazon identity and are not

`jng_sp.marketplace_id` points at Manobo's `marketplaces` table, whose types are rotated in production (29 "Amazon
NL" is typed `AmazonUSJGMarketplace`). `use_amvd_logistic` and `salesChannelIsAmazon()` mean Amazon **Vendor**.
`jng_sp.currency` is EUR on US, PL and SE. `package_prefix`, channel ids and subclasses are banned by ADR 0134.
Amazon identity is `amazon_seller_account`, `amazon_marketplace_id` and `use_external_warehouse`, once built.

## "`order_id` identifies one Amazon order"

Not across seller accounts (13 ids sit in both AM.DF and AN.DB), and not as one row: split channels hold one row
per unit. Scope matching to one seller account and count `DISTINCT order_id`.

## "The sandbox client id works with the production refresh tokens"

`AMAZON_SANDBOX_CLIENT_ID`/`SECRET` belong to the sandbox app; LWA answers `unauthorized_client` for a production
refresh token. Use `AMAZON_PROD_CLIENT_*` (2026-10-27).

## "searchOrders returns fulfilment data"

Not without `includedData=FULFILLMENT`; the block is simply absent (smoke test, 2026-10-27).

## "Julie & Grace sells through ChannelAdvisor"

The Sales documents and the first project form said so. J&G retail is Tradebyte (`tb_used = 1`) on every channel
but AM.US, which has 4 orders a year. Phase 2 replaces Tradebyte for Amazon, not ChannelAdvisor.

## "`S0402620921` is an Amazon SKU"

It is the ChannelAdvisor family parent shown in a CA catalogue screenshot; Amazon answers 404. A ChannelAdvisor
screen is not Amazon evidence: confirm on Amazon with getListingsItem (2026-10-28).
