-- Hangman Game Implementation in Lua

-- Table to store game states
Games = {}
Words = {"MOON", "WORD", "GAME", "LUCK"}

-- Function to start a new game
function startGame()
    local randomWord = Words[math.random(#Words)]
    local res = {
        word = randomWord,
        guessedLetters = {},
        incorrectGuesses = 0,
        status = "ongoing"
    }
    res.maxIncorrectGuesses = math.floor(#res.word * 1.5)
    return res
end

Help = " start / letter X / guess XXXX / abandon"

-- Function to update the game state based on user input
function updateGame(game, message)
    local command, arg = message:match("(%a+)%s*(%a*)")

    if command == "start" then
        return "Game started: " .. #game.word .. " letter word: " .. string.rep("-", #game.word)

    elseif command == "abandon" then
        return "You gave up:  The word was: '" .. game.word .. "'"

    elseif command == "letter" then
        local letter = arg:upper()
        if letter:match("[A-Z]") then
            if game.guessedLetters[letter] then
                return "You already guessed this letter. " .. game.status
            elseif game.word:find(letter, 1, true) then
                game.guessedLetters[letter] = true
                local displayWord = game.word:gsub(".", function(c)
                    return game.guessedLetters[c] and c or "-"
                end)
                if not displayWord:find("-", 1, true) then
                    game.status = "Congratulations! You guessed the word '" .. game.word .. "'"
                end
                return "Good guess:   " .. #game.word .. " letter word: " .. displayWord
            else
                game.incorrectGuesses = game.incorrectGuesses + 1
                if game.incorrectGuesses >= game.maxIncorrectGuesses then
                    game.status = "Game over. The word was: '" .. game.word .. "'"
                end
                local displayWord = game.word:gsub(".", function(c)
                    return game.guessedLetters[c] and c or "-"
                end)
                return "Bad guess:    " .. #game.word .. " letter word: " .. displayWord
            end
        else
            return "Invalid input! " .. game.status
        end

    elseif command == "guess" then
        local guess = arg:upper()
        if guess == game.word then
            game.status = "Congratulations! You guessed the word '" .. game.word .. "'"
        else
            game.incorrectGuesses = game.incorrectGuesses + 1
            if game.incorrectGuesses >= game.maxIncorrectGuesses then
                game.status = "Game over. The word was: '" .. game.word .. "'"
            else
                return "Bad guess:    " .. #game.word .. " letter word: " .. string.rep("-", #game.word) .. ". You have " .. game.maxIncorrectGuesses - game.incorrectGuesses .. " guesses left."
            end
        end
        return game.status

    else
        return "Invalid command. " .. game.status
    end
end

-- Function to handle user messages
function handleMessage(userId, message)
    if not Games[userId] or Games[userId].status == "ended" then
        local command, arg = message:match("(%a+)%s*(%a*)")

        if command ~= "start" then
            return "No games started for this user. Commands: ".. Help
        else
            Games[userId] = startGame()
        end
    end

    local response = updateGame(Games[userId], message)
    if Games[userId].status ~= "ongoing" then
        Games[userId].status = "ended"
    end

    return response
end

-- ao Handlers
handlers.append(
    function (msg)
        if msg.from ~= ao.id then
            return -1
        end
    end,
    function (msg)
        table.insert(inbox, msg)
        local msgBody = ''
        for i, t in ipairs(msg.tags) do
            if t.name == "body" then
                msgBody = t.value
            end
        end
        ao.send( { body = handleMessage(msg.from, msgBody) }, msg.from )
    end,
    "hangman"
)






-- test:
-- print(handleMessage("user1", "letter G"))
-- print(handleMessage("user1", "start"))
-- print(handleMessage("user1", "letter A"))
-- print(handleMessage("user1", "letter M"))
-- print(handleMessage("user1", "guess MISS"))
-- print(handleMessage("user1", "guess MOON"))
-- print(handleMessage("user1", "abandon"))
-- test in AO:
-- handleMessage("user1", "letter G")
-- handleMessage("user1", "start")
-- handleMessage("user1", "letter A")
-- handleMessage("user1", "letter M")
-- handleMessage("user1", "guess MISS")
-- handleMessage("user1", "guess MOON")
-- handleMessage("user1", "abandon")
