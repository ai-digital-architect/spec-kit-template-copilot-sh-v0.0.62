
# Customimzation for Claude
.claude/
├── config.yml                         # Global configuration
├── README.md                          # Documentation for this folder
├── claude-instructions.md             # Main codebase instructions
├── .claudeignore                      # Files/patterns to exclude
│
├── chat-modes/                        # Different interaction modes
│   ├── README.md
│   ├── debug.yml
│   ├── refactor.yml
│   ├── code-review.yml
│   ├── documentation.yml
│   └── architect.yml
│
├── prompts/                           # Reusable prompt templates
│   ├── README.md
│   ├── templates/
│   │   ├── bug-fix.md
│   │   ├── feature-request.md
│   │   ├── code-review.md
│   │   └── test-generation.md
│   └── snippets/
│       └── common-instructions.txt
│
├── workflows/                         # Multi-step automated workflows
│   ├── README.md
│   ├── feature-development.yml
│   ├── bug-triage.yml
│   ├── refactoring-flow.yml
│   └── release-prep.yml
│
├── skills/                            # Custom skills (most important!)
│   ├── README.md
│   ├── index.yml                      # Skills registry
│   │
│   ├── project/                       # Project-specific skills
│   │   ├── architecture/
│   │   │   ├── SKILL.md
│   │   │   ├── examples/
│   │   │   └── diagrams/
│   │   │
│   │   ├── domain-knowledge/
│   │   │   ├── SKILL.md
│   │   │   └── glossary.md
│   │   │
│   │   └── api-patterns/
│   │       ├── SKILL.md
│   │       └── examples/
│   │
│   └── shared/                        # Reusable across projects
│       ├── testing-best-practices/
│       ├── security-review/
│       └── performance-optimization/
│
├── context/                           # Additional context files
│   ├── architecture.md
│   ├── conventions.md
│   ├── tech-stack.md
│   ├── dependencies.md
│   └── team-standards.md
│
└── agents/                            # Custom agent configurations
    ├── README.md
    ├── code-reviewer.yml
    ├── test-writer.yml
    └── documentation-agent.yml


🎯 Best Practices
For Skills

One skill per domain - Don't mix concerns (e.g., separate architecture from testing)
Rich examples - Include code examples for common scenarios
Clear triggers - Define when Claude should use the skill
Keep updated - Update skills when architecture changes
Version control - Track skill changes in git

For Instructions

Be specific - Vague instructions lead to inconsistent results
Include examples - Show what good looks like
Update regularly - Keep in sync with codebase changes
Team alignment - Get team buy-in on conventions

For Chat Modes

Purpose-driven - Each mode should have a clear purpose
Contextual - Load relevant skills and context automatically
Customizable - Allow per-project customization

For Workflows

Step-by-step - Break complex tasks into manageable steps
Interactive - Allow user input at decision points
Reusable - Make workflows general enough for multiple use cases


🚀 Usage Tips
Activating Custom Configurations
bash# Claude Code will auto-discover .claude/ in your repo
claude-code chat

# Use specific chat mode
claude-code chat --mode code-review

# Run a workflow
claude-code workflow run feature-development

# Load specific skill
claude-code chat --skill architecture
Priority Order

.claude/config.yml settings
Chat mode specific configurations
Auto-loaded skills from skills/index.yml
claude-instructions.md
Context files
