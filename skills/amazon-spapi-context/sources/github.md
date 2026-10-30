# GitHub and local notes

**Owner:** Wayfinder sessions write the GitHub lines of this store (map, tickets, resolution comments, PRs, ADR
statuses). From S1 on, implementation sessions add the "Implemented by PR #…" lines under the decisions they build.

| | |
|---|---|
| Map | julie-grace/manobo-2008 #5967 (`wayfinder:map`); tickets `wayfinder:grilling` / `research` / `task`; technical decisions in each ticket's resolution comment |
| Comment ids | `#5970 c6435901334` = `issuecomment-6435901334` |
| ADRs | `docs/adr/0128`–`0134`, `0138`, `0139` on master, the binding technical decisions (statuses and merge commits in [index.md](../index.md)); `0140` never on master |
| `GLOSSARY.md` | master: Integrator, Amazon Seller vs Amazon Vendor, Seller account (Amazon), Fulfilment channel (Amazon), Amazon marketplace vs Marketplace; "Amazon Seller channel" in PR #6008 |
| Read | [verification.md](../verification.md#github) |

Amazon map tickets: #5968–#5989, #5991, #6006, #6012, #6013; added later: #6039, #6040, #6052 and the S1 spec #6062
([open-state.md](../open-state.md#map-tickets)).

## Research branches

Findings behind #5980–#5983, each one `docs/research/*.md`, never merged; no checkout needed:
`research/jewelry-list-price` (`amazon-jewelry-list-price.md`), `research/amazon-carrier-codes`
(`amazon-carrier-codes.md`), `research/currency-pairs` (`5980-exchange-rate-pairs-usd-pln-sek.md`),
`5983-research-amazon-personalisation-prod` (`amazon-personalisation-prod.md`).

## Local notes

| Notes | Location | Holds |
|---|---|---|
| Ticket fact notes | `~/.config/Claude/side-session-notes/local_37c29950-6eeb-45e7-a4a8-4be997f0d0c4/` (`5969`…`5984-*.md`) | raw evidence the resolutions cite |
| #5976 DE diff | `~/.config/Claude/side-session-notes/local_0f6cedbf-c406-4622-afe2-5b8dae0215c5/` (`w2-de-dry-diff`) | the manual DE diff of 2026-10-30 |
| Auto-memory | `~/.claude/projects/-home-ericknyoto-Work-manobo-2008/memory/amazon-spapi-*.md` and neighbours | chronological notes holding superseded lines ("14 channels"); this skill is the curated copy |

## Code anchors

Accurate on 2026-10-28: manobo-2008 master `74b6517496`, manobo-service-api `edd3b67`. `Manobo2/Domain/AmazonSeller`
and `config/amazon.php` do not exist yet. Anchors, not addresses: this knowledge base is not versioned with the
code, so confirm a symbol exists before relying on it.

| What | Where | Flow |
|---|---|---|
| CA order download and routing | `Manobo2/Domain/Shared/ChanneladvisorExchange/Service/ChanneladvisorDownloadOrderService.php::downloadNewOrders` | orders |
| CA order import, shipment ids, carrier map | `…/ChanneladvisorExchange/Service/ChanneladvisorOrderService.php` (`generateShipmentId`, `generateShipmentIdForSplitQuantity`, `getShipmentCarrier`) | orders, shipment |
| CA refund / cancel (quantity only) | `…/ChanneladvisorExchange/Service/ChanneladvisorOrderStatusService.php::setOrderItemAsAdjusted` | refund |
| Returns to CA, shipping refund (off) | `Manobo2/Domain/SalesOrder/Channeladvisor/Listener/ProcessReturnB2cToChanneladvisorListener.php` | refund |
| SKU lookup | `…/ChanneladvisorExchange/Service/ChanneladvisorCacheService.php::getObjectProductArticleBySku` | orders |
| Real SKU | `Manobo2/Services/ProductSkuService.php::generate` | listings |
| CA family parent `S…` | `…/ChanneladvisorExchange/Service/ChanneladvisorExportProductFamilyService.php` | listings |
| Item promotions / tax | `Manobo2/Domain/SalesOrder/Channeladvisor/Action/SavePromotionsItemLevelAction.php`, `Manobo2/Domain/Order/Action/UpdateTaxAmountAction.php` | orders |
| Import error ledger | `Manobo2/Domain/SalesOrder/Action/RecordOrderImportErrorAction.php` | orders, monitoring |
| `ca_used`/`tb_used` derived on save | `Manobo2/Domain/Shared/SalesChannel/Action/SaveSalesChannelDetailAction.php` | channels |
| FBA refund pull | `Manobo2/Domain/ChannelAdvisor/Command/OrderRefundFromSalesChanneladvisorFbaCommand.php` | refund |
| Currency conversion | `helpers/functions-2.php` (`convertCurrency`), `cron/daily-exchange-rate.php` | orders |
| CA new-order read (service-api) | `app/Manobo/Service/Impl/v3/ChanneladvisorOrderApiService.php::getNewOrders` | orders |
