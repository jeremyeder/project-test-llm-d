#!/bin/bash

# Create Release Checklist Script for llm-d
# Usage: ./create-release-checklist.sh [version]
# Example: ./create-release-checklist.sh v0.8

set -e

# Function to get current milestone if not provided
get_current_milestone() {
    # Get the next upcoming milestone
    CURRENT_MILESTONE=$(gh api repos/:owner/:repo/milestones \
        --jq 'map(select(.state == "open")) | sort_by(.due_on) | .[0].title' 2>/dev/null || echo "")
    
    if [ -z "$CURRENT_MILESTONE" ]; then
        echo "Error: No open milestones found. Create a milestone first."
        exit 1
    fi
    
    echo "$CURRENT_MILESTONE"
}

# Function to get milestone due date
get_milestone_due_date() {
    local version=$1
    gh api repos/:owner/:repo/milestones \
        --jq ".[] | select(.title == \"$version\") | .due_on" 2>/dev/null || echo ""
}

# Function to get milestone theme
get_milestone_theme() {
    local version=$1
    gh api repos/:owner/:repo/milestones \
        --jq ".[] | select(.title == \"$version\") | .description" 2>/dev/null | sed 's/\*\*Release Theme: \(.*\)\*\* - .*/\1/' || echo "TBD"
}

# Function to calculate week dates
calculate_week_dates() {
    local due_date=$1
    local due_timestamp=$(date -d "$due_date" +%s)
    
    # Calculate week boundaries (4 weeks before due date)
    local week4_start=$(date -d "$due_date -28 days" +%b\ %d)
    local week4_end=$(date -d "$due_date -22 days" +%b\ %d)
    local week3_start=$(date -d "$due_date -21 days" +%b\ %d)
    local week3_end=$(date -d "$due_date -8 days" +%b\ %d)
    local week2_start=$(date -d "$due_date -7 days" +%b\ %d)
    local week2_end=$(date -d "$due_date -1 days" +%b\ %d)
    local release_date=$(date -d "$due_date" +%b\ %d)
    
    echo "$week4_start-$week4_end|$week3_start-$week3_end|$week2_start-$release_date"
}

# Parse command line arguments
VERSION=${1:-$(get_current_milestone)}
DUE_DATE=$(get_milestone_due_date "$VERSION")
THEME=$(get_milestone_theme "$VERSION")

# Validate inputs
if [ -z "$DUE_DATE" ]; then
    echo "Error: Milestone $VERSION not found"
    exit 1
fi

# Check if release checklist already exists
EXISTING_ISSUE=$(gh issue list --milestone "$VERSION" --label "type/task" --search "Release Planning and Coordination" --json number --jq '.[0].number' 2>/dev/null || echo "")

if [ ! -z "$EXISTING_ISSUE" ]; then
    echo "Error: Release checklist already exists for $VERSION (Issue #$EXISTING_ISSUE)"
    exit 1
fi

# Calculate week dates
WEEK_DATES=$(calculate_week_dates "$DUE_DATE")
IFS='|' read -r WEEK1 WEEK2 WEEK3 <<< "$WEEK_DATES"

# Create release checklist issue body
RELEASE_CHECKLIST_BODY="## Release Information
- **Version**: $VERSION
- **Theme**: $THEME
- **Due Date**: $(date -d "$DUE_DATE" '+%B %d, %Y')
- **Release Lead**: TBD (assign this issue to Release Lead)

## Weekly Timeline

### 📋 Week 1 ($WEEK1): Planning & Triage
- [ ] Review project board 'This Month' column
- [ ] Confirm 5-8 core stories are ready for development
- [ ] Update release theme if still TBD
- [ ] Announce release timeline to team (#sig-release channel)
- [ ] Coordinate with extension component owners
- [ ] Create/update release branch if needed
- [ ] Send weekly status update

### 🔨 Week 2-3 ($WEEK2): Development & Integration
- [ ] Monitor core component development progress
- [ ] Ensure all PRs have proper labels and milestone assignment
- [ ] Coordinate integration testing between components
- [ ] Weekly standup reviews (Wednesday updates)
- [ ] Track blockers and escalate if needed
- [ ] Update release notes draft
- [ ] Coordinate with Red Hat product teams

### 🚀 Week 4 ($WEEK3): Release & Stabilization
- [ ] **Pre-release checklist**:
  - [ ] All core milestone issues completed or moved to next release
  - [ ] All CI/CD tests passing
  - [ ] Documentation updated
  - [ ] Quickstart guide tested and updated
  - [ ] Integration tests passing
  - [ ] Performance regression testing complete
  - [ ] Security scan complete
  - [ ] Release notes finalized

- [ ] **Release execution**:
  - [ ] Create release branch (\`release-${VERSION}\`)
  - [ ] Build and sign all core component binaries
  - [ ] Build and push container images to registry
  - [ ] Tag release with ${VERSION}.0
  - [ ] Publish release notes
  - [ ] Update compatibility matrix
  - [ ] Announce release to community
  - [ ] Update documentation website

- [ ] **Post-release**:
  - [ ] Monitor for critical issues (48 hours)
  - [ ] Update project board milestone status
  - [ ] Create next month's milestone
  - [ ] Conduct release retrospective
  - [ ] Document lessons learned

## Extension Component Coordination
- [ ] Notify extension owners of release timeline
- [ ] Track extension component releases
- [ ] Ensure compatibility declarations are updated
- [ ] Coordinate joint announcements if needed

## Success Criteria
- [ ] All core components released together as ${VERSION}.0
- [ ] Extension components coordinate independently
- [ ] No P0/P1 issues in release
- [ ] Release completed by due date
- [ ] Post-release retrospective conducted

## Communication Checkpoints
- [ ] Weekly team updates (Mondays)
- [ ] Stakeholder updates (Wednesdays)
- [ ] Community announcements (as needed)
- [ ] Release day communications

## Emergency Contacts
- **Release Lead**: TBD
- **Engineering Manager**: TBD
- **Product Manager**: TBD
- **On-call Engineer**: TBD

## Related Issues
- Epic: [Link to release epic if exists]
- Integration Testing: [Link to integration testing issue]
- Release Notes: [Link to release notes issue]

---
**⚠️ Generated Checklist**: This checklist was auto-generated. Update as needed for your specific release requirements.
**📅 Created**: $(date '+%Y-%m-%d %H:%M:%S')"

# Create the release checklist issue
echo "Creating release checklist for $VERSION..."
echo "Due date: $(date -d "$DUE_DATE" '+%B %d, %Y')"
echo "Theme: $THEME"

ISSUE_URL=$(gh issue create \
    --title "[PROCESS] $VERSION Release Planning and Coordination" \
    --body "$RELEASE_CHECKLIST_BODY" \
    --milestone "$VERSION" \
    --label "core-release,type/task,priority/high")

echo "✅ Successfully created release checklist: $ISSUE_URL"
echo "📋 Assign this issue to the Release Lead"
echo "🗓️  Review and update timeline as needed"
echo "📢 Share with team for review and feedback"

# Optional: Add to project board automatically
read -p "Add to project board automatically? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Extract issue number from URL
    ISSUE_NUMBER=$(echo "$ISSUE_URL" | sed 's/.*\/\([0-9]*\)$/\1/')
    
    # Add to project board (assumes project #6 based on current setup)
    gh project item-add 6 --owner jeremyeder --url "$ISSUE_URL" 2>/dev/null || echo "Note: Could not auto-add to project board"
    
    echo "✅ Added to project board"
fi