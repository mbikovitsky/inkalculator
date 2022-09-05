=== function multiply_string(s, count) ===
~ return __multiply_string_recursive("", s, count)

=== function __multiply_string_recursive(current, s, count) ===
{ count <= 0:
  ~ return current
- else:
  ~ return __multiply_string_recursive(current + s, s, count - 1)
}
