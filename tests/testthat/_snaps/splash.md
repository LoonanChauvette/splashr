# splash() errors on unknown names with a helpful message

    Code
      splash("chartreuse")
    Condition
      Error in `FUN()`:
      ! Unknown Splash color `chartreuse`. Use a 3-digit code (e.g. "900"), a wildcard (e.g. "9_9"), or a theme color name. Valid names for theme `default`: green, cyan, blue, purple, pink, red, orange, yellow

# splash() errors on malformed codes

    Code
      splash("99")
    Condition
      Error in `FUN()`:
      ! Unknown Splash color `99`. Use a 3-digit code (e.g. "900"), a wildcard (e.g. "9_9"), or a theme color name. Valid names for theme `default`: green, cyan, blue, purple, pink, red, orange, yellow

---

    Code
      splash("9999")
    Condition
      Error in `FUN()`:
      ! Unknown Splash color `9999`. Use a 3-digit code (e.g. "900"), a wildcard (e.g. "9_9"), or a theme color name. Valid names for theme `default`: green, cyan, blue, purple, pink, red, orange, yellow

---

    Code
      splash("9x9")
    Condition
      Error in `FUN()`:
      ! Unknown Splash color `9x9`. Use a 3-digit code (e.g. "900"), a wildcard (e.g. "9_9"), or a theme color name. Valid names for theme `default`: green, cyan, blue, purple, pink, red, orange, yellow

---

    Code
      splash("9__")
    Condition
      Error in `FUN()`:
      ! Unknown Splash color `9__`. Use a 3-digit code (e.g. "900"), a wildcard (e.g. "9_9"), or a theme color name. Valid names for theme `default`: green, cyan, blue, purple, pink, red, orange, yellow

