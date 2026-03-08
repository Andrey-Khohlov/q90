# context
PostgreSQL DECIMAL slow, MONEY ambiguous with localization → using INTEGER with decimal places defined by currency field

# decision
Store monetary values as INTEGER (minor currency units), encode decimal places in currency field

# consequences
+ Fast integer arithmetic
+ No localization ambiguity
+ Consistent precision control
- Requires client-side division by 10^decimals for display