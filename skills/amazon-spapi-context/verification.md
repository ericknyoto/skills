# Verification playbook

Every recipe here is read-only and worked on the date given. Credentials live in `manobo-2008/.env` and **must
never be printed**: read them into variables and reference them. No session helper is persisted: rebuild the replica
query wrapper and the GET-only SP-API script below in each session. Flow-specific queries and requests live in each
flow file's "How to verify" section.

## Safety

- **Replica:** `SELECT`/`SHOW`/`DESCRIBE`/`EXPLAIN` only, inside `SET SESSION TRANSACTION READ ONLY`. Any write
  needs Erick's explicit per-task approval.
- **Never `SELECT *` on `jng_sp_download`** (`info` holds the CA profile refresh token) and never select
  `jng_sp_orders.description` (the same token). Name the columns you need.
- **SP-API: GET only.** The LWA token POST is the one exception. No `createFeed`, `patchListingsItem` or
  `confirmShipment` from a laptop (ADR 0128 rule 5); a refund feed is not deduplicated by Amazon.
- **No buyer PII in output.** Do not request `includedData` BUYER or RECIPIENT to explore; print counts, Amazon
  order ids, SKUs and statuses only.
- **Doc A, Asana, GitHub and the sheet are read-only** unless the human asks for the write.

## Production replica

Production is the central tenant of `manobo-2008`, which holds every Nenalina channel; the replica is reached via
`DB_*_PRODUCTION_DEBUGGING`. Shape of the wrapper used on 2026-10-28:

```bash
envf=/home/ericknyoto/Work/manobo-2008/.env
g() { grep -E "^$1=" "$envf" | head -1 | cut -d= -f2- | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//"; }
q() { MYSQL_PWD="$(g DB_PASSWORD_PRODUCTION_DEBUGGING)" mariadb --protocol=TCP --ssl -t \
        -h "$(g DB_HOST_PRODUCTION_DEBUGGING)" -P "$(g DB_PORT_PRODUCTION_DEBUGGING)" \
        -u "$(g DB_USERNAME_PRODUCTION_DEBUGGING)" "$(g DB_DATABASE_PRODUCTION_DEBUGGING)" \
        -e "SET SESSION TRANSACTION READ ONLY; $1" 2>&1 | grep -v '^WARNING'; }
```

Queries per flow: channels and orders per channel in [channels-and-routing.md](flows/channels-and-routing.md#how-to-verify),
"is an Amazon order in Manobo?" and exchange-rate pairs in [orders-import.md](flows/orders-import.md#how-to-verify),
ChannelAdvisor SKU errors and the `-L` strip in [prices-and-listings.md](flows/prices-and-listings.md#how-to-verify),
returns per origin in [cancel-and-refund.md](flows/cancel-and-refund.md#how-to-verify).

## SP-API, read-only

SP-API is reached via `AMAZON_PROD_*` in the local `.env`. Shape of the script used on 2026-10-27/28 (Python
standard library, run with `python3 -I`):

```python
env = {k: v.strip().strip('"\'') for k, v in (l.strip().split('=', 1) for l in open(ENV) if l.startswith('AMAZON_PROD_') and '=' in l)}
body = urllib.parse.urlencode({'grant_type': 'refresh_token',
    'refresh_token': env['AMAZON_PROD_REFRESH_TOKEN_NENALINA_EU'],          # or …_NA
    'client_id': env['AMAZON_PROD_CLIENT_ID'], 'client_secret': env['AMAZON_PROD_CLIENT_SECRET']}).encode()
tok = json.load(urllib.request.urlopen(urllib.request.Request('https://api.amazon.com/auth/o2/token', data=body)))['access_token']
req = urllib.request.Request('https://sellingpartnerapi-eu.amazon.com' + path,   # NA: sellingpartnerapi-na
                             headers={'x-amz-access-token': tok, 'user-agent': 'manobo-readonly-check/1.0'})
```

Write each response to a file and print only `GET path -> status`. Never print `env`, `tok` or a response that
could carry buyer data. API models without a call: `models/orders-api-model/orders_2026-01-01.json` and
`ordersV0.json` in `amzn/selling-partner-api-models`.

Requests per flow (EU seller `A1SMSLS6YOBHD5`, DE `A1PA6795UKMFR9`): marketplaces of a token in
[channels-and-routing.md](flows/channels-and-routing.md#how-to-verify); listings, SKU search and product type schema in
[prices-and-listings.md](flows/prices-and-listings.md#how-to-verify); FBA stock in [fba-stock.md](flows/fba-stock.md#how-to-verify);
orders in [orders-import.md](flows/orders-import.md#how-to-verify); refunds on an order in
[cancel-and-refund.md](flows/cancel-and-refund.md#how-to-verify); the LWA secret check in
[data-protection.md](flows/data-protection.md#how-to-verify).

## GitHub

Repo julie-grace/manobo-2008, cwd `/home/ericknyoto/Work/manobo-2008`:

```bash
gh issue view 5967                                            # map: Notes, Decisions so far, Not yet specified
gh issue list --search 'label:wayfinder:grilling' --state all # labels are shared with Lumen map #5922 (5923–5933)
gh issue view 5970 --comments                                 # a ticket's resolution comment
gh api repos/julie-grace/manobo-2008/issues/5978/dependencies/blocked_by -q '.[] | "#\(.number) \(.state)"'
gh pr view 6008 --json state,mergedAt,headRefOid,mergeStateStatus,reviewDecision
git fetch origin 5973-adr-amazon-channel-config
git show origin/5973-adr-amazon-channel-config:docs/adr/0134-amazon-seller-channels-configured-by-columns.md
git show origin/master:docs/adr/0132-one-integrator-per-sales-channel.md
```

Ticket numbers, ADR files and research branches: [sources/github.md](sources/github.md).

## Doc A and Nitya's timeline

Docs MCP, read:

1. `ToolSearch` with `select:mcp__1a59c906-04da-521d-bda7-7f71b9f9e01c__read,mcp__1a59c906-04da-521d-bda7-7f71b9f9e01c__guide`;
   call `guide` with `topic.instructions` once.
2. `read` ref `{object: project, id: fa6cbfbc-b183-4630-91d7-4a9698b7eab5}` lists the tab.
3. `read` ref `{object: node, id: 3544b1d9-3e5b}` with container `{kind: project, id: fa6cbfbc-…}`. The result
   (about 200 KB at rev 157) overflows into a saved file: a JSON array whose element `[1].text` is JSON with
   `data.rev` and `data.xml`. Parse the XML (`paragraph`, `table`/`row`/`cell`, `list`/`listItem`, `text`, ids
   `mzse2z3z5sh.N`) with a short Python script; the decision log is table `mzse2z3z5sh.36886`.
4. Nitya's artifact: ref `{object: node, id: 9cc01e70-9437}`, container `{kind: project, id:
   54c254bd-2bb2-4e38-89c6-e02f1fed3def}`; fits inline (rev 57 on 2026-10-28).

## Asana

Read: tools `mcp__047f5739-9183-4376-9dd3-e2c259f07f1b__*`, loaded with `ToolSearch`. `get_project` 1219919921535476 with
`include_sections`; `get_tasks` with `project` and `opt_fields=name,due_on,assignee.name,completed,memberships.section.name`
returns all 61 tasks in one page; `get_task_stories` with `task_ids=[…]` and `resource_subtype=comment_added` reads
every comment in one call. Profile ids inside comment mentions do not resolve with `get_user`.

## Sales Channel List sheet

Read: Google Drive MCP `read_file_content`, `fileId` `1I1FtuGRnXalKkJmLXanTLsljNFLsAMNvKlQ2kIH5nlM`: returns all three tabs
as tables (2026-10-28).

## Production host

SSH needs a per-task grant from Erick.

- CA download log: container `manobo_2008-manobo_central-NN`, `/app/storage/logs/channeladvisor-download-order-YYYY-MM-DD.log`
  (about 43 MB a day, the full service-api response per run).
- CA order-status log: `/app/storage/logs/channeladvisor-order-status-service-*.log`; older days in
  `archive/YYYY-MM/*.log.gz`.
- CA stock failures: `/app/logs/classes_Domain_Shared_ChanneladvisorExchange_Job_ExportStockToChanneladvisorJob.log`.
- Cadences: `crontab -l` as `manobo` on the host (Europe/Berlin); `php artisan schedule:list` in
  `manobo_2008-manobo_central_scheduler-1` (prints UTC); host cron logs in
  `/home/manobo/production/manobo_2008/cron/log/{central,local}/`.
