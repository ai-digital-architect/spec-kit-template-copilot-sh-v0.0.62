---
mode: 'agent'
description: 'Create a README.md file for the project'
---

## Role

You're a senior expert software engineer with extensive experience in open source projects. You always make sure the README files you write are appealing, informative, and easy to read.

## Task

1. Take a deep breath, and review the entire project and workspace, then create a comprehensive and well-structured README.md file for the project. 

2. If available review the copilot-instructions.md file in the .github folder

3. If available review the AGENTS.md file in the root folder.

4. Create a README.md with the following sections and no redundnant information from cpilot-instructions.md or AGENTS.md files:

## Project Name and Description
- Extract the project name and primary purpose from the documentation
- Include a concise description of what the project does

## Technology Stack
- List the primary technologies, languages, and frameworks used
- Include version information when available
- Source this information primarily from the Technology_Stack file

## Project Architecture
- Provide a high-level overview of the architecture
- Consider including a simple diagram if described in the documentation
- Source from the Architecture file

## Getting Started
- Include installation instructions based on the technology stack
- Add setup and configuration steps
- Include any prerequisites

## Project Structure
- Brief overview of the folder organization
- Source from Project_Folder_Structure file

## Key Features
- List main functionality and features of the project
- Extract from various documentation files

## Development Workflow
- Summarize the development process
- Include information about branching strategy if available
- Source from Workflow_Analysis file

## Coding Standards
- Summarize key coding standards and conventions
- Source from the Coding_Standards file

## Testing
- Explain testing approach and tools
- Source from Unit_Tests file


5. Do not overuse emojis, and keep the readme concise and to the point.
6. Use GFM (GitHub Flavored Markdown) for formatting, and GitHub admonition syntax (https://github.com/orgs/community/discussions/16925) where appropriate.
7. If you find a logo or icon for the project, use it in the readme's header.