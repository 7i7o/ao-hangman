---------
-- Hangman Game Implementation in Lua

-- Table to store game states
Games = {}
Words = { "MOON", "WORD", "GAME", "LUCK", "ABOUT", "AFTER", "AGAIN", "BELOW", "COULD", "EVERY", "FIRST", "GREAT", "HOUND",
    "INDIGO", "JUMBO", "KNIFE", "LARGE", "MIGHT", "NIGHT", "OTHER", "PLANT", "QUICK", "RAVEN", "SILVER", "TABLE", "UNDER",
    "VIOLET", "WORLD", "XENON", "YELLOW", "ZERO", "APPLE", "BANANA", "CHERRY", "DOCTOR", "ELEPHANT", "FAMILY", "GRAPES",
    "HAPPY", "IGLOO", "JUPITER", "KIWI", "LEMON", "MANGO", "NEVER", "ORANGE", "PENCIL", "QUEEN", "RIVER", "SUNNY",
    "TIGER", "UMBRELLA", "VICTOR", "WINTER", "XEROX", "YOGURT", "ZEBRA", "AIRPLANE", "BRIDGE", "CAPTAIN", "DIAMOND",
    "ELEVATOR", "FINGER", "GUITAR", "HORIZON", "ISLAND", "JACKET", "KANGAROO", "LANTERN", "MACHINE", "NINJA", "OCEAN",
    "PARADE", "QUIET", "REPTILE", "SATELLITE", "TURTLE", "UNICORN", "VANILLA", "WINDOW", "XYLOPHONE", "YELLOWSTONE",
    "ZOOLOGIST", "ACADEMIC", "BROTHER", "CAMERA", "DINOSAUR", "EXOTIC", "FANTASY", "GARDEN", "HARMONY", "INTRIGUE",
    "JOURNEY", "KALEIDOSCOPE", "LULLABY", "MYSTERIOUS", "NOVEL", "OBSERVATION", "PHOTOGRAPH", "QUOTIENT", "REFLECTION",
    "SYMBOLIZE", "TREASURE", "UNDERSTAND", "VANQUISH", "WISDOM", "XYLOGRAPH", "YESTERDAY", "ZENITH", "ALPHABETICAL",
    "BENEVOLENT", "CEREMONIAL", "DELECTABLE", "ELOQUENT", "FABULOUS", "GRACEFUL", "HARMONIOUS", "IMAGINATIVE", "JUBILANT",
    "KALEIDOSCOPIC", "LUMINOUS", "MAGNIFICENT", "NOSTALGIC", "OPULENT", "PERSUASIVE", "QUIESCENT", "RADIANT",
    "SERENDIPITY", "TRANQUIL", "UNFORGETTABLE", "VIVACIOUS", "WONDERFUL", "XANADU", "YOUTHFUL", "ZESTFUL" }

-- Function to start a new game
function startGame()
    local randomWord = Words[math.random(#Words)]
    return {
        word = randomWord,
        displayWord = string.rep("-", #randomWord),
        guessedLetters = {},
        incorrectLetters = {},
        incorrectGuesses = 0,
        maxIncorrectGuesses = math.floor(#randomWord * 1.5),
        status = "ongoing"
    }
end

Help = " start / letter X / guess XXXX / abandon / add XXXX"

function drawGame(g)
    if g.status == "ongoing" then
        return #g.word ..
            " letter word: " ..
            g.displayWord .. " | " .. g.maxIncorrectGuesses - g.incorrectGuesses .. " guesses left"
    end

    if g.status == "ended" then
        return "The word was:  " .. g.word .. " | You guessed: " .. g.displayWord
    end
end

-- Function to update the game state based on user input
function updateGame(game, message)
    local command, arg = message:match("(%a+)%s*(%a*)")

    if command == "start" then
        return "Game started! " .. drawGame(game)
    elseif command == "abandon" then
        game.status = "ended"
        return "You gave up!  " .. drawGame(game)
    elseif command == "letter" then
        local letter = arg:upper()
        if not letter:match("[A-Z]") then
            return "Invalid letter! " .. drawGame(game)
        end
        if game.guessedLetters[letter] then
            return "Already used! " .. drawGame(game)
        elseif game.incorrectLetters[letter] then
            return "Already tried!" .. drawGame(game)
        elseif game.word:find(letter, 1, true) then
            game.guessedLetters[letter] = true
            game.displayWord = game.word:gsub(".", function(c)
                return game.guessedLetters[c] and c or "-"
            end)
            if not game.displayWord:find("-", 1, true) then
                game.status = "ended"
                return "Congrats!     " .. drawGame(game)
            end
            return "Good guess!   " .. drawGame(game)
        else
            game.incorrectLetters[letter] = true
            game.incorrectGuesses = game.incorrectGuesses + 1
            if game.incorrectGuesses >= game.maxIncorrectGuesses then
                game.status = "ended"
                return "Game Over!    " .. drawGame(game)
            end
            return "Bad guess!    " .. drawGame(game)
        end
    elseif command == "guess" then
        local guess = arg:upper()
        if guess == game.word then
            game.displayWord = guess
            game.status = "ended"
            return "Congrats!     " .. drawGame(game)
        else
            game.incorrectGuesses = game.incorrectGuesses + 1
            if game.incorrectGuesses >= game.maxIncorrectGuesses then
                game.status = "ended"
                return "Game Over!    " .. drawGame(game)
            else
                return "Bad guess!    " .. drawGame(game)
            end
        end
    else
        return "Invalid command. " .. drawGame(game)
    end
end

-- Function to handle user messages
function handleMessage(userId, message)
    local command, arg = message:match("(%a+)%s*(%a*)")

    if command == "add" then
        local word = arg:upper()
        for i, w in ipairs(Words) do
            if w == word then return "Word '" .. word .. "' was already in the list of words" end
        end
        Words[#Words + 1] = word
        return "Added word '" .. word .. "' to the list"
    end

    if not Games[userId] or Games[userId].status == "ended" then
        if command ~= "start" then
            return "No games started for this user. Commands: " .. Help
        else
            Games[userId] = startGame()
        end
    end

    local response = updateGame(Games[userId], message)

    return response
end

-- ao Handlers
handlers.append(
    function(msg)
        if msg.from ~= ao.id then
            return -1
        end
    end,
    function(msg)
        table.insert(inbox, msg)
        local msgBody = ''
        for i, t in ipairs(msg.tags) do
            if t.name == "body" then
                msgBody = t.value
            end
        end
        ao.send({ body = handleMessage(msg.from, msgBody) }, msg.from)
    end,
    "hangman"
)



-- quick test:
-- print(handleMessage("user1", "add Mine"))
-- print(handleMessage("user1", "letter G"))
-- print(handleMessage("user1", "start"))
-- print(handleMessage("user1", "letter A"))
-- print(handleMessage("user1", "letter M"))
-- print(handleMessage("user1", "guess MISS"))
-- print(handleMessage("user1", "guess MOON"))
-- print(handleMessage("user1", "abandon"))
-- quick test in AO:
-- handleMessage("user1", "letter G")
-- handleMessage("user1", "start")
-- handleMessage("user1", "letter A")
-- handleMessage("user1", "letter M")
-- handleMessage("user1", "guess MISS")
-- handleMessage("user1", "guess MOON")
-- handleMessage("user1", "abandon")
