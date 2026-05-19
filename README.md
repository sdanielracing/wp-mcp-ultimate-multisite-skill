# WP MCP Ultimate Multisite Skill

> A context layer for [WP MCP Ultimate](https://github.com/AgriciDaniel/wp-mcp-ultimate) that lets you manage multiple WordPress clients from a single Claude Code session — no config changes, no repeated prompts, no switching files.

---

## The problem this solves

If you manage WordPress sites for multiple clients, every time you start a session with Claude you have to explain who the client is, what tone to use, what their phone number is, where they're located, what to put in the CTA, and so on. Every prompt. Every session.

This skill fixes that.

---

## How it works

**Once per client:** run `/add-wpworkspace`. The guided setup walks you through:

1. Choosing a workspace name
2. Pasting the MCP server config that WP MCP Ultimate generates for your site
3. Entering your WordPress username and the Application Password it generated
4. Claude auto-calculates the Base64 authorization (`username:APIkey` encoded) and asks you to confirm it before saving — so you can be sure the connection will work
5. Writing a plain-text description of the business. Claude uses this to generate the full editorial profile and the JSON-LD schema markup that powers SEO — so that data never has to be repeated in a prompt again.

**Every session:** run `/use-wpworkspace [name]`. Claude loads the entire client profile and:
1. **Automatically updates your local `.mcp.json`** to configure the `"wp-mcp-ultimate"` server with the active credentials and URL.
2. **Automatically runs a live connection check** by querying the WordPress `discover-abilities` endpoint to verify credentials.
3. Loads all client, editorial, and connection context into the session.

All of this happens instantly without requiring a restart of Claude Code (as the CLI hot-reloads the local `.mcp.json` automatically).

```
/use-wpworkspace corner-brew
```

```
✅ Workspace active: corner-brew

🌐 The Corner Brew — Café / Food & Beverage
   Independent specialty coffee shop focused on single-origin beans and a calm workspace atmosphere

📍 14 Oak Street, Portland, OR 97201
📞 +1 555 000 0001
📧 hello@example-coffee.com

✍️  Editorial profile
   Tone:     Warm, unhurried, sensory — like a good cup of coffee
   Voice:    First person plural (we/our) — the shop speaking
   Language: en-US
   Audience: Remote workers, coffee enthusiasts, locals looking for a calm spot
   Avoid:    Corporate buzzwords, urgency language, hard sells
   CTA:      Inviting, low-pressure — "come by", "we'd love to see you"

🔧 WP MCP: wp-mcp-ultimate (updated in local .mcp.json) → https://corner-brew.com
🔌 Connection: 🟢 Connection verified: OK (found 35 abilities)
```

From this point on in the session, Claude already knows:
- Who to write for and how to sound doing it
- What contact info and legal notices go in CTAs and footers
- Which WordPress site to publish to (fully connected)
- What the SEO target domain is
- What to never write

No more repeating any of it, and no manual file switching.

---

## Structured data is generated automatically

Everything you fill in about the client — business name, address, phone numbers, email, industry, description — is used by Claude to dynamically generate the correct JSON-LD schema markup for that business.

You don't write the markup. Claude builds it from the workspace data.

For a local business it generates `LocalBusiness` schema. For a professional it generates `Person` or `Physician`. For a law firm, `LegalService`. The type is inferred from the industry you describe. The values come directly from what you entered — no manual markup, no risk of mismatched data between your content and your structured data.

This means:

- **Contact info stays consistent** across content, CTAs, and schema
- **Address, phone, and email** appear correctly in rich results
- **Business hours** (if provided in the description) are included automatically
- **Legal notices** surface in the right places — footers, disclaimers, schema
- **Every post or page** Claude publishes gets the right markup for that specific client, not a generic template

The workspace is the single source of truth. Change it once, and everything — content, CTAs, and schema — updates from the same data.

---

## Skills

| Command | Description |
|---|---|
| `/use-wpworkspace [name]` | Activate a workspace and load all context into the session |
| `/use-wpworkspace` | List all configured workspaces |
| `/add-wpworkspace` | Add a new client — guided setup with credential calculation and auto-generated editorial profile |
| `/update-wpworkspace [name]` | Update a workspace — business info only, or full reset if the Application Password was revoked |

---

## Requirements

- **[Claude Code](https://claude.ai/code)** — Anthropic's CLI for Claude
- **[WP MCP Ultimate](https://github.com/AgriciDaniel/wp-mcp-ultimate)** — WordPress MCP server (must be installed and configured in `.mcp.json`)
- **WordPress** with Application Passwords enabled (Settings → Users → Application Passwords)

---

## Installation

### 1. Clone and install

```bash
git clone https://github.com/sdanielracing/wp-mcp-ultimate-multisite-skill
cd wp-mcp-ultimate-multisite-skill
chmod +x install.sh && ./install.sh
```

The installer copies both skills to `~/.claude/skills/` and creates `~/.config/wp-workspaces/workspaces.json` with example entries if none exist.

### 2. Restart Claude Code

Skills are loaded at session start — a restart is required after installation.

### 3. Add your first client

Run `/add-wpworkspace` inside Claude Code. The setup walks you through 6 steps:

**Step 1 — Choose a workspace name**
Pick a short slug you'll use to activate this client later (e.g. `corner-brew`, `harmon-legal`). No spaces or special characters.

**Step 2 — Paste your WP MCP Ultimate config block**
Copy the server entry from your `.mcp.json` file and paste it:

```json
"site_url": "https://yoursite.com",
"wp": {
  "mcp_endpoint": "https://yoursite.com/wp-json/mcp/wp-mcp-ultimate",
  "auth_header": "Basic YOUR_BASE64_HERE",
  "mcp_server": "wp-mcp-ultimate"
}
```

Claude extracts the site URL and endpoint from this. The `auth_header` value is ignored here — it gets recalculated in the next steps.

**Step 3 — Enter your WordPress username**
The username you use to log into the WP admin dashboard.

**Step 4 — Enter your Application Password**
This key is generated inside WP MCP Ultimate — not in the WordPress admin profile. Open WP MCP Ultimate, find the API key it generated for your site, and paste it here. If you can no longer see it, revoke it and generate a new one — the key is only shown once.

**Step 5 — Claude calculates and confirms your authorization**
Claude automatically encodes `username:application_password` in Base64 and shows you the result:

```
Your authorization has been calculated:

  Username:             your_username
  Application Password: xxxx xxxx xxxx xxxx
  Base64 result:        eW91cl91c2VybmFtZTp4eHh4...
  auth_header will be:  Basic eW91cl91c2VybmFtZTp4eHh4...

This was auto-calculated from your credentials to make sure it works correctly.
Confirm this is the right account before continuing.
```

You confirm before anything is saved.

**Step 6 — Describe the client**
Write a plain-text description — as detailed as you like. Include what the business does, who their customers are, the tone and voice they use, their contact details, business hours, service areas, certifications, legal notices, and anything else that should appear consistently in content, CTAs, and structured data. Claude uses this to generate the full editorial profile and JSON-LD schema automatically.

**Step 7 — Generate and confirm workspace**
Claude generates the industry classification, business description, tone, voice, audience, avoided topics, and custom CTA style based on your plain-text description. You review the formatted summary and confirm to save.

**Step 8 — Automatic server registration**
Claude automatically updates (or creates) the local `.mcp.json` file in the current working directory, writing the credentials under the standardized `"wp-mcp-ultimate"` key, and removing any obsolete WordPress server keys to prevent tool collisions.

**Step 9 — Activation & Verification**
You activate the workspace using `/use-wpworkspace [id]`. Claude will instantly connect to the site, verify the connection with a live check, and load all writing guidelines into the session.

---

## Usage

### Activate a workspace

```
/use-wpworkspace my-client
```

Claude loads all context and automatically updates `.mcp.json`. Blog writing, SEO analysis, and WordPress publishing will automatically use the correct credentials, tone, contact data, and content rules for that client — without repeating them in every prompt. No restart is needed.

### List available workspaces

```
/use-wpworkspace
```

### Add a new client

```
/add-wpworkspace
```

Fill in the form, paste your WP connection block, write a description of the client, and Claude builds the workspace, updates the local `.mcp.json`, and registers it.

### Switch between clients in the same session

You can switch workspaces instantly at any time in your session:

```
/use-wpworkspace client-a
/use-wpworkspace client-b
```

No restarts required. The active credentials and URLs are swapped dynamically in `.mcp.json` and hot-reloaded by the Claude CLI.

---

## Workspace structure

Each workspace has three sections:

```json
{
  "site_url": "https://mysite.com",
  "wp": {
    "mcp_endpoint": "https://mysite.com/wp-json/mcp/wp-mcp-ultimate",
    "auth_header": "Basic BASE64_ENCODED_CREDENTIALS",
    "mcp_server": "wp-mcp-ultimate"
  },
  "client": {
    "business_name": "Business or person name",
    "contact_name": "Contact person",
    "industry": "Inferred from description",
    "description": "1–2 sentence summary",
    "phones": ["+1 555 000 0000"],
    "whatsapp": "",
    "email": "",
    "address": "Full address",
    "site_web": "https://mysite.com",
    "legal": ["Any required legal notices"]
  },
  "editorial": {
    "tone": "Generated from your description",
    "voice": "First / third person or brand voice",
    "language": "en-US",
    "audience": "Who the content is for",
    "avoid": ["Things to never write"],
    "cta_style": "How calls to action should sound",
    "notes": "Any standing instructions"
  }
}
```

The `editorial` block is generated automatically from your client description and is used by Claude SEO, blog, and publishing tools without requiring extra prompting.

---

## How it works

The skills use Claude's built-in `Read` tool to load `workspaces.json` at activation time. No new MCP servers, no background processes, no additional dependencies beyond WP MCP Ultimate.

```
/use-wpworkspace [name]
        ↓
Read ~/.config/wp-workspaces/workspaces.json
        ↓
Load client + editorial + WP context into session
        ↓
All tools (blog, SEO, WP publish) use active workspace automatically
```

`workspaces.json` lives at `~/.config/wp-workspaces/` — outside any project directory so credentials are never accidentally committed.

---

## Project structure

```
wp-mcp-ultimate-multisite-skill/
├── install.sh                        ← one-command installer
├── workspaces.json                   ← example registry (two different industries)
├── skills/
│   ├── use-wpworkspace/
│   │   └── SKILL.md                 ← /use-wpworkspace
│   └── add-wpworkspace/
│       └── SKILL.md                 ← /add-wpworkspace
└── README.md
```

After installation, live files are at:

```
~/.claude/skills/use-wpworkspace/SKILL.md
~/.claude/skills/add-wpworkspace/SKILL.md
~/.config/wp-workspaces/workspaces.json
```

---

## Uninstall

```bash
rm -rf ~/.claude/skills/use-wpworkspace
rm -rf ~/.claude/skills/add-wpworkspace

# Optionally remove all workspace configs
# rm -rf ~/.config/wp-workspaces
```

---

## Acknowledgments

This skill was built to unlock the full potential of two tools that together make Claude a genuinely useful WordPress co-pilot:

- **[WP MCP Ultimate](https://github.com/AgriciDaniel/wp-mcp-ultimate)** by [@AgriciDaniel](https://github.com/AgriciDaniel) — the WordPress MCP server that connects Claude Code to your site. This skill is a companion layer on top of it, not a replacement. Daniel also built [Claude SEO](https://github.com/AgriciDaniel/claude-seo), a powerful SEO skill for Claude Code that this workspace system feeds automatically — contact data, schema type, target domain, and language all flow from your workspace into Claude SEO without extra prompting.

- **[Claude Blog](https://github.com/AgriciDaniel/claude-blog)** by [@AgriciDaniel](https://github.com/AgriciDaniel) — the blog writing and optimization skill for Claude Code. When a workspace is active, Claude Blog uses the editorial profile (tone, voice, audience, CTA style) from your workspace automatically, so every post is written in the right voice for the right client from the first word.

- **[Claude Code](https://claude.ai/code)** by [Anthropic](https://anthropic.com) — the AI-powered CLI and skills system everything runs on.

---

## Using Elementor?

Install the **[WP MCP Ultimate Elementor Add-on](https://github.com/sdanielracing/wp-mcp-ultimate-elementor)** — built by the author of this skill.

The original Elementor MCP toolset was created by [@msrbuilds](https://github.com/msrbuilds/elementor-mcp). This add-on is a full adaptation of that work, rebuilt from the ground up to integrate with WP MCP Ultimate instead of the MCP Adapter — so that Claude SEO and Claude Blog can read, write, and optimize Elementor-built pages the same way they work on any other WordPress site.

It adds 110+ Elementor-specific abilities: create and edit pages, containers, widgets, global colors, typography, templates, and more — all from Claude Code, without opening the editor.

If your site runs on Elementor and you want Claude to actually work with your content rather than around it, this is the missing piece.

---

## Contributing

Pull requests are welcome. For major changes please open an issue first. Test with at least two different workspace configurations before submitting.

---

## License

Copyright (C) 2026 Sergio Daniel Hernandez Hernandez

This program is free software: you can redistribute it and/or modify it under the terms of the **GNU General Public License version 3** as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
