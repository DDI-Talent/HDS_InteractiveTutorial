# Load necessary libraries
library(shiny)

# Define the list of words for the Hangman game
words <- c("apple", "banana", "cherry", "grape", "orange", "watermelon", "pineapple")

# Function to pick a random word
choose_word <- function(words) {
        sample(words, 1)
}

# Initialize game state
initialize_game <- function(word) {
        list(
                word = word,
                guessed_letters = character(0),
                wrong_guesses = 0,
                max_wrong_guesses = 6
        )
}

# Update game state based on the player's guess
update_game_state <- function(game_state, guess) {
        if (!(guess %in% game_state$guessed_letters)) {
                game_state$guessed_letters <- c(game_state$guessed_letters, guess)
                if (!(guess %in% strsplit(game_state$word, "")[[1]])) {
                        game_state$wrong_guesses <- game_state$wrong_guesses + 1
                }
        }
        game_state
}

# Check if the player has won
is_winner <- function(game_state) {
        all(strsplit(game_state$word, "")[[1]] %in% game_state$guessed_letters)
}

# Check if the player has lost
is_loser <- function(game_state) {
        game_state$wrong_guesses >= game_state$max_wrong_guesses
}

# Create UI
ui <- fluidPage(
        titlePanel("Hangman Game"),
        sidebarLayout(
                sidebarPanel(
                        h3("Game Controls"),
                        textInput("guess", "Enter your guess:", ""),
                        actionButton("guess_button", "Submit Guess"),
                        actionButton("new_game", "Start New Game"),
                        br(),
                        br(),
                        h4("Game Status"),
                        textOutput("game_status"),
                        textOutput("guessed_letters"),
                        textOutput("remaining_guesses")
                ),
                mainPanel(
                        h3("Word to Guess"),
                        textOutput("word_display"),
                        br(),
                        h3("Hangman"),
                        uiOutput("hangman_image")
                )
        )
)

# Create server logic
server <- function(input, output, session) {
        # Reactive value to hold the game state
        game_state <- reactiveVal(initialize_game(choose_word(words)))
        
        # Update the game state based on user input
        observeEvent(input$guess_button, {
                guess <- tolower(input$guess)
                if (nchar(guess) == 1 && grepl("[a-z]", guess)) {
                        game_state(update_game_state(game_state(), guess))
                }
                updateTextInput(session, "guess", value = "")
        })
        
        # Start a new game
        observeEvent(input$new_game, {
                game_state(initialize_game(choose_word(words)))
        })
        
        # Display the word with blanks for unguessed letters
        output$word_display <- renderText({
                word <- game_state()$word
                guessed <- game_state()$guessed_letters
                sapply(strsplit(word, "")[[1]], function(letter) {
                        if (letter %in% guessed) {
                                letter
                        } else {
                                "_"
                        }
                }) %>% paste(collapse = " ")
        })
        
        # Display the guessed letters
        output$guessed_letters <- renderText({
                guessed <- game_state()$guessed_letters
                paste("Guessed Letters:", paste(guessed, collapse = ", "))
        })
        
        # Display the remaining guesses
        output$remaining_guesses <- renderText({
                remaining <- game_state()$max_wrong_guesses - game_state()$wrong_guesses
                paste("Remaining Wrong Guesses:", remaining)
        })
        
        # Display the game status
        output$game_status <- renderText({
                if (is_winner(game_state())) {
                        "Congratulations! You've won!"
                } else if (is_loser(game_state())) {
                        paste("Game Over! The word was:", game_state()$word)
                } else {
                        "Keep guessing!"
                }
        })
        
        # Display the hangman image
        output$hangman_image <- renderUI({
                wrong_guesses <- game_state()$wrong_guesses
                hangman_image <- paste0("https://www.hangmanwords.com/images/hangman_", wrong_guesses, ".png")
                img(src = hangman_image, alt = "Hangman Image", height = 300)
        })
}

# Run the application
shinyApp(ui = ui, server = server)
