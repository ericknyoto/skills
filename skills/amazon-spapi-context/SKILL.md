---
name: amazon-spapi-context
description: >-
  ChannelAdvisor → Amazon SP-API migration for the Nenalina Amazon channels, with Julie & Grace as phase 2.
  Read before working a ticket on wayfinder map #5967 or an ADR 0128–0134, writing `Domain\AmazonSeller`
  code, calling SP-API or querying production about Amazon channels, SKUs, stock or order money, editing
  Doc A or the Asana project, or quoting a scope, date, status or volume. Spans Doc A (the decision log), the
  GitHub map, Asana, the ADRs and production, so no single place holds the picture. Organised per flow: each file
  in flows/ holds one flow's decisions, facts, traps, checks and open items, and index.md lists every decision.
  Carries a corrections list of conclusions that proved wrong (scope 16 vs 20, the "dead" UK channel, money in the
  promotion and tax blocks, the `-L` SKUs) and read-only verification recipes. Write verified findings back into it
  before you finish; it lives outside the repos and nothing else keeps it current.
---

# Amazon SP-API migration context

## The project in ten lines

1. **Goal:** replace ChannelAdvisor (Rithum) with a direct Manobo → Amazon SP-API integration, built in
   `manobo-2008` as one new domain `Manobo2/Domain/AmazonSeller` (ADR 0128). `manobo-service-api` gets no new code.
2. **Scope (2026-10-28):** 20 Nenalina channels per the Sales Channel List sheet: 2 DE, 14 EU order-only, UK
   AN.KB, US AN.UB, MX AN.MB, CA AN.CB. Only the test channel AN.DT closes. Julie & Grace (Tradebyte) is phase 2.
3. **Timeline (revised 2026-10-28):** S0–S4 20 Oct 2026 – 1 Jan 2027; DE go-live with UAT 4–8 Jan 2027; every
   other Nenalina channel 11–15 Jan; monitoring to 15 Feb; JG from 15 Feb, finish 26 Mar – 9 Apr; ChannelAdvisor
   decommissioned after the JG gate (no date). Latest date for all Nenalina direct: 31 Mar 2027.
4. **Conditions:** Frank's go decision and the tokens before 6 Nov 2026; no production release in the Christmas peak.
5. **Business decisions:** Nitya (BA) clarifies each with Sarina Seigis (PO) into BRD P0+P1, tracked in Asana.
   IT never grills a business question.
6. **Technical decisions:** Erick (tech lead) by grilling, one GitHub ticket per session, durable ones as ADRs,
   collected on wayfinder map #5967 whose destination is "S1 can start" (9 Nov 2026).
7. **Doc A is the source of truth for every decision** (its "Log keputusan" table). Nitya's timeline artifact is
   the source of truth for dates since 28 Oct; the sheet is the source of truth for scope.
8. **Others:** Sahat co-owns the Start-build gate with Sarina; Anja (Marketplace) uploads listings by hand and
   reviews the SKU reconciliation; Frank decides go/no-go.
9. **Languages:** Doc A is Bahasa Indonesia; GitHub, Asana and this skill are English.
10. **Shape of the risk:** decisions and tokens slipping move every gate 1:1; the code is about 4 sprints.

## Read this if you are…

| Doing | Read |
|---|---|
| Anything, before believing a number, a scope or a status | [`traps.md`](traps.md) — **start here** — then the Traps of your flow |
| Meeting a bug or working a ticket in one Amazon flow | that file in [`flows/`](#layout): Decisions, Facts, Traps, How to verify, Open |
| Asking whether something is decided, by whom, and where it is written | [`index.md`](index.md), then the flow file it links |
| Asking when something happened | [`timeline.md`](timeline.md) |
| Finding what is open, blocked or owed, and by whom | [`open-state.md`](open-state.md) |
| Running a replica query or an SP-API call, or reading Doc A, Asana, GitHub or the sheet | [`verification.md`](verification.md) and [`sources/`](#layout) |
| Grilling a map ticket | the flow file's Decisions for what is settled, `open-state.md` for its blockers |

## Layout

- `index.md` — every decision, one line each: id, gist, who, date, link to its flow file.
- `timeline.md` — dated events, oldest first: decisions, merges, Asana completions, production changes, deploys.
- `open-state.md` — live state only: PRs, open map tickets, Asana questions, deadlines, owed actions, known-unfixed.
- `traps.md` — wrong conclusions that cut across flows, plus pointers to flow traps hit from outside.
- `verification.md` — safety rules and generic recipes: replica, SP-API GET script, GitHub, Doc A, Asana, sheet, host.
- `sources/doc-a.md`, `sources/asana.md`, `sources/github.md`, `sources/timeline-nitya.md`, `sources/sheet.md` — ids,
  URLs, owners and access notes per source; `github.md` also holds the ADR list, research branches, local note
  folders and the code anchors.
- `flows/channels-and-routing.md` — seller accounts, app, marketplace ids, channel tables, integrator switch (ADR 0128, 0132, 0134), populations.
- `flows/orders-import.md` — order stream and routing (ADR 0130), SKU resolution, order money in Manobo (#5980), missing orders, ChannelAdvisor import.
- `flows/shipment-confirmation.md` — confirmShipment, carrier codes (#5982), cadence.
- `flows/cancel-and-refund.md` — flows per fulfilment channel (ADR 0138), `shipment_id` and raw money (ADR 0131), feeds, refunds on FBA, returns.
- `flows/fba-stock.md`, `flows/fbm-stock.md` — FBA stock read and FBM stock push, inventory API.
- `flows/prices-and-listings.md` — SKU formats and mapping (#5978, #5986), listings, price fields (#6012, #6013), personalisation.
- `flows/monitoring-and-failures.md` — SP-API transport and rate limits (ADR 0129), failures, alarms, supervisor (ADR 0139), no n8n.
- `flows/data-protection.md` — PII (ADR 0133, BR-1 … BR-6), credentials and LWA rotation (#5985).
- `flows/governance-and-timeline.md` — roles, scope, phases and gates, no shadow mode, the withdrawn ADR 0140.

**Who writes what.** Wayfinder sessions own the GitHub lines (map, tickets, resolution comments, PRs, ADR statuses);
the coordinator owns the Asana, Doc A and BRD lines; from S1 on, implementation sessions add the "Implemented by"
lines. Code symbols named here are anchors, not addresses: see [`sources/github.md`](sources/github.md#code-anchors).

## Keeping this current — required

**You are expected to write back what you learn.** Nothing else updates this. It lives in Erick's skills repo
(`/home/ericknyoto/Work/ericknyoto-skills`, remote `ericknyoto/skills`, path `skills/amazon-spapi-context/`) and is
installed by symlink from `~/.agents/skills/amazon-spapi-context`: never run `npx skills update` for it; edit the
repo and push. Commit each change with a one-line reason, on your own paths only (`git add <file>`, never `git add
-A`: a concurrent agent's loose edits get swept in under your name).

**Verified, or not written.** Check a claim before writing it (`verification.md` and the flow's How to verify hold
the commands) and name the check and its date. A wrong turn belongs in a Traps section. A hunch stays in the reply to
the human, or goes in marked `Assumption:`. Counts expire: re-measure before quoting one.

**Replace, do not append.** A superseded fact is edited out, not stacked under its replacement, and each fact
lives in exactly one file: link rather than restate. The failure mode is sediment, stale layers that settle
because adding feels safe and removing feels risky. Date anything that expires.

**Doc A stays the source of truth.** This skill indexes it. A new decision is logged in Doc A by whoever owns the
session, and only when the human asks; then its row id goes into the flow file's Decisions and a line into `index.md`.

**Implementation and events.** Every PR that implements an Amazon decision gets a line "Implemented by PR #n, merged
<date>, deployed <date>" under that decision in its flow file. Every deploy, channel switch and incident gets one
dated line in `timeline.md` the same day.

| What you learned | Goes in |
|---|---|
| A decision, who made it, where it is recorded, or a decision superseded | the flow file's Decisions, and its line in `index.md` |
| An id, a column value, a volume, an API shape, a code entry point | the flow file's Facts, with date and source (code anchors: `sources/github.md`) |
| A conclusion that looked right and was not | the flow file's Traps; `traps.md` if it cuts across flows |
| A command, query or API call that worked | the flow file's How to verify; `verification.md` if generic |
| A PR, ticket or Asana state, a question asked or answered, an owed action | `open-state.md` (carries an "as of" line) |
| A deploy, a channel switch, an incident, a merge | `timeline.md` |

**At most 250 lines per flow file.** Past the cap something has stopped earning its place: prune superseded facts
before adding, never a fact that still holds.

## Hard lines

**Asana questions for the BA are posted as comments that @-mention Nitya** (`html_text` with `<a data-asana-gid="1198833652207853"/>`); a note or title edit notifies nobody (Erick, 28 Oct). Sarina = `1202380965972104`, Sahat = `49340007000266`.

**SP-API writes run only from production.** ADR 0128 makes every write refuse a production endpoint outside
production; from a laptop, use GET calls only. A refund feed (`POST_PAYMENT_ADJUSTMENT_DATA`) is not
deduplicated by Amazon and is never replayed (ADR 0129).

**ChannelAdvisor downloads stuck at `R` are re-imported one order at a time, with Erick's approval per order.**
A re-import can ship an order that ops already shipped by hand.

**No secrets, no buyer PII, read-only production** in anything you print or write here: [`verification.md`](verification.md#safety).
