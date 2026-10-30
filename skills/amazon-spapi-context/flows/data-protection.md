# Data protection

Amazon buyer PII (ADR 0133, BR-1 … BR-6), what Amazon returns about buyers with our roles, the old-order PII
question, credentials and the LWA secret rotation (#5985), sandbox versus production app. The production app's
roles and the seller accounts: [channels-and-routing.md](channels-and-routing.md#seller-accounts-and-app). Rules for
handling secrets and PII during checks: [verification.md](../verification.md#safety).

## Decisions

### ADR 0133 Amazon buyer PII

Amazon buyer PII only in `PiiFieldMap` columns, which BR-1 redacts; no PII in any `AmazonSeller` store, log, feed
row, money table, shadow or failure table, job payload or cache (test-enforced); retention per channel is a business
switch, with no forced validation and no gate; FBA requests neither BUYER nor RECIPIENT until #5988; Amazon
`errors[]` logged as code + message; Sentry `sql_bindings` off and Nightwatch checked before the first PII read
(BR-3, S1). Shadow mode was dropped on 30 Oct; BR-3 stays binding before the first production PII read, now the
go-live order import: [no shadow mode](governance-and-timeline.md#no-shadow-mode).
- **Status:** Accepted 2026-10-27 (`ffd5aa4aaf`; Q1 answered by Erick, Q2–Q6 delegated); PR #5995 merged 2026-10-28 06:59Z (`d5f55beb6f`)
- **Where:** #5975 c6435827564 (closed by Erick); Doc A .49003 (said Proposed), .71195 (merged)

### BR-1 to BR-6 stay binding

Amazon DPP obligations BR-1 … BR-6 stay binding for the new domain.
- **Who, when:** Erick, 2026-10-27
- **Where:** Doc A .38010; ADR 0133

### 5985 LWA secrets

LWA secrets (#5985): `Manobo-2008-Sellers` rotated now although it had no alert (the local `.env` was its only copy,
the cheapest moment); staging and production get the credentials from the S1 ticket that adds `config/amazon.php`,
not now; the unused sandbox app `Manobo` (`2185aaca`) that carried the alert is left unrotated.
- **Who, when:** Erick (rotation, unused app); coordinator on Erick's delegation (server env); 2026-10-30
- **Where:** #5985 c6516733459, c6517469235; map #5967
- **Follow-up:** the LWA secret rotation (`1219920153548672`, #5985) is done: Asana task completed 30 Oct 07:37Z
  (story `1220045306266864`), Doc A log row `.90339` (rev 189). The rotation reminder is in Erick's Google Calendar
  for Friday 2027-02-19 09:00 WITA (set by the #5985 session on 30 Oct); Doc A row `.90339` corrected to 19 Feb.

### Staging gets the sandbox values only

Staging Central holds only the sandbox app's client id, secret and refresh token; no `AMAZON_PROD_*` and no read-override
variable. The staging connection check runs in sandbox mode only; the production-read check runs on production after the
S1 parent deploy. A production refresh token is a full key to the Nenalina account that Amazon cannot scope to reads (the
ADR 0128 guard lives in Manobo code), and a production read from staging would pull buyer PII onto staging before BR-3 is
live there. ADR 0128's assumption (lines 34–35) that the sandbox is reached with the same app's tokens was refuted on
27 Oct (trap below), so S1 needs no production token on staging. Reading production from staging (order-mapping
validation in S2) is decided in the S2 spec as a bounded procedure: token set for one test window, removed after it, BR-3
live first. ADR 0128 gets a one-sentence erratum (docs PR by the S1 session).
- **Who, when:** Erick ("Opsi 1 saja"), 2026-10-30, on the coordinator's analysis
- **Where:** Doc A .96202; #6067 issuecomment-6519943243; spec #6062 section B and "Still open" 2 (edited by the S1 session)

### Old-order PII is an After Release Task

Old-order PII: the BA will have users tick the PII field in the sales-channel setting, as an After Release Task
(ART): decided with Sarina before go-live; if agreed, a post-release task enables PII redaction per channel and the
developer verifies the process; not blocking S1 (Erick, 28 Oct). The task: "Redact PII of 70,793 old orders now or
from go-live (BD-21)", due 2026-12-18 (was 11-06; task renamed "Before go-live (After Release Task)"); its state on
10-28 07:21Z: "BA will inform users to mark the PII field in the sales-channel setting; part of the ART task".
- **Who, when:** the BA, 2026-10-28
- **Where:** Asana 1219922605431756 (07:21Z); Doc A .70800, .72438

### BD-21 task completed by Erick

Historical-order PII (BD-21): Asana task completed by Erick himself (04:17Z, intentional): it is an After Release
Task, decided with Sarina before go-live (18 Dec); nothing to decide for S1–S4.
- **Who, when:** Erick, 2026-10-29
- **Where:** Asana 1219922605431756 (marked complete, no comment); Doc A log row added 29 Oct

## Facts

### PII in Amazon order data

- **FBA buyer data with our roles:** AFN orders carry no buyer block, and `recipient.deliveryAddress` holds only
  city, postal code and country (sometimes region): 96 of 96 DE FBA orders, 2026-10-27; v0 `getOrderAddress` Name
  is empty. MFN orders are complete. Through CA, AN.DB has full addresses today (370 of 370 orders in 30 days),
  with Amazon relay emails and placeholder phones (Doc A .27600, .44046; example `303-6456306-1725135`).
- searchOrders v2026-01-01: **without BUYER/RECIPIENT, FBM orders still return `giftMessage` (via FULFILLMENT) and
  `customizedUrl` (ungated)**; FBA orders neither (#5976).
- **PII:** retention is off on all 238 channels and `pii_redaction_logs` is empty; the 20 Nenalina channels hold
  70,793 orders shipped more than 30 days ago that still carry PII (FBM 6,380, FBA 64,413, oldest mid-2023)
  (#5975, 2026-10-27). `config/sentry.php` has `breadcrumbs.sql_bindings => true` on master (2026-10-30); PR #6085 (#6066,
  open) sets it and `tracing.sql_bindings` false.
- **Sentry and Nightwatch bindings paths** (code read at master `b53a9b8971`, 2026-10-30): sentry-laravel 4.20.1 has a
  second key, `tracing.sql_bindings`, which defaults to true when absent (`Tracing/EventHandler.php:99`), so BR-3
  needs both keys off. Nightwatch v1.22.1 sends SQL with `?` placeholders and no job payloads, and receives no log
  records (`config/logging.php` overrides its `nightwatch` channel with a daily file). It does send exception
  messages, and a `QueryException` message embeds the bound values (`QueryException::formatMessage`). Its
  `exception_preview` skips `redactExceptions` (`ExceptionSensor.php:74`). Scrubber follow-up: #6087, due before
  the DE go-live import. **Nightwatch on production Central** (read over SSH, `config:show` in
  `manobo_central`, 2026-10-30, #6066 issuecomment-6520256868): enabled, token set, agent running; sampling
  requests 0.1, commands 1, scheduled tasks 1, exceptions 0 (= only unsampled executions are dropped, so exceptions
  in every command/scheduled task and 10% of requests are sent); `ignore_queries` false; log_level error;
  `capture_request_payload` false.

### Credentials

- LWA client secrets (#5985, portal read 2026-10-30): `Manobo-2008-Sellers` rotated 2026-10-30 07:23Z, rotation
  deadline **2027-04-28 07:23Z**; sandbox `Manobo-2008` (the one in `.env`) deadline **2027-03-22 03:24Z**. The portal
  banner and the only expiration alert belong to an unused sandbox app `Manobo` (`amzn1.sp.solution.2185aaca-…`,
  deadline 2026-10-13, left unrotated by Erick; not in `.env` or any repo). Right after "Rotate secret", the
  credentials view still shows the OLD secret until the page is reloaded, and the confirmation message showed a
  different date (2027-03-23); trust the reloaded view. New secret verified 07:32Z (EU and NA 200). Amazon's page
  "Rotating your app's LWA credentials" (read 2026-10-30): rotate every 180 days; the old secret
  expires 7 days after the new one is generated; only the primary account user can rotate; notice 90 days ahead; past
  the deadline SP-API calls return an error (the page does not say "suppressed"). Rotation does not invalidate
  refresh tokens (Amazon SP-API support, 2026-09-24).
- **Env var names** (local `manobo-2008/.env` only; staging and production are filled by the S1 ticket that adds
  `config/amazon.php`, under the names it fixes: #5985, 30 Oct): `AMAZON_PROD_{APP_ID,CLIENT_ID,CLIENT_SECRET}`,
  `AMAZON_PROD_REFRESH_TOKEN_NENALINA_{EU,NA}`, `AMAZON_SANDBOX_{APP_ID,CLIENT_ID,CLIENT_SECRET,REFRESH_TOKEN}`. No
  code on master reads them (`git grep` on `b53a9b8971`, 2026-10-30).
  Planned override (#5972): `AMAZON_SELLER_READ_ENDPOINT_<ACCOUNT>=production`, reads only.

## Traps

### "The sandbox client id works with the production refresh tokens"

`AMAZON_SANDBOX_CLIENT_ID`/`SECRET` belong to the sandbox app; LWA answers `unauthorized_client` for a production
refresh token. Use `AMAZON_PROD_CLIENT_*` (2026-10-27).

## How to verify

**LWA secret check (status only; #5985).** Per app, run the token exchange of the SP-API GET script
([verification.md](../verification.md#sp-api-read-only)) with that app's client id and
secret: `AMAZON_PROD_*` with the EU and the NA refresh token, and `AMAZON_SANDBOX_*` with
`AMAZON_SANDBOX_REFRESH_TOKEN` against `https://sandbox.sellingpartnerapi-eu.amazon.com`. Then call
`GET /sellers/v1/marketplaceParticipations`. Print only the two status codes, plus LWA's `error` field on a failure
(`invalid_client` = rejected secret). To prove a rotation inside the 7-day overlap, store a SHA-256 of each client
secret in a `umask 077` scratchpad file before rotating (never printed) and afterwards report only "changed: yes/no".
Run it again after day 7, when the old secret is dead. Last OK: 2026-10-30, all 200.

## Open

Live state is in [open-state.md](../open-state.md); the lines that touch this flow:

- BR-3 before the first production PII read (DPP obligations task, due 4 Dec) and the 19 Feb 2027 LWA rotation
  reminder: [Deadlines ahead](../open-state.md#deadlines-ahead).
- #5988 / Asana 1219919849816117 (FBA buyer name and address, or request Tax Invoicing now): [map](../open-state.md#map-tickets).
- Known-unfixed: the CA refresh token written into the error log; ADR 0111's stale Context line:
  [known-unfixed](../open-state.md#known-unfixed-no-issue-yet).
