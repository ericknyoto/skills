# Traps — conclusions that were wrong, and why

Each entry was believed somewhere (Doc A, a ticket, an ADR draft, a status line, memory) and later corrected.
They are cheap to repeat. Read this before quoting a scope, a status or a number. This file holds the traps that cut
across flows; a trap that belongs to one flow lives in that flow file's Traps section, and the ones likely to be hit
from outside their flow are listed at the end. The figures behind each correction live in the flow files.

## "Phase 1 is 16 channels, per the sheet"

**Believed** on the morning of 2026-10-28 and written to Doc A (.60881), Asana and the map: 16 = 2 DE + 14 EU,
MX and CA closed, UK pending, US AN.UB "inactive in the sheet".
**True:** the Sales Channel List sheet marks 20 Nenalina channels "Active, need to migrate"; only AN.DT is
inactive. The 16 and "AN.UB/AN.KB inactive" came from Nitya's timeline artifact before she updated it.
**Caught** the same day: Erick named the sheet the reference, the coordinator read it (20 active), and Nitya
confirmed 20 in Asana (1219919783909992). Doc A .65324 records the correction. **Read the sheet itself, and name
the document a number came from.**

## "That ADR is Proposed" / "that PR is open"

**Believed** on 2026-10-28 by the coordinator ledger, memory and Doc A: ADR 0133 Proposed (it was accepted on
2026-10-27, `ffd5aa4aaf`), PRs #5994, #5995 and #6007 open (merged 06:52–07:14Z that day). Doc A rows .49003,
.50867, .52459 still say Proposed; the map still says ADR 0133 is not merged.
**True:** status lags in every copy. Read the ADR file on `origin/master` and `gh pr view`; see [index.md](index.md).
**Caught** while building this skill, 2026-10-28.

## Flow traps likely to be hit from outside their flow

- "The UK channel is dead": [orders-import.md](flows/orders-import.md#the-uk-channel-is-dead)
- "Amazon has orders Manobo lacks, so the import is broken": [orders-import.md](flows/orders-import.md#amazon-has-orders-manobo-lacks-so-the-import-is-broken)
- "`order_id` identifies one Amazon order": [orders-import.md](flows/orders-import.md#order_id-identifies-one-amazon-order)
- "searchOrders returns fulfilment data": [orders-import.md](flows/orders-import.md#searchorders-returns-fulfilment-data)
- "Amazon's `promotion` and `tax` blocks carry money": [cancel-and-refund.md](flows/cancel-and-refund.md#amazons-promotion-and-tax-blocks-carry-money)
- "FBA uses the real SKU, so the mapping is real SKU vs real SKU + `-FBM`": [prices-and-listings.md](flows/prices-and-listings.md#fba-uses-the-real-sku-so-the-mapping-is-real-sku-vs-real-sku---fbm)
- "`S0402620921` is an Amazon SKU" (a ChannelAdvisor screen is not Amazon evidence): [prices-and-listings.md](flows/prices-and-listings.md#s0402620921-is-an-amazon-sku)
- Columns that look like Amazon identity and are not: [channels-and-routing.md](flows/channels-and-routing.md#columns-that-look-like-amazon-identity-and-are-not)
- "Setting `ca_used = 0` stops ChannelAdvisor for a channel": [channels-and-routing.md](flows/channels-and-routing.md#setting-ca_used--0-stops-channeladvisor-for-a-channel)
- "Removing the cron line stops ChannelAdvisor for Nenalina": [channels-and-routing.md](flows/channels-and-routing.md#removing-the-cron-line-stops-channeladvisor-for-nenalina)
- "Julie & Grace sells through ChannelAdvisor": [channels-and-routing.md](flows/channels-and-routing.md#julie--grace-sells-through-channeladvisor)
- "The sandbox client id works with the production refresh tokens": [data-protection.md](flows/data-protection.md#the-sandbox-client-id-works-with-the-production-refresh-tokens)
