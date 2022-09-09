# title: Inkalculator
# author: Biko's House of Horrors
# theme: dark

INCLUDE common.ink
INCLUDE math.ink
INCLUDE string.ink
INCLUDE easter_eggs.ink


VAR MAX_DIGITS = -42

VAR memory = 0.0
VAR result = 0.0
VAR argument = 0.0
VAR decimal = 0
VAR operator = ""
VAR typing = false
VAR dirty = false
VAR error = false
VAR constant = 0.0
VAR constant_operator = ""
VAR typing_constant = false
VAR calculations_performed = 0


{ count_significant_digits(FLOAT(99999999)) != 8:
  ~ MAX_DIGITS = 7  // The engine is using f32 (probably)
- else:
  ~ MAX_DIGITS = 8  // The engine is using f64
}

-> main


=== main ===
~ display()

-> easter_eggs ->

~ temp rounded_memory = 0

  ~ temp i = 0
- (__keypad_loop_top)
  { i <= 9:
    <- process_digit(i)
    ~ i++
    -> __keypad_loop_top
  }

<- process_operator("+")
<- process_operator("-")
<- process_operator("*")
<- process_operator("/")

+ {not error} [>>> KEYPAD: MC]
  ~ memory = 0.0

+ {not error} [>>> KEYPAD: MR]
  ~ argument = memory
  ~ decimal = 0
  ~ typing = false
  ~ dirty = true

+ {not error} [>>> KEYPAD: MS]
  ~ memory = argument

+ {not error} [>>> KEYPAD: M+]
  ~ memory += argument
  ~ rounded_memory = memory
  { not round_for_display(rounded_memory):
    ~ error = true
    ~ memory = 0.0
  }

+ {not error} [>>> KEYPAD: M-]
  ~ memory -= argument
  ~ rounded_memory = memory
  { not round_for_display(rounded_memory):
    ~ error = true
    ~ memory = 0.0
  }

+ {not error} [>>> KEYPAD: .]
  { not typing:
    ~ argument = 0.0
    ~ typing = true
    ~ dirty = true
  }
  { decimal >= 0:
    ~ decimal = -1
  }
  { typing_constant:
    ~ constant = argument
  }

+ {not error} [>>> KEYPAD: +-]
  ~ argument = -1 * argument
  { typing_constant:
    ~ constant = argument
  }

+ {not error} [>>> KEYPAD: 1/x]
  ~ argument = FLOAT(1) / argument
  ~ decimal = 0
  ~ typing = false
  ~ dirty = true
  { typing_constant:
    ~ constant = argument
  }

+ {not error} [>>> KEYPAD: sqrt]
  ~ argument = POW(argument, 0.5)
  ~ decimal = 0
  ~ typing = false
  ~ dirty = true
  { typing_constant:
    ~ constant = argument
  }

+ {not error} [>>> KEYPAD: %]
  ~ argument = result * argument / 100.0
  ~ decimal = 0
  ~ typing = false
  ~ dirty = true
  { typing_constant:
    ~ constant = argument
  }

+ (CLEAR) [>>> KEYPAD: AC]
  ~ clear()
  
+ {not error} [>>> KEYPAD: =]
  ~ flush(true)
  ~ typing_constant = false
  ~ calculations_performed++

- -> main

= process_digit(i)
+ {can_type()} [>>> KEYPAD: {i}]
  { typing:
    { decimal < 0:
      ~ argument += sign(argument) * FLOAT(i) * POW(10, decimal)
      ~ decimal--
    - else:
      ~ argument = argument * 10 + sign(argument) * i
    }
  - else:
    ~ argument = FLOAT(i)
    ~ typing = true
    ~ dirty = true
  }
  { typing_constant:
    ~ constant = argument
  }
  -> main

= process_operator(op)
+ {not error} [>>> KEYPAD: {op}]
  { dirty:
    ~ flush(false)
  }
  ~ operator = op
  ~ constant_operator = op
  ~ constant = argument
  ~ typing_constant = true
  -> main


=== function clear() ===
~ result = 0.0
~ argument = 0.0
~ decimal = 0
~ operator = ""
~ typing = false
~ dirty = false
~ error = false
~ constant = 0.0
~ constant_operator = ""
~ typing_constant = false


=== function can_type() ===
{ error:
  ~ return false
}

{ not typing:
  ~ return true
}

~ temp total_digits = count_significant_digits(argument)
{ decimal < 0:
  ~ total_digits += abs(decimal) - 1
}

~ return total_digits < MAX_DIGITS


=== function flush(use_constant) ===
{ 
- operator:
  ~ result = do_operation(result, argument, operator)
- use_constant && bool(constant_operator):
  ~ result = do_operation(argument, constant, constant_operator)
- else:
  ~ result = argument
}

~ argument = result
~ decimal = 0
~ operator = ""
~ typing = false
~ dirty = false


=== function do_operation(a, b, op) ===
{ op:
- "+":
  ~ return a + b
- "-":
  ~ return a - b
- "*":
  ~ return a * b
- "/":
  { a == 0 && b == 0:
    ~ return inf()  // Technically should be NaN, but inkjs can't handle it
                    // https://github.com/y-lohse/inkjs/blob/v2.1.0/src/engine/Value.ts#L50
  - else:
    ~ return FLOAT(a) / b
  }
- else:
  ERROR # NOMEMORY
  ~ halt_and_catch_fire("Invalid operator \"{op}\"")
}


=== function round_for_display(ref x) ===
{ isnan(x):
  ~ return false
}

~ temp significant_digits = count_significant_digits(x)
{ significant_digits > MAX_DIGITS:
  ~ return false
}
~ x = round2(x, MAX_DIGITS - significant_digits)
~ return true


=== function display() ===

~ temp rounded = argument
{ not round_for_display(rounded):
  ~ error = true
}

{ error:
  ERROR # NOMEMORY
  ~ return
}

~ temp text = "{rounded}"

// Display trailing zeroes when typing
{ rounded == INT(rounded) && decimal < 0:
  ~ text += "." + multiply_string("0", abs(decimal) - 1)
}

{ memory:
  {text} # MEMORY
- else:
  {text} # NOMEMORY
}
