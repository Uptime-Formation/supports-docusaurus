# Stack : Node.js + Express + TypeScript

## Configuration pour `.cursorrules` ou `CLAUDE.md`

### Langage et version
- Node.js 20 LTS
- TypeScript strict
- tsconfig.json avec strict: true

### Framework
- Express.js avec typescript-express
- Middleware pattern pour validation et auth
- Async/await obligatoire

### Base de données
- Prisma ORM (schéma source de vérité)
- Migrations auto avec Prisma Migrate

---

## Exemple : Middleware et route

```typescript
// middleware/auth.ts
export const requireAuth = (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers.authorization?.split(" ")[1];
  if (!token) return res.status(401).json({ error: "Unauthorized" });
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!);
    (req as any).user = decoded;
    next();
  } catch {
    return res.status(403).json({ error: "Invalid token" });
  }
};

// routes/users.ts
router.post("/users", requireAuth, async (req: Request, res: Response) => {
  const { email, name } = req.body;
  if (!email || !name) {
    return res.status(400).json({ error: "Missing fields" });
  }
  
  const user = await prisma.user.create({
    data: { email, name }
  });
  
  return res.status(201).json(user);
});
```

---

## Test avec Jest

```typescript
describe("POST /users", () => {
  it("should create user with valid token", async () => {
    const response = await request(app)
      .post("/users")
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ email: "test@example.com", name: "Test" });
    
    expect(response.status).toBe(201);
    expect(response.body.email).toBe("test@example.com");
  });
  
  it("should reject without token", async () => {
    const response = await request(app)
      .post("/users")
      .send({ email: "test@example.com", name: "Test" });
    
    expect(response.status).toBe(401);
  });
});
```
