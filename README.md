# Comparison of Postgres procedure languages

`psql -f test.sql postgres postgres`

- Return 42 is function returning hardcoded value 42.
- Select row selects a single row from table having 10k rows.

|test_type  | language | avg_execution_time_ms | min_execution_time_ms | max_execution_time_ms | relative_performance|
|-----------|----------|-----------------------|-----------------------|-----------------------|---------------------|
|Return 42  | SQL      |                  8.76 |                  8.49 |                  9.16 |                 1.00|
|Return 42  | PL/pgSQL |                 17.55 |                 16.90 |                 17.89 |                 2.00|
|Return 42  | Perl     |                 19.62 |                 19.36 |                 20.17 |                 2.24|
|Return 42  | Python   |                 20.60 |                 20.35 |                 20.87 |                 2.35|
|Return 42  | Tcl      |                 25.96 |                 25.08 |                 27.91 |                 2.96|
|Select Row | PL/pgSQL |                 51.97 |                 49.72 |                 58.02 |                 1.00|
|Select Row | SQL      |                191.73 |                186.58 |                202.99 |                 3.69|
|Select Row | Tcl      |                266.48 |                262.12 |                273.94 |                 5.13|
|Select Row | Perl     |                267.07 |                257.00 |                274.40 |                 5.14|
|Select Row | Python   |                351.92 |                340.68 |                365.17 |                 6.77|

