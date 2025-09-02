# Joins

## 1. **What is a JOIN?**

A JOIN combines rows from two or more tables based on a related column.
Think of it like:
👉 Table A = “Users” (who they are)
👉 Table B = “Orders” (what they bought)
👉 JOIN them = “Which user bought what”

**Note**: in MySQL you can just type `JOIN` or `INNER JOIN` it works the same way, the `INNER` word is optional.

**Syntax**:

```sql
SELECT *  "your columns selection"
FROM table_1   "the first table you want to combine columns"
JOIN table_2    "the second table you want to combine columns with"
ON  condition    "the condition that you want to join columns based on "

```

---

## 2. **INNER JOIN**

An **INNER JOIN** returns only the rows that have a **match in both tables**.
If there’s no match, that row is excluded.

### Example

Suppose we have these tables:

**Users Table**

| user_id | name    | country |
| ------- | ------- | ------- |
| 1       | Alice   | USA     |
| 2       | Bob     | Canada  |
| 3       | Charlie | UK      |

**Orders Table**

| order_id | user_id | product  |
| -------- | ------- | -------- |
| 101      | 1       | Laptop   |
| 102      | 2       | Phone    |
| 103      | 2       | Keyboard |
| 104      | 4       | Mouse    |

### Query with INNER JOIN

```sql
SELECT users.user_id, users.name, orders.product
FROM users
INNER JOIN orders
    ON users.user_id = orders.user_id;
```

👉 Result:

| user_id | name  | product  |
| ------- | ----- | -------- |
| 1       | Alice | Laptop   |
| 2       | Bob   | Phone    |
| 2       | Bob   | Keyboard |

✅ Explanation:

- Alice (id=1) matched → Laptop
- Bob (id=2) matched twice → Phone, Keyboard
- Charlie (id=3) had no order → excluded
- order with user_id=4 → excluded (no matching user)

---

## 3. **Column Name Conflict (same column in both tables)**

Both `users` and `orders` have a column named **`user_id`**.
If you just write:

```sql
SELECT user_id FROM users INNER JOIN orders ...
```

👉 SQL will complain: **“Column 'user_id' is ambiguous”**
Because it doesn’t know if you mean `users.user_id` or `orders.user_id`.

### Solution

Always **prefix with the table (or alias)**:

```sql
SELECT users.user_id, orders.user_id
FROM users
INNER JOIN orders ON users.user_id = orders.user_id;
```

👉 Or shorter, use aliases:

```sql
SELECT u.user_id AS user_from_users, o.user_id AS user_from_orders
FROM users AS u
INNER JOIN orders AS o
    ON u.user_id = o.user_id;
```

This way you control exactly which `user_id` you want.

---

⚡ Recap:

- `INNER JOIN` → only matching rows
- If same column exists in both tables → must prefix with `table.column` or alias

## 4. Using aliases

Use alias to make your join query short and easy to understand:

```sql
SELECT u.user_id, u.name, o.product
FROM users u
JOIN orders o ON u.user_id = o.user_id;

```

```sql
SELECT u.user_id, u.name, o.product
FROM users AS u
JOIN orders AS o ON u.user_id = o.user_id;

```

- AS is optional for table aliases; both styles are fine.

- Prefer aliases in joins to keep the SELECT list tidy and to avoid typos.

## 5. Alternative syntax when the join keys share the same name: USING

```sql
SELECT
  user_id,        -- note: no qualifier now
  u.name,
  o.product
FROM users u
JOIN orders o
USING (user_id);

```

### What changes with USING

- The join key(s) named in USING are coalesced into a single output column called user_id.

- You now refer to it unqualified (user_id).

- Trying to reference u.user_id or o.user_id after USING will usually error, because the output has a single merged user_id.

Tip: USING is neat for common keys, but many teams still prefer ON ... = ... for clarity and portability.

## Importance of ON phrase in JOINs

# 1. What happens if you JOIN with **no `ON` condition**?

If you write:

```sql
SELECT *
FROM users
JOIN orders;
```

(or in some SQL flavors, if you omit `ON` but don’t use `USING`), what you actually get is a **CROSS JOIN** (also called a **Cartesian product**).

👉 This means: **every row from `users` is paired with every row from `orders`**.

---

### Example

**Users**

| user_id | name  |
| ------- | ----- |
| 1       | Alice |
| 2       | Bob   |

**Orders**

| order_id | user_id | product  |
| -------- | ------- | -------- |
| 101      | 1       | Laptop   |
| 102      | 2       | Phone    |
| 103      | 2       | Keyboard |

---

### CROSS JOIN result

Without `ON`, SQL pairs **each row from users with every row from orders**:

| user_id | name  | order_id | user_id | product  |
| ------- | ----- | -------- | ------- | -------- |
| 1       | Alice | 101      | 1       | Laptop   |
| 1       | Alice | 102      | 2       | Phone    |
| 1       | Alice | 103      | 2       | Keyboard |
| 2       | Bob   | 101      | 1       | Laptop   |
| 2       | Bob   | 102      | 2       | Phone    |
| 2       | Bob   | 103      | 2       | Keyboard |

- That’s **2 users × 3 orders = 6 rows**.
- In general: if table A has _m_ rows and table B has _n_ rows, a CROSS JOIN gives _m × n_ rows.
- Notice that most of these rows **don’t make sense** (e.g., Bob paired with Alice’s Laptop order).

This is why **joining with no condition is almost never what you want** (unless you’re deliberately building a grid of combinations, like all color–size pairs).

---

# 2. What happens when you add `ON users.user_id = orders.user_id`?

Now you’re telling SQL: _“Don’t just pair everything — only keep the pairs where the user IDs match.”_

```sql
SELECT u.user_id, u.name, o.product
FROM users u
JOIN orders o
  ON u.user_id = o.user_id;
```

---

### Step 1 — SQL still starts by doing a CROSS JOIN in theory

It considers every possible `(user, order)` pair. (Databases optimize this heavily behind the scenes, but logically, that’s what happens.)

### Step 2 — Apply the `ON` condition

Keep only the pairs where `u.user_id = o.user_id`.

From the big 6-row CROSS JOIN above, only these survive:

| user_id | name  | product  |
| ------- | ----- | -------- |
| 1       | Alice | Laptop   |
| 2       | Bob   | Phone    |
| 2       | Bob   | Keyboard |

✅ This is now an **INNER JOIN result**.

---

# 3. Why is `ON` so important?

- **Without `ON`:** you explode the dataset into meaningless combinations (CROSS JOIN).
- **With `ON`:** you filter down to meaningful matches between rows.

👉 So you can think of `ON` as the **rule that connects rows between tables**. Without it, there’s no relationship — just chaos.

---

# 4. Bonus: what if the `ON` condition isn’t equality?

The `ON` doesn’t _have_ to be `=` — it can be any boolean condition:

```sql
JOIN orders o
  ON u.user_id = o.user_id
     AND o.created_at >= DATE '2025-01-01'
```

- This still matches users to their orders, but only keeps **recent** orders.
- Some advanced cases even join on ranges (`u.birthday BETWEEN o.start_date AND o.end_date`), but equality on keys is the norm.

---

✅ **Summary:**

- No `ON` → CROSS JOIN (every row with every row).
- With `ON` → INNER JOIN (keep only pairs where condition is true).
- Internally, SQL thinks “CROSS JOIN first, then filter by ON.”

---

## Where could WHERE, ORDER BY, and LIMIT go?

```sql
SELECT u.user_id, u.name, o.product
FROM users u
JOIN orders o ON u.user_id = o.user_id
WHERE o.created_at >= DATE '2025-01-01'   -- filter rows after the join
ORDER BY u.name ASC                        -- sort the final result
LIMIT 100;
```

- Remember the execution order: FROM/JOIN → WHERE → SELECT → ORDER BY → LIMIT.

- That’s why you can use table columns in WHERE, but can’t use a SELECT-alias there (the alias doesn’t exist yet).
