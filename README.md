# project-test-llm-d

This is a test repository demonstrating the lightweight project management workflow for the [llm-d project](https://github.com/llm-d/llm-d).

## 🎯 Purpose
- Test GitHub Projects workflow for monthly releases
- Demo Red Hat ↔ Open Source integration  
- Validate weekly review process

## 📋 Project Board
[View the Project Board](../../projects/1) to see:
- **Release Pipeline**: 4-column kanban (Inbox → This Month → In Progress → Done)
- **Monthly Roadmap**: Timeline view of upcoming milestones
- **Weekly Focus**: Table view of current priorities

## 🔄 Process Overview

### Weekly (15 minutes total)
- **Monday**: Triage new issues (5 min)
- **Wednesday**: Standup review of "This Month" column (10 min)

### Monthly (30 minutes)
- **Week 1**: Plan the month - select 5-8 stories
- **Week 3**: Feature freeze and testing
- **Week 4**: Release and retrospective

## 🏷️ Labels

### Priority
- `priority/urgent` - Red Hat customer blocker
- `priority/high` - Must have for monthly release
- `priority/medium` - Should have 
- `priority/low` - Nice to have

### Type  
- `type/epic` - Multi-story initiative (monthly review)
- `type/story` - Single feature/fix (weekly review if active)
- `type/task` - Implementation detail (review only if blocked)
- `type/bug` - Something broken

### Component
- `component/scheduler`, `component/kv-cache`, `component/routing`
- `component/benchmark`, `component/deployment`, `component/docs`

### Special
- `rh-priority` - Red Hat commercial requirement
- `blocked` - Cannot proceed
- `community` - External contributor

## 📊 Success Metrics
We track 3 simple metrics:
1. **Velocity**: Issues closed per month
2. **Community**: New contributors per month  
3. **Quality**: Customer-reported bugs per release

## 🤝 Red Hat Integration
Customer requirements flow into the open source backlog via:
1. Create GitHub issue with `rh-priority` label
2. Community discussion on approach
3. Implementation upstream-first
4. Include in Red Hat product releases

## 🚀 Demo Features

This test repo includes sample issues showing:
- Epic spanning multiple months
- Stories for monthly releases
- Red Hat priority customer requirements
- Community contributions
- Bug reports with different severities

## ⚡ Next Steps
1. [Create GitHub Project](../../projects/new) with Release Pipeline view
2. Import the sample issues (see Issues tab)
3. Run through a weekly review with your team
4. Demo to stakeholders

---
**The goal: Process should enable speed, not replace it.**