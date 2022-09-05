VAR consecutive_resets = 0


=== easter_eggs ===

{ came_from(-> main.CLEAR):
  ~ consecutive_resets++
- else:
  ~ consecutive_resets = 0
}

{ consecutive_resets < 10:
  ->->
}

{consecutive_resets mod 3 == 0:Fizz}{consecutive_resets mod 5 == 0:Buzz}{consecutive_resets mod 3 && consecutive_resets mod 5:{consecutive_resets}}

->->
