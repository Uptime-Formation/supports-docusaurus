# GitHub Copilot Instructions

## Project Context

This is a TypeScript-based REST API using Express.js and PostgreSQL.

## Code Conventions

### TypeScript
- Always use TypeScript strict mode
- Prefer interfaces over type aliases for object shapes
- Use explicit return types for functions

### Naming
- Variables/Functions: camelCase
- Classes/Interfaces: PascalCase
- Constants: UPPER_SNAKE_CASE
- Files: kebab-case.ts

### Import Paths
Use absolute imports with @ alias:
```typescript
import { UserService } from '@/services/user.service';
// NOT: import { UserService } from '../../../services/user.service';
```

## Framework-Specific

### Express Routes
```typescript
router.post('/users',
  validateBody(createUserSchema),
  asyncHandler(async (req, res) => {
    const user = await userService.create(req.body);
    res.status(201).json(user);
  })
);
```

### Database Access
Always use the repository pattern:
```typescript
// Good
const user = await userRepository.findById(id);

// Bad
const user = await db.query('SELECT * FROM users WHERE id = $1', [id]);
```

## Testing

When suggesting tests:
- Use Jest with TypeScript
- Mock external dependencies
- Follow AAA pattern (Arrange, Act, Assert)
- Test both success and error cases

Example:
```typescript
describe('UserService', () => {
  describe('create', () => {
    it('should create a new user with hashed password', async () => {
      // Arrange
      const userData = { email: 'test@example.com', password: 'password123' };

      // Act
      const user = await userService.create(userData);

      // Assert
      expect(user.email).toBe(userData.email);
      expect(user.password).not.toBe(userData.password);
    });
  });
});
```

## Security

When generating code involving:
- Authentication: Use JWT with refresh tokens
- Passwords: Always hash with bcrypt (min 10 rounds)
- SQL: Use parameterized queries ONLY
- API keys: Read from environment variables

## Error Handling

Use custom error classes:
```typescript
throw new AppError('Resource not found', 404);
// NOT: throw new Error('Not found');
```

## Commit Messages

When suggesting commit messages, use:
```
type(scope): description

---
🤖 AI-Assisted Development
Tool: GitHub Copilot
Suggestion: [What was suggested]
Human review: [What was validated]
```
