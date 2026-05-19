#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "WP MCP Ultimate Multisite Skill — Installer"
echo "============================================"
echo ""

# Install skills
echo "Installing skills..."
mkdir -p ~/.claude/skills/use-wpworkspace
mkdir -p ~/.claude/skills/add-wpworkspace
mkdir -p ~/.claude/skills/update-wpworkspace

cp skills/use-wpworkspace/SKILL.md ~/.claude/skills/use-wpworkspace/SKILL.md
cp skills/add-wpworkspace/SKILL.md ~/.claude/skills/add-wpworkspace/SKILL.md
cp skills/update-wpworkspace/SKILL.md ~/.claude/skills/update-wpworkspace/SKILL.md

echo -e "${GREEN}✅ /use-wpworkspace skill installed${NC}"
echo -e "${GREEN}✅ /add-wpworkspace skill installed${NC}"
echo -e "${GREEN}✅ /update-wpworkspace skill installed${NC}"

# Create workspace registry
mkdir -p ~/.config/wp-workspaces

if [ ! -f ~/.config/wp-workspaces/workspaces.json ]; then
  cp workspaces.json ~/.config/wp-workspaces/workspaces.json
  echo -e "${GREEN}✅ Created ~/.config/wp-workspaces/workspaces.json${NC}"
  echo -e "${YELLOW}   → Edit this file and add your site credentials${NC}"
else
  echo -e "${YELLOW}⚠️  ~/.config/wp-workspaces/workspaces.json already exists — not overwritten${NC}"
fi

echo ""
echo "Done. Restart Claude Code and run:"
echo ""
echo "  /use-wpworkspace <name>    activate a workspace"
echo "  /add-wpworkspace           add a new doctor/site"
echo ""
