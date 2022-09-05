=== function inf() ===
~ return 1.0 / 0.0


=== function isnan(x) ===
~ return x != x


=== function round(x) ===
// https://en.wikipedia.org/wiki/Rounding#Round_half_away_from_zero
~ return sign(x) * FLOOR(abs(x) + 0.5)


=== function round2(x, digits) ===
{ x == INT(x):
  ~ return x
}
~ temp factor = FLOAT(POW(10, digits))
~ return round(x * factor) / factor


=== function sign(x) ===
{
- x >= 0:
  ~ return 1
- else:
  ~ return -1
}


=== function abs(x) ===
{ x < 0:
  ~ return -1 * x
- else: 
  ~ return x
}


=== function count_significant_digits(x) ===
{
- x == inf() || x == -1 * inf():
  ~ return inf()
- isnan(x):
  ~ return x
}

~ x = abs(x)
{ x < 0:
  // Must be INT_MIN. This will overflow, but won't change the number of digits.
  ~ x = x - 1
}

{ x < 1:
  ~ return 1
- else:
  ~ return __count_significant_digits_recursive(x, 0)
}

=== function __count_significant_digits_recursive(x, digits) ===
{ x < 1:
  ~ return digits
- else:
  ~ return __count_significant_digits_recursive(x / 10, digits + 1)
}
