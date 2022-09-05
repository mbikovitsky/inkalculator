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
~ x = FLOAT(x)  // This may introduce an error when converting from int,
                // but it shouldn't introduce an order-of-magnitude error...
                // I hope. I haven't noticed anything yet.

{
- x == inf() || x == -1 * inf():
  ~ return inf()
- isnan(x):
  ~ return x
}

{ -1 < x && x < 1:
  ~ return 1
- else:
  ~ return __count_significant_digits_recursive(x, 0)
}

=== function __count_significant_digits_recursive(x, digits) ===
{ -1 < x && x < 1:
  ~ return digits
- else:
  // Why are we casting to float here? Because otherwise inkjs might coerce it back
  // to an int... At least I think that's what happens.
  ~ return __count_significant_digits_recursive(FLOAT(x) / 10, digits + 1)
}
