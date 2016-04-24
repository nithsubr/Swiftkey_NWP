library(shiny)
library(RCurl)
library(data.table)
library(tau)

data_html <- " "

load("df4_KN.rds")

load("df3_KN.rds")

load("df2_KN.rds")

load("df1_KN.rds")

df1_tmp <- df1[order(-df1$prob_int), ][1:3] 

df1 <- data.table(df1)
df2 <- data.table(df2)
df3 <- data.table(df3)
df4 <- data.table(df4)
setkey(df4, word_1, word_2, word_3)
setkey(df3, word_1, word_2)
setkey(df2, word_1)

rb_choice <- "  "

shinyServer(
  
  function(input, output) 
    
  {
    
    observe({
      
      withProgress(message = "Loading Data", value = 0,
                   {
                     
                     if(input$radio != rb_choice && input$radio == "kn")
                     {
                       
                       rb_choice <- input$radio
                       
                       load("df4_KN.rds")
                       
                       load("df3_KN.rds")
                       
                       load("df2_KN.rds")
                       
                       load("df1_KN.rds")
                       
                       df1_tmp <- df1[order(-df1$prob_int), ][1:3] 
                       
                       df1 <- data.table(df1)
                       df2 <- data.table(df2)
                       df3 <- data.table(df3)
                       df4 <- data.table(df4)
                       setkey(df4, word_1, word_2, word_3)
                       setkey(df3, word_1, word_2)
                       setkey(df2, word_1)
                       
                     } else {
                       
                       if(input$radio != rb_choice && input$radio == "gt")
                       {
                         
                         rb_choice <- input$radio
                         
                         load("df4_GT.rds")
                         
                         load("df3_GT.rds")
                         
                         load("df2_GT.rds")
                         
                         load("df1_GT.rds")
                         
                         df1_tmp <- df1[order(-df1$prob_int), ][1:3] 
                         
                         df1 <- data.table(df1)
                         df2 <- data.table(df2)
                         df3 <- data.table(df3)
                         df4 <- data.table(df4)
                         setkey(df4, word_1, word_2, word_3)
                         setkey(df3, word_1, word_2)
                         setkey(df2, word_1)
                         
                       }
                       
                     }
                     
                     
                   }) })
    
    pred <- reactive(#input$go, 
      
      {
        # process the term
        term <- tolower(input$term)
        term <- tokenize(term)
        term <- term[which(!term == " ")]
        len <- length(term)
        
        term_tmp <- term
        
        found <- 0
        found1 <- 0
        found2 <- 0
        found3 <- 0
        
        pred1 = " "
        pred2 = " "
        pred3 = " "
        
        if(len >= 3)
        {
          
          term <- term[(len-2):len]
          
          term[1] <- df1[word == term[1], "pred", with = F]
          term[2] <- df1[word == term[2], "pred", with = F]
          term[3] <- df1[word == term[3], "pred", with = F]
          
          tmp = data.frame(df4[word_1 == term[1] & word_2 == term[2] & word_3 == term[3], "pred", with = FALSE])
          
          pred1 = tmp[1,1]
          pred2 = tmp[2,1]  
          pred3 = tmp[3,1]
          
          if(is.na(pred1)) pred1 <- " "
          if(is.na(pred2)) pred2 <- " "
          if(is.na(pred3)) pred3 <- " "
          
          if(pred1 != " ") {found1 <- 1}
          if(pred2 != " ") {found2 <- 1}
          if(pred3 != " ") {found3 <- 1}
          if(found1 == 1 && found2 == 1 && found3 == 1) found <- 1
        }
        
        if(len >= 2 && found == 0)
        {
          
          term <- term_tmp
          term <- term[(len-1):len]        
          
          term[1] <- df1[word == term[1], "pred", with = F]
          term[2] <- df1[word == term[2], "pred", with = F]
          
          tmp = data.frame(df3[word_1 == term[1] & word_2 == term[2], "pred", with = FALSE])
          
          if(is.na(pred1)) pred1 <- " "
          if(is.na(pred2)) pred2 <- " "
          if(is.na(pred3)) pred3 <- " "
          
          if(pred1 == " ") 
          {
            pred1 = tmp[1,1]
            pred2 = tmp[2,1]
            pred3 = tmp[3,1]
            
          } else {
            
            if(pred2 == " ") 
            {
              tmp <- tmp[tmp$pred != pred1, ]
              pred2 = tmp[1]
              pred3 = tmp[2]
              
            } else {
              
              if(pred3 == " ") 
              {
                tmp <- tmp[(tmp$pred != pred1 & tmp$pred != pred2), ]
                pred3 = tmp[1]
              }
            }
          }
          
          if(is.na(pred1)) pred1 <- " "
          if(is.na(pred2)) pred2 <- " "
          if(is.na(pred3)) pred3 <- " "
          
          if(pred1 != " ") {found1 <- 1}
          if(pred2 != " ") {found2 <- 1}
          if(pred3 != " ") {found3 <- 1}
          if(found1 == 1 && found2 == 1 && found3 == 1) found <- 1
          
        }
        
        if(len >= 1 && found == 0)
        {
          term <- term_tmp
          term <- term[len]
          
          term <- df1[word == term[1], "pred", with = F]
          
          tmp = data.frame(df2[word_1 == term, "pred", with = FALSE])
          
          if(is.na(pred1)) pred1 <- " "
          if(is.na(pred2)) pred2 <- " "
          if(is.na(pred3)) pred3 <- " "
          
          if(pred1 == " ") 
          {
            pred1 = tmp[1,1]
            pred2 = tmp[2,1]
            pred3 = tmp[3,1]
            
          } else {
            
            if(pred2 == " ") 
            {
              tmp <- tmp[tmp$pred != pred1, ]
              pred2 = tmp[1]
              pred3 = tmp[2]
              
            } else {
              
              if(pred3 == " ") 
              {
                tmp <- tmp[(tmp$pred != pred1 & tmp$pred != pred2), ]
                pred3 = tmp[1]
              }
            }
          }
          
          if(is.na(pred1)) pred1 <- " "
          if(is.na(pred2)) pred2 <- " "
          if(is.na(pred3)) pred3 <- " "
          
          if(pred1 != " ") {found1 <- 1}
          if(pred2 != " ") {found2 <- 1}
          if(pred3 != " ") {found3 <- 1}
          if(found1 == 1 && found2 == 1 && found3 == 1) found <- 1
          
        }
        
        if(found == 0)
          
        {
          
          if(is.na(pred1)) pred1 <- " "
          if(is.na(pred2)) pred2 <- " "
          if(is.na(pred3)) pred3 <- " "
          
          if(pred1 == " ")
          {
            pred1 = df1_tmp[1, "pred"]
            pred2 = df1_tmp[2, "pred"]
            pred3 = df1_tmp[3, "pred"]
            
          } else {
            
            if(pred2 == " ")
            {
              tmp <- df1_tmp[df1_tmp$pred != pred1, ]
              pred2 = df1_tmp[1, "pred"]
              pred3 = df1_tmp[2, "pred"]
              
            } else
              
            {
              if(pred3 == " ")
              {
                tmp <- df1_tmp[(df1_tmp$pred != pred1 & df1_tmp$pred != pred2), ]
                pred3 = df1_tmp[1, "pred"]
              }
            }
            
          }
          
        }
        
        pred1 <- df1[pred == pred1, "word", with = FALSE]
        pred2 <- df1[pred == pred2, "word", with = FALSE]
        pred3 <- df1[pred == pred3, "word", with = FALSE]
        
        wa <- data.frame(term = paste("Input Text", input$term, sep = " : "), pred1 = as.vector(pred1[[1]]), pred2 = as.vector(pred2[[1]]), pred3 =  as.vector(pred3[1]))
        
        return(wa)
        
      })
    
    observe({
      
      wa <- pred()
      
      output$term <- renderText(as.character(wa[,1]))
      output$pred1 <- renderText(as.character(wa[,2]))
      output$pred2 <- renderText(as.character(wa[,3]))
      output$pred3 <- renderText(as.character(wa[,4]))
      
    })
    
    
  })
