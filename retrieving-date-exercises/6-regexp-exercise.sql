-- Get the customers whose
--      first names are Elka or Ambur
--      last names end with EY or ON
--      last names start with MY or contains SE
--      last names contains B followed by R or U

SELECT * FROM customers
WHERE first_name REGEXP "Elka|Ambur";


SELECT * FROM customers
WHERE last_name REGEXP "EY$|ON$"


SELECT * FROM customers
WHERE last_name REGEXP "^MY|SE"


SELECT * FROM customers
WHERE last_name REGEXP "B[RU]"


