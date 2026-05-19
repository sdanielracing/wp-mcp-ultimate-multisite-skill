# Skill: use-wpworkspace

Activates a client workspace and loads all context for the session: client profile, editorial guidelines, WP credentials, and site configuration.

## Invocation

```
/use-wpworkspace [name]
/use-wpworkspace coffee-shop
/use-wpworkspace             ← no argument: lists available workspaces
```

## Behavior

### No argument
1. Read `~/.config/wp-workspaces/workspaces.json`
2. List all workspaces with name, industry, and URL
3. Ask which one to activate

### With workspace name
1. Read `~/.config/wp-workspaces/workspaces.json`
2. Find the workspace — if not found, list available and ask to choose
3. Automatically update or create the local `.mcp.json` file in the current working directory.
   - Set/overwrite the `"wp-mcp-ultimate"` key under `"mcpServers"` with the workspace's connection endpoint and authorization headers:
     ```json
     "wp-mcp-ultimate": {
       "type": "streamable-http",
       "url": "[wp.mcp_endpoint]",
       "headers": {
         "Authorization": "[wp.auth_header]"
       }
     }
     ```
   - Preserve any other non-WordPress MCP servers configured in `.mcp.json`.
   - Remove any previous/colliding WordPress MCP servers from the `"mcpServers"` dictionary (e.g. keys matching `"wp-cirujanoencdmx"`, `"wp-prostaclinic"`, or other site names) to avoid tool collisions.
4. **Verify MCP Connection**:
   - Immediately execute the `wp-mcp-ultimate/discover-abilities` tool (using the newly updated credentials and URL).
   - If the connection succeeds, count the registered WordPress abilities found and display a success status (`🟢 Connection verified: OK (found X abilities)`).
   - If the connection fails (e.g., authorization error, network issue, or invalid URL), display a warning status (`🔴 Connection verification failed: [brief description of error]`) and warn the user to check their workspace credentials.
5. Load full context and return the confirmation below.

## Output on activation

```
✅ Workspace active: [id]

🌐 [client.business_name] — [client.industry]
   [client.description]

📍 [client.address]
📞 [client.phones]
[if whatsapp] 💬 [client.whatsapp]
[if email] 📧 [client.email]
[if legal] 📋 [client.legal joined by " | "]

✍️  Editorial profile:
   Tone:     [editorial.tone]
   Voice:    [editorial.voice]
   Language: [editorial.language]
   Audience: [editorial.audience]
[if editorial.avoid] ⚠️  Avoid: [editorial.avoid joined by ", "]
[if editorial.notes] 📌 [editorial.notes]

🔧 WP MCP: wp-mcp-ultimate (updated in local .mcp.json) → [site_url]
🔌 Connection: [Verification Status Message]
```

After this, Claude holds all context for the session. No need to repeat client details in subsequent prompts.

## How this context feeds other tools

Once active, this workspace context automatically informs:

- **Content / blog writing** — tone, voice, language, audience, CTAs, and legal notices from `editorial`
- **WP publishing** — credentials and endpoint from `wp` (routed through the `wp-mcp-ultimate` MCP server)
- **SEO** — target domain from `site_url`, language from `editorial.language`
- **CTAs and footers** — business name, contact, and legal from `client`
- **Anything in `editorial.notes`** — apply to all content without being asked

## Notes

- Registry lives at `~/.config/wp-workspaces/workspaces.json`
- To add a new client: `/add-wpworkspace`
- To generate an auth header: `echo -n "user:app_password" | base64`
- Active workspace persists for the session until another `/use-wpworkspace` is called

