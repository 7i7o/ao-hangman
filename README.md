# Lua Hangman

Hangman (word-guessing) game implementation in Lua

## How to play

The game works by receiving messages and replying to them with options.

### Available messages:

- "start" Starts a new game with a random word. Replies how many letters the word has and the game status.
- "abandon" Ends the game and replies with the word-guessing
- "letter [letter]" Guess if the letter [letter] is included (only latin letters). Replies Good or Bad Guess and the game status
- "guess [word]" Guess if the word to guess is [word]. Replies if you guessed and the game ended, or if you wasted a guess and the game status.
- "add [word]" Add the word [word] into the list of possibilities.

## Examples:

| Player message | Game response                                                |
| -------------- | ------------------------------------------------------------ |
| `start`        | `Game started! 6 letter word: ------ \| 9 guesses left`      |
| `letter A`     | `Bad guess!    6 letter word: ------ \| 8 guesses left`      |
| `letter E`     | `Good guess!   6 letter word: -E---- \| 8 guesses left`      |
| `guess LENTIL` | `Bad guess!    6 letter word: -E---- \| 7 guesses left`      |
| `guess PENCIL` | `Congrats!     The word was:  PENCIL \| You guessed: PENCIL` |
| `abandon`      | `You gave up!  The word was:  PENCIL \| You guessed: -E----` |
| `add LENTIL`   | `Added word 'LENTIL' to the list`                            |
| `add LENTIL`   | `Word 'LENTIL' was already in the list of words`             |

## Version 0.0.1

First working version is in AO process `_iXqmk0xFd8jg3V3xgDcTrhSVU65HckkMbV9LsXIIM8`

From any AOS process you can send a message by:

`send("_iXqmk0xFd8jg3V3xgDcTrhSVU65HckkMbV9LsXIIM8", "your_message")`

And then check your `inbox` 😉
