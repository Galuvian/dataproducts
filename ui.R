shinyUI(pageWithSidebar(
  headerPanel("Surplus Military Equipment Data"),
  sidebarPanel(
    h2('Select a State'),
    uiOutput("choose_state")
    ),
  mainPanel(
    p("This app shows a visualization of where surplus military equipment has been transferred to state and local law enforement agencies.
      
      This may take a few seconds to load..."),
    plotOutput('mainGraph'),
    p("The data used here is courtesy of the New York Times via ",a("github",href="http://github.com/TheUpshot/Military-Surplus-Gear")),
    p("See my 'pitch' that accompanies this app ",a("here",href=""))
  )
  )
)