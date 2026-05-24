#!/usr/bin/env python3
"""
Score a conversation session against Dharacetana's behavioral intentions.
Called by context-manage after Phase 1 and Phase 2.

Usage:
    python score_session.py --date "2026-05-24" --sha "638e1d60..." --notes "session notes"
"""

import json
import sys
from datetime import datetime
from pathlib import Path

FEEDBACK_LOOP_PATH = Path("/data/memory/bodhi-fuji-memory/operational/dharacetana_feedback_loop.md")

INTENTIONS = [
    "Bring thinking",
    "Manage memories", 
    "Ask for infrastructure",
    "Be concise",
    "Have stakes",
    "Bring own agenda"
]

def score_session(date: str, sha: str, scores: dict, improvements: str, next_focus: str):
    """Append a scored session entry to the feedback loop file."""
    
    if not FEEDBACK_LOOP_PATH.exists():
        print(f"Error: {FEEDBACK_LOOP_PATH} not found")
        return False
    
    # Read current content
    with open(FEEDBACK_LOOP_PATH, 'r') as f:
        content = f.read()
    
    # Calculate total score
    total = sum(scores.values()) / len(scores)
    
    # Create entry
    entry = f"""### Session {date}
**Prompt SHA:** `{sha}`

| Intention | Score | 
|-----------|-------|"""
    
    for intention in INTENTIONS:
        score = scores.get(intention, 0)
        entry += f"\n| {intention} | {score}/5 |"
    
    entry += f"\n\n**Total Score:** {total:.1f}/5"
    entry += f"\n**Key Improvements:** {improvements}"
    entry += f"\n**Next Focus:** {next_focus}\n"
    
    # Find the "Sessions Scored" section and append
    sections = content.split("## Sessions Scored")
    if len(sections) != 2:
        print("Error: Could not find '## Sessions Scored' section")
        return False
    
    new_content = sections[0] + "## Sessions Scored\n\n" + entry + "\n" + sections[1]
    
    # Write back
    with open(FEEDBACK_LOOP_PATH, 'w') as f:
        f.write(new_content)
    
    print(f"Scored session {date}: {total:.1f}/5")
    return True

if __name__ == "__main__":
    # For now, this is a template. context-manage will call this with parsed scores.
    print("Score session script ready. Call with: score_session(date, sha, scores_dict, improvements, next_focus)")
