# context
Filtering on `coffees` table and threre are a lot of JOINs there.
# deciesion
We're fully normalizing the database. If the project grows and we see slowdowns, we can always denormalize later.
# consequences
Low speed due to JOIN a lot of tables for **filtering**