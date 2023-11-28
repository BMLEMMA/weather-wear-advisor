
## Login page
# Create a user data frame

############################## Section 1 ########################################################
user_data <- data.frame(Username = c("user1", "user2"),
                        Password = c("123", "456"), 
                        favorite_location=c("New York", "London"))

# Create a folder on your desktop (change the path as needed)
folder_path <- file.path("~/Desktop", "UserInformation")

# Create the folder if it doesn't exist
if (!dir.exists(folder_path)) {
  dir.create(folder_path)
}

# Save user data to a CSV file in the folder
write.csv(user_data, file.path(folder_path, "user_data.csv"))

################################################################################################

########################################section 2 ###############################################
install.packages("shiny")

library("shiny")
library("readr")
library("httr")

ui <- fluidPage(
  titlePanel("User Management"),
  sidebarLayout(
    sidebarPanel(
      textInput("username", "Enter username"),
      textInput("favorite_location", "Enter Favorite Location"),
      passwordInput("password", "Enter password"),
      actionButton("addUser", "Add User")
    ),
    mainPanel(
      tableOutput("userTable"),
      textOutput("weather_info")
    )
  )
)

#################################################################################################

#################################################section 3 ######################################

server <- function(input, output, session) {
  observeEvent(input$addUser, {
    # Get username, password, and location from user input
    new_username <- input$username
    new_password <- input$password
    new_location <- input$favorite_location
    
    # Add new user to the data frame
    new_user <- data.frame(Username = new_username, Password = new_password, favorite_location=new_location)
    user_data <<- rbind(user_data, new_user)
    
    # Write the updated user data to the CSV file
    write_csv(user_data, file.path(folder_path, "user_data.csv"), col_names = TRUE)
  })
  
  output$userTable <- renderTable({
    user_data
  })
  
  observe({
    # Make weather API request based on the first user's favorite location
    response <- GET(
      url = "http://api.weatherstack.com/current",
      query = list(
        access_key = "5c9d683ef624cf06dde4f408321c79fb",
        query = user_data$favorite_location[1]
      )
    )
    weather_info <- content(response)
    output$weather_info <- renderText({
      paste("Current weather in", user_data$favorite_location[1], "is", weather_info$current$temperature, "°C")
    })
    
    
  })
}

##################################section 5 ########################################################

shinyApp(ui, server)
