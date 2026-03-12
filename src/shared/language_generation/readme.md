# language_generation.gd
This file is responsible for converting a text written in natural language into gibberish to be spoken by the alien, returned in a format easily readable by other files.

## find_seed_from_preset_words()
Currently executed on \_ready(). Must be executed just once, on the game initialisation. This function finds the seed and sorts the internal array of syllables in order to ensure that certain phrases in natural language get converted to specific phrases in alien language.
### Inputs:
Currently none. In future, the natural and alien phrase pairs might be extracted into a separate file. The (unsorted) list of available syllables should also probably be extracted to somewhere available globally.
### Output:
Currently none - the function modifies the global variables in this file.

## process_dialogue(input_str)
Converts a string of text in natural language into an array of syllables, based on the previously generated seed.
### Inputs:
- **input\_str** - A string of text in natural language.
- ***seed_val** (default: final_seed) - An integer given by the seed seeking function, while the global variable final_seed is not found yet. **Should not be used elsewhere!***
- ***seed_seeking_mode** (default: false) - A boolean used to tell the function that it should return integers returned by the randomisation with the current seed instead of the actual syllables. Given by the seed seeking function, **should not be used elsewhere!***
### Output:
- A three-dimensional array of strings, **output[x][y][z]**, where:
  - **x** marks the line in the input string
  - **y** marks the word in the line
  - **z** marks the individual syllables of the word
- *When seed_seeking_mode == true, the function returns a three-dimensional array of integers instead.*
