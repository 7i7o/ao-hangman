# Lua Hangman

Hangman (word-guessing) game implementation in Lua

## How to play

The game works by receiving messages and replying to them with options.

### Available messages:

- "start" Starts a new game with a random word. Replies how many letters the word has and the game status.
- "abandon" Ends the game and replies with the word-guessing
- "letter [letter]" Guess if the letter [letter] is included (only latin letters). Replies Good or Bad Guess and the game status
- "guess [word]" Guess if the word to guess is [word]. Replies if you guessed and the game ended, or if you wasted a guess and the game status.

## Examples:

"User message" -> "Game response"

- "start" -> "Game started. 4 letter word: - - - -"
- "letter A" -> "Not included. 4 letter word: - - - -"
- "letter M" -> "Included. 4 letter word: M - - -"
- "guess MISS" -> "Bad guess. 4 letter word: M - - -"
- "guess MOON" -> "Good Guess! Congratulations! You guessed the word 'MOON'"
- "abandon" -> "Game ended. The word was: 'MOON'"