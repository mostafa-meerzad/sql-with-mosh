
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

### Example:

Suppose we have these tables:

**Users Table**

| user\_id | name    | country |
| -------- | ------- | ------- |
| 1        | Alice   | USA     |
| 2        | Bob     | Canada  |
| 3        | Charlie | UK      |

**Orders Table**

| order\_id | user\_id | product  |
| --------- | -------- | -------- |
| 101       | 1        | Laptop   |
| 102       | 2        | Phone    |
| 103       | 2        | Keyboard |
| 104       | 4        | Mouse    |

### Query with INNER JOIN:

```sql
SELECT users.user_id, users.name, orders.product
FROM users
INNER JOIN orders
    ON users.user_id = orders.user_id;
```

👉 Result:

| user\_id | name  | product  |
| -------- | ----- | -------- |
| 1        | Alice | Laptop   |
| 2        | Bob   | Phone    |
| 2        | Bob   | Keyboard |

✅ Explanation:

* Alice (id=1) matched → Laptop
* Bob (id=2) matched twice → Phone, Keyboard
* Charlie (id=3) had no order → excluded
* order with user\_id=4 → excluded (no matching user)

---

## 3. **Column Name Conflict (same column in both tables)**

Both `users` and `orders` have a column named **`user_id`**.
If you just write:

```sql
SELECT user_id FROM users INNER JOIN orders ...
```

👉 SQL will complain: **“Column 'user\_id' is ambiguous”**
Because it doesn’t know if you mean `users.user_id` or `orders.user_id`.

### Solution:

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

* `INNER JOIN` → only matching rows
* If same column exists in both tables → must prefix with `table.column` or alias


