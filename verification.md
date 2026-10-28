# Verification playbook

Every recipe here is read-only and worked on the date given. Credentials live in `manobo-2008/.env` and **must
never be printed**: read them into variables and reference them.

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

Database = the central tenant, which holds every Nenalina channel. Shape of the wrapper used on 2026-10-28:

```bash
envf=/home/ericknyoto/Work/manobo-2008/.env
g() { grep -E "^$1=" "$envf" | head -1 | cut -d= -f2- | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//"; }
q() { MYSQL_PWD="$(g DB_PASSWORD_PRODUCTION_DEBUGGING)" mariadb --protocol=TCP --ssl -t \
        -h "$(g DB_HOST_PRODUCTION_DEBUGGING)" -P "$(g DB_PORT_PRODUCTION_DEBUGGING)" \
        -u "$(g DB_USERNAME_PRODUCTION_DEBUGGING)" "$(g DB_DATABASE_PRODUCTION_DEBUGGING)" \
        -e "SET SESSION TRANSACTION READ ONLY; $1" 2>&1 | grep -v '^WARNING'; }
```

**Channels** (the `facts.md` channel table):

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

**Is an Amazon order in Manobo?** `SELECT jng_sp_id, shipment_id, order_date FROM jng_sp_orders WHERE order_id IN
('…')` — then check the `jng_sp_id` belongs to the right seller account (`order_id` repeats across accounts).
If absent: `SELECT order_number, created_at, resolved_at, JSON_EXTRACT(payload,'$.errors') FROM
order_import_errors WHERE source = 'channeladvisor' AND order_number IN ('…')`.

**ChannelAdvisor SKU errors per channel** (`order_import_errors.payload` holds `errors[]` and a `reference`
"Download ID/CA Order ID: <download id>/<CA id>"; ran 2026-10-28, about 5 s):

```sql
WITH e AS (
  SELECT oie.id, d.jng_sp_id,
         TRIM(SUBSTRING_INDEX(j.err, 'Product not found for SKU:', -1)) COLLATE utf8mb4_general_ci sku
  FROM order_import_errors oie
  JOIN JSON_TABLE(oie.payload, '$.errors[*]' COLUMNS (err VARCHAR(500) COLLATE utf8mb4_general_ci PATH '$')) j
  JOIN jng_sp_download d ON d.jng_sp_download_id = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(
         JSON_UNQUOTE(JSON_EXTRACT(oie.payload,'$.reference')),': ',-1),'/',1) AS UNSIGNED)
  WHERE oie.source = 'channeladvisor' AND oie.created_at >= NOW() - INTERVAL 30 DAY
    AND j.err LIKE '%Product not found for SKU:%')
SELECT jng_sp_id, COUNT(*) err_rows, COUNT(DISTINCT sku) distinct_skus,
       COUNT(DISTINCT CASE WHEN sku LIKE '%-L' THEN sku END) l_suffix,
       COUNT(DISTINCT CASE WHEN sku LIKE '%-FBM' THEN sku END) fbm_suffix,
       COUNT(DISTINCT CASE WHEN sku IN (SELECT sku FROM product_skus) THEN sku END) in_product_skus,
       COUNT(DISTINCT CASE WHEN sku IN (SELECT sku FROM jng_sp_sku) THEN sku END) in_any_jng_sp_sku
FROM e GROUP BY jng_sp_id;
```

To test the `-L` strip on one channel, add `d AS (SELECT DISTINCT sku FROM e WHERE jng_sp_id = 195)` and count
`JOIN product_skus ps ON ps.sku = LEFT(d.sku, CHAR_LENGTH(d.sku) - 2)`; `jng_sp_sku` has `jng_sp_id`, `sku`,
`products_id`, `articles_id`.

**Exchange-rate pairs** (add any pair the same way):

```sql
SELECT updated_at, JSON_LENGTH(value), JSON_EXTRACT(value,'$.USD2EUR'), JSON_EXTRACT(value,'$.GBP2EUR'),
       JSON_EXTRACT(value,'$.MXN2EUR'), JSON_EXTRACT(value,'$.CAD2EUR')
FROM app_config WHERE `key` = 'exchange-rate';
```

## SP-API, read-only

Shape of the script used on 2026-10-27/28 (Python standard library, run with `python3 -I`):

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
could carry buyer data.

| Purpose | Request (EU seller `A1SMSLS6YOBHD5`, DE `A1PA6795UKMFR9`) | Last OK |
|---|---|---|
| Marketplaces of a token | `GET /sellers/v1/marketplaceParticipations` (EU token: 18 entries, 13 Amazon + 5 MCF) | 2026-10-28 |
| One listing | `GET /listings/2021-08-01/items/{seller}/{urlencoded sku}?marketplaceIds={mp}&includedData=summaries,attributes,offers,fulfillmentAvailability,issues` — 404 `NOT_FOUND` = no such SKU | 2026-10-28 |
| Find a SKU / count listings | `GET /listings/2021-08-01/items/{seller}?marketplaceIds={mp}&identifiers={sku}&identifiersType=SKU&includedData=summaries`; with `pageSize=20` and no identifiers → `numberOfResults` | 2026-10-28 |
| FBA stock of a SKU | `GET /fba/inventory/v1/summaries?details=true&granularityType=Marketplace&granularityId={mp}&marketplaceIds={mp}&sellerSkus={sku}` (50 per page) | 2026-10-28 |
| Product type schema | `GET /definitions/2020-09-01/productTypes/{TYPE}?marketplaceIds={mp}&requirements=LISTING&locale=de_DE`, then fetch `schema.link` (pre-signed, 0.4–0.5 MB) | 2026-10-27 |
| Orders, counts only | `GET /orders/2026-01-01/orders?marketplaceIds={13 ids}&createdAfter=…&includedData=FULFILLMENT`; each next page sends `paginationToken` **plus the original `createdAfter`**, else 400 | 2026-10-27 |

searchOrders allows 0.0056 requests per second (burst 20): a 30-day EU pull took 13 pages. API models without a
call: `models/orders-api-model/orders_2026-01-01.json` and `ordersV0.json` in `amzn/selling-partner-api-models`.

## GitHub (repo julie-grace/manobo-2008, cwd `/home/ericknyoto/Work/manobo-2008`)

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

Amazon map tickets: #5968–#5989, #5991, #6006, #6012, #6013. Research write-ups: `docs/research/` on
`research/jewelry-list-price` (`amazon-jewelry-list-price.md`), `research/amazon-carrier-codes`
(`amazon-carrier-codes.md`), `research/currency-pairs` (`5980-exchange-rate-pairs-usd-pln-sek.md`),
`5983-research-amazon-personalisation-prod` (`amazon-personalisation-prod.md`). No checkout needed.

## Doc A and Nitya's timeline (Docs MCP, read)

1. `ToolSearch` with `select:mcp__1a59c906-04da-521d-bda7-7f71b9f9e01c__read,mcp__1a59c906-04da-521d-bda7-7f71b9f9e01c__guide`;
   call `guide` with `topic.instructions` once.
2. `read` ref `{object: project, id: fa6cbfbc-b183-4630-91d7-4a9698b7eab5}` lists the tab.
3. `read` ref `{object: node, id: 3544b1d9-3e5b}` with container `{kind: project, id: fa6cbfbc-…}`. The result
   (about 200 KB at rev 157) overflows into a saved file: a JSON array whose element `[1].text` is JSON with
   `data.rev` and `data.xml`. Parse the XML (`paragraph`, `table`/`row`/`cell`, `list`/`listItem`, `text`, ids
   `mzse2z3z5sh.N`) with a short Python script; the decision log is table `mzse2z3z5sh.36886`.
4. Nitya's artifact: ref `{object: node, id: 9cc01e70-9437}`, container `{kind: project, id:
   54c254bd-2bb2-4e38-89c6-e02f1fed3def}`; fits inline (rev 57 on 2026-10-28).

## Asana (read)

Tools `mcp__047f5739-9183-4376-9dd3-e2c259f07f1b__*`, loaded with `ToolSearch`. `get_project` 1219919921535476 with
`include_sections`; `get_tasks` with `project` and `opt_fields=name,due_on,assignee.name,completed,memberships.section.name`
returns all 61 tasks in one page; `get_task_stories` with `task_ids=[…]` and `resource_subtype=comment_added` reads
every comment in one call. Profile ids inside comment mentions do not resolve with `get_user`.

## Sales Channel List sheet (read)

Google Drive MCP `read_file_content`, `fileId` `1I1FtuGRnXalKkJmLXanTLsljNFLsAMNvKlQ2kIH5nlM`: returns all three tabs
as tables (2026-10-28).

## Production host (SSH needs a per-task grant from Erick)

- CA download log: container `manobo_2008-manobo_central-NN`, `/app/storage/logs/channeladvisor-download-order-YYYY-MM-DD.log`
  (about 43 MB a day, the full service-api response per run).
- CA order-status log: `/app/storage/logs/channeladvisor-order-status-service-*.log`; older days in
  `archive/YYYY-MM/*.log.gz`.
- CA stock failures: `/app/logs/classes_Domain_Shared_ChanneladvisorExchange_Job_ExportStockToChanneladvisorJob.log`.
- Cadences: `crontab -l` as `manobo` on the host (Europe/Berlin); `php artisan schedule:list` in
  `manobo_2008-manobo_central_scheduler-1` (prints UTC); host cron logs in
  `/home/manobo/production/manobo_2008/cron/log/{central,local}/`.
