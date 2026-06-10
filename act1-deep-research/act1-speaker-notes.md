# Act 1 — Speaker Notes & Stage-Ready Examples

> Punchy, on-stage version of the [full report](./act1-research-report.md). One block per slide: the line to say, the number to show, and the example to tell. ✅ = safe to claim · ⚠️ = hedge it · 🔴 = don't say it.

---

### Slide 1 — Title & Agenda
**Say:** "For the next 90 minutes the through-line is one sentence: *make every token count.* Not 'spend less' — *count.* Optimize for agent quality, and lower spend follows automatically. Act 1 is why that's true; Acts 2–5 are how."

---

### Slide 2 — Why This Matters
**The hook:** "As of **eight days ago** — June 1, 2026 — GitHub Copilot stopped billing you per *request* and started billing you per *token*."

**Show:** `1 AI Credit = $0.01` · billed on **input + output + cached tokens** · at each model's **published API rate.**

**The killer quote (GitHub's own blog, verbatim):**
> *"a quick chat question and a multi-hour autonomous coding session can cost the user the same amount."*

**Say:** "That sentence is GitHub admitting the old model hid waste. It doesn't anymore. Every wasted token is now a line on someone's bill — yours, or your org's."

✅ Safe — primary source. ⚠️ Note prices unchanged (Pro $10, Pro+ $39, Business $19, Enterprise $39); completions still free.

---

### Slide 3 — The "Gambling" Anti-Pattern
**The story (NASA analogy):** "The old workflow was: fire 20 rockets at the moon and hope one lands. Lazy one-line prompt, almost no context, and when it fails — just retry. Re-roll the dice."

**Ground it:** GitHub literally priced that the same as a one-line question — so gambling was *rational* under flat billing. Now it isn't.

**Tease the mechanism:** "Here's the trap nobody sees: a retry isn't free, and it isn't even *linear*. We'll see why on the next slide."

✅ The cost mechanics are verified (see slide 4).

---

### Slide 4 — Why Gambling Broke
**The number to show:** A 20-step agent loop = **~210,000 input tokens, not 20,000.**

**Say:** "Agents are stateless. Every step re-sends the *entire* conversation so far. Step 20 re-sends steps 1 through 19. That's `1+2+…+N` — it grows with the **square** of task length. ProjectDiscovery calls it the **agentic tax.**"

**Why it breaks at scale:** "At 2–4 agents a day, you eat the quadratic cost and never notice. At dozens-to-hundreds — the 'AI engineer' workflow — every lazy prompt makes the trajectory longer, every retry restarts that `N²` bill from zero. The curve detaches from your budget."

**Real example to cite:** ProjectDiscovery's own agents — *"system prompts are 2,500+ lines of YAML, over 20K tokens"* — re-sent on **every one of 40 steps** = 800K tokens of system prompt alone, for one task.

✅ Augment Code's worked example confirms 210K (= `20×21/2 × 1000`).

---

### Slide 5 — Make Every Token Count
**The reframe:** "The instinct is to make the fuel cheaper — switch to a cheaper-per-token model. But that's just gambling with cheaper chips. A cheaper model still pays the **quadratic tax** on the same bloated, wandering, retry-heavy run."

**Show:** Agentic tasks consume **~1,000× more tokens than code chat** (Stanford Digital Economy Lab) — and **input tokens dominate the cost.**

**Say:** "When input tokens dominate and agents are a thousand times hungrier, the only structural lever is **fewer, better-targeted runs that finish in fewer steps.** Quality *is* the cost optimization."

🔴 **Don't say** "1,000× more than ChatGPT" — the baseline is *code chat*, not a consumer chatbot. ⚠️ Goldman's "24× token demand by 2030" is a *forecast* — say so.

---

### Slide 6 — The Compounding-Error Problem
**The whole slide in one table:**

| Per-step accuracy | over 50 steps |
|---|---|
| **99%** | **60.5%** |
| **95%** | **7.7%** |

**Say:** "Success over a trajectory is `p^N`. Drop from 99% to 95% per step — sounds tiny — and your 50-step task goes from a coin-flip-you-win to **almost never finishing.** Four percentage points per step = an 8× collapse in success."

**The honest twist (this *strengthens* your case):** "And that's the *optimistic* curve. Research from Cambridge and Max Planck (ICLR 2026) shows per-step accuracy actually **degrades** as the run gets longer — the model **conditions on its own earlier mistakes.** Bigger models don't fix it. So long, junk-filled context doesn't just cost more — it makes the agent *dumber as it goes.*"

✅ Math is exact; both arXiv papers confirm. ⚠️ Frame `p^N` as a *mechanism*, not a proven law (Ord hedges).

---

### Slide 7 — Reducing Context = Both Levers
**Say:** "Here's why context discipline is the rare move that wins on *both* axes at once. That 20K-token system prompt? Stateless agents re-send it **every single turn** — 40 times on a 40-step task. Trim the context and you cut the per-turn bill *and* you raise per-step accuracy by removing distractions the model can't tell are irrelevant."

**One line:** "Quality and cost aren't a trade-off here. The same action — less junk in the window — moves both."

✅ ProjectDiscovery's 20K × 40 example is the concrete demo.

---

### Slide 8 — The Maturity Spectrum
**Show:** METR — *"the length of tasks AI agents can complete at 50% reliability has doubled roughly **every 7 months for 6 years.**"*

**The reality-check datapoint:** "A GPT-5 agent has a 2h17m 'time horizon' — but on tasks in its *own* range it only *reliably* finishes **one-third.** A '2-hour horizon' is not '2 hours of reliability.'"

**Say:** "At ~10 agents a day, tuning your setup is low-ROI — just do the work. But the frontier is doubling every few months. The 'AI engineer' running *hundreds* of async agents is arriving fast — and at that scale, because reliability compounds as `p^N`, **every single percentage point of per-step quality compounds into the difference between a system that ships and one that thrashes.** That's who the rest of this talk is for."

⚠️ METR figures are model-snapshot-specific and domain-bounded to research-engineering tasks.

---

## The 3 numbers to memorize
1. **60.5% vs 7.7%** — 99% vs 95% per step, over 50 steps. (The thesis in one stat.)
2. **210,000 not 20,000** — tokens for a 20-step loop. (The quadratic agentic tax.)
3. **June 1, 2026 · 1 credit = $0.01 · input + output + cached** — the billing flip that puts waste on your bill.

## The 3 verbatim quotes to drop
- GitHub: *"a quick chat question and a multi-hour autonomous coding session can cost the user the same amount."*
- ProjectDiscovery: *"On a 40-step task, you're sending that 20K-token system prompt 40 times."*
- ICLR 2026: *"models become more likely to make mistakes when the context contains their errors from prior turns."*

## The 2 traps to avoid on stage
- 🔴 "Costs doubled since January" — single weak source (Ed Zitron). Use GitHub's "escalating/unsustainable" instead.
- 🔴 "Agents use 1,000× more than ChatGPT" — the verified baseline is **code chat**, and it's a Stanford study, not a Tom's Hardware claim.
