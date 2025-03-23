# Contributing to BrogueMCP

Thank you for your interest in contributing to BrogueMCP! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Pull Request Process](#pull-request-process)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Community](#community)

## Code of Conduct

Our project is dedicated to providing a harassment-free experience for everyone, regardless of gender, gender identity and expression, sexual orientation, disability, physical appearance, body size, age, race, or religion. We do not tolerate harassment of participants in any form.

## Getting Started

1. **Fork the Repository**: Start by forking the [BrogueMCP repository](https://github.com/yourusername/BrogueMCP).

2. **Clone Your Fork**:
   ```bash
   git clone https://github.com/your-username/BrogueMCP.git
   cd BrogueMCP
   ```

3. **Set Up Development Environment**:
   - Follow the instructions in [BUILDING.md](../../BUILDING.md)
   - Set up the DM Agent as described in [DM-AI.md](../../DM-AI.md)

4. **Create a Branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

We follow a feature branch workflow:

1. **Create a Branch**: Create a branch for your feature or bugfix.
2. **Make Changes**: Implement your changes, following our coding standards.
3. **Test**: Thoroughly test your changes.
4. **Commit**: Commit your changes with clear, descriptive messages.
5. **Push**: Push your branch to your fork.
6. **Pull Request**: Create a pull request against the main repository.

### Branch Naming

Use the following convention for branch names:

- `feature/short-description` - For new features
- `bugfix/issue-number-description` - For bug fixes
- `docs/what-you-changed` - For documentation changes
- `refactor/component-name` - For code refactoring

## Coding Standards

### C Code

- **Indentation**: 4 spaces (no tabs)
- **Line Length**: 120 characters maximum
- **Brace Style**: Allman style (braces on new lines)
- **Pointer Alignment**: Right-aligned (e.g., `char *ptr`)
- **Naming Conventions**:
  - Functions: camelCase (e.g., `calculateDamage()`)
  - Variables: camelCase (e.g., `playerHealth`)
  - Structs: PascalCase (e.g., `PlayerStats`)
  - Macros/Constants: UPPERCASE_WITH_UNDERSCORES
  - File-scope variables and functions: prefixed with static

```c
/* Example of proper C code style */
#include <stdio.h>

#define MAX_PLAYERS 4

typedef struct PlayerStats
{
    int health;
    int strength;
    char *name;
} PlayerStats;

static int calculateBonus(int level, int multiplier);

int calculateDamage(PlayerStats *player, int weaponStrength)
{
    if (player == NULL)
    {
        return 0;
    }
    
    int baseDamage = player->strength + weaponStrength;
    int bonus = calculateBonus(player->level, 2);
    
    return baseDamage + bonus;
}
```

### JavaScript Code (DM Agent)

- **Indentation**: 2 spaces
- **Semicolons**: Required
- **Quotes**: Single quotes for strings
- **Naming**: camelCase for variables and functions, PascalCase for classes
- **Commenting**: JSDoc style for function documentation

```javascript
/**
 * Generates a narrative based on the event and context
 * @param {Object} event - The game event
 * @param {Object} context - The game context
 * @param {Object} memory - The memory manager
 * @returns {Promise<string>} The generated narrative
 */
async function generateNarrative(event, context, memory) {
  const prompt = buildPrompt(event, context);
  const memories = await memory.retrieveRelevantMemories(event);
  
  return await ollamaClient.generate(prompt, memories);
}
```

## Pull Request Process

1. **Update Documentation**: Ensure that documentation is updated to reflect your changes.
2. **Include Tests**: Add tests for new features or bug fixes.
3. **Update CHANGELOG**: Add an entry to the CHANGELOG.md for your changes.
4. **Submit PR**: Create a pull request with a clear title and description.
5. **Code Review**: Address any feedback from code reviews.
6. **Merge**: Once approved, your PR will be merged by a maintainer.

## Testing Guidelines

### C Code Testing

- Write tests for all new functions in the `test/` directory
- For procedural generation tests, include seed values
- Test for memory leaks using Valgrind
- Verify cross-platform functionality

### DM Agent Testing

- Write tests for all new functions in the `dm-agent/test/` directory
- Test all event types
- Verify memory system functionality
- Test across different model configurations

### Integration Testing

- Test full integration between game and DM Agent
- Verify proper event generation and handling
- Test narrative display in-game
- Check error handling and edge cases

## Documentation

Good documentation is critical for our project:

- **Code Comments**: Document complex algorithms and non-obvious behavior
- **Function Headers**: Include purpose, parameters, return values, and examples
- **README Files**: Keep them updated with current information
- **API Documentation**: Document all public APIs
- **User Guides**: Update user-facing documentation for new features

## Memory Bank Usage

When working with the DM AI memory system:

1. **Respect the Memory Schema**: Follow the established schema for different memory types.
2. **Persist Important Information**: Identify what should be stored long-term.
3. **Clean Up Temporary Data**: Don't persist unnecessary information.
4. **Test Memory Retrieval**: Verify your changes work with the memory retrieval system.

## Community

- **Discord**: Join our [Discord server](https://discord.gg/example) for discussions
- **Issues**: Use GitHub issues for bug reports and feature requests
- **Discussions**: Use GitHub discussions for general questions and ideas

## Special Thanks

By contributing to BrogueMCP, you join a community of developers dedicated to enhancing the roguelike experience with AI. We appreciate every contribution, whether it's code, documentation, testing, or ideas.

Thank you for making BrogueMCP better! 