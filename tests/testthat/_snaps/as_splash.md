# as_splash() errors on malformed hex

    Code
      as_splash("#ff000")
    Condition
      Error in `parse_hex()`:
      ! Each hex color must be 3 or 6 hex digits (optionally prefixed with '#').

---

    Code
      as_splash("ff")
    Condition
      Error in `parse_hex()`:
      ! Each hex color must be 3 or 6 hex digits (optionally prefixed with '#').

---

    Code
      as_splash("#gggggg")
    Condition
      Error in `parse_hex()`:
      ! Hex colors must contain only 0-9 and a-f (case insensitive).

