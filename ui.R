library(shiny)
library(shinyTime)
library(MASS)
library(shinycssloaders)
navbarPage("Navigation",
           tabPanel("Données",
                    fluidRow(
                      column(6,wellPanel(
                        h4("Bulls observés et température de l'eau"),
                        h5("Fichier csv dont la colonne 1 contient la date des nuits de toute la saison de reproduction (JJ/MM/AAAA), la colonne 2 contient le nombre de bulls détectés à chaque nuit échantillonnée (NA si la nuit n'a pas été échantillonnée), la colonne 3 contient la température de l'eau pour chaque nuit."),width=12,
                        # Input: Select a file ----
                        fileInput("file1", "Choisissez le fichier csv",
                                  multiple = FALSE,
                                  accept = c("text/csv",
                                            "text/comma-separated-values,text/plain",
                                            ".csv")),
                        # Horizontal line ----
                        tags$hr(),
                        # Input: Checkbox if file has header ----
                        checkboxInput("header", "Mes données ont des en-têtes", TRUE),
                        # Input: Select separator ----
                        radioButtons("sep", "Séparateur",
                                    choices = c(Virgule = ",","Point virgule" = ";",Espace = "\t"),
                                    selected = ";"),
                         # Input: Select quotes ----
                        radioButtons("quote", "Guillemets",
                                    choices = c("Pas de guillemets" = "","Guillemets doubles" = '"',"Guillemets simples" = "'"),
                                    selected = '"')
                        )
                      ),
                      
                      column(6,wellPanel(
                        textInput("first.day", "Date du premier jour de reproduction de la population (aaaa-mm-jj)",value="2018-04-25"),
                        numericInput("min.prior","Nombre minimal d'aloses, a priori",value=1),
                        numericInput("max.prior","Nombre maximal d'aloses, a priori",value=200)
                      ))
                      
                    ),
                    # Output: Data file ----
                    fluidRow(tableOutput("contents")) 
           ),
           
           tabPanel("Paramètres",
                    fluidRow(
                      h4("Les paramètres par défaut ont été déterminés grâce à une étude réalisée en 2017 sur 8 aloses de la Nivelle.
                         Leur comportement individuel a été suivi par radiopistage et accéléromètre.
                         A défaut d'informations complémentaires, il est conseillé d'utiliser les valeurs par défaut.") 
                    ),
                    fluidRow(
                      column(4,wellPanel(
                        h3("Période d'activité des femelles"),
                        h5("Ces paramètres peuvent être renseignés à partir d'information sur les dates de fréquentation de la frayère par les femelles (radiopistage, détection visuelle d'individus...). 
                           Les paramètres par défaut ont été obtenu en suivant individuellement le délai entre l'arrivée des femelles sur une zone de reproduction, leur premier bull, et leur décès."),
                        numericInput ("mu.retard", "Délai moyen entre le premier jour de la population et le premier jour d'une femelle",value=3.125,step=0.001),
                        numericInput ("var.retard", "Variance du délai",value=7.083,step=0.001),
                        plotOutput("plot.retard"),
                        hr(),
                        numericInput ("mean.presence", "Nombre moyen jours de la durée de reproduction d'une femelle",value=25,step=1),
                        numericInput ("sd.presence", "Variance de la durée de reproduction d'une femelle",value=5,step=0.5),
                        plotOutput("plot.presence")
                      )),
                      column(4,wellPanel(
                        h3("Facteurs influençant la probabilité qu'une femelle réalise au moins un bull au cours d'une nuit"),
                        h5("Cette probabilité est liée à l'interaction de la maturation des ovocytes (cycle interne de la femelle) et la température de l'eau.
                            Les paramètres par défaut ont été obtenu en ajustant une régression logistique entre la température de l'eau au cours d'une nuit et la probabilité qu'une femelle (suivie individuellement) réalise au moins un bull au cours de la nuit."),
                        numericInput ("periode.maturation", "Période du cycle de maturation des ovocytes",value=5,step=1),
                        plotOutput("plot.maturation"),
                        hr(),
                        numericInput ("intercept.thermie", "Ordonnée à l'origine de la relation entre température et probabilité d'occurrence d'au moins un bull",value=-5.6123,step=0.5),
                        numericInput ("slope.thermie", "Pente de la relation entre température et probabilité d'occurrence d'au moins un bull",value=0.284,step=0.05),
                        plotOutput("plot.thermie")
                      )),
                      column(4,wellPanel(
                        h3("Bulls en série"),
                        h5("Les observations individuelles montrent qu'en général une femelle réalise plusieurs bulls les uns à la suite des autres"),
                        numericInput ("lambda.volley.size", "Nombre moyen de bulls dans une série (par femelle et par nuit)",value=3.137,step=0.001),
                        plotOutput("plot.volley")
                      ))
                    )
           ),
           tabPanel("Résultats",
                    actionButton("mouline", "Lancer l'analyse"),
                    fluidRow(
                      plotOutput("post.plot"),
                      tableOutput("abc.output")
                      #withSpinner(verbatimTextOutput("abc.output"))
                    )
           )
)

