=== function bool(x) ===
{ x:
  ~ return true
- else:
  ~ return false
}


=== function came_from(-> x) ===
~ return TURNS_SINCE(x) == 0


=== function halt_and_catch_fire(message) ===
>>> LOG: {message}
~ temp x = 0 / ""
