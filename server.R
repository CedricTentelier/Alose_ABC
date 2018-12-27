# Charge les biblioth�ques n�cessaires � l'ex�cution du script
library(msm)
library(lubridate)
library(MASS)
library(EasyABC)
library(abc)
library(shinycssloaders)
library(Hmisc)

function(input, output, session) {
  alt.shad.spawn<-function(N, 
                           first.day=input$first.day,mu.retard=input$mu.retard, var.retard=input$var.retard, 
                           mean.presence=input$mean.presence,sd.presence=input$sd.presence,
                           periode.maturation=input$periode.maturation, 
                           intercept.thermie=input$intercept.thermie,slope.thermie=input$slope.thermie,
                           lambda.volley.size=input$lambda.volley.size,
                           sampling.plan.path=input$file1$datapath,
                           temperature.path=NULL){
    
    #Charge le jeu de donn?es et en tire un vecteur de temps et de temp?ratures
    ech<-read.csv(input$file1$datapath,header = input$header,sep = input$sep,quote = input$quote)
    time<-1:nrow(ech)
    temperature<-ech[,3]

    retard<-rnegbin(N,mu=mu.retard,theta=mu.retard^2/(var.retard-mu.retard))+1 #le delai d'arrivée sur la frayère
    presence<-round(rnorm(N,mean=mean.presence,sd=sd.presence)) #la durée de presence sur la frayère
    maturation<-0.5+0.5*sin((2*pi/periode.maturation)*time+rpois(1,5)) # la maturation des ovocytes suit une sinusoïde avec 5j de période
    #plot(time,maturation,type="l")
    thermie<-1/(1+exp(-(intercept.thermie+slope.thermie*temperature))) #la température influence la probabilité de bull
    #plot(temperature,thermie)
    spawning.night<-matrix(data=0,nrow=length(time),ncol=N)
    for(i in 1:N)
      spawning.night[retard[i]:(retard[i]+presence[i]-1),i]<-rbinom(presence[i],1,maturation*thermie)
    #rowSums(spawning.night)
    #plot(time,rowSums(spawning.night))
    
    #volley.size.obs<-c(1,1,3,3,2,3,1,2,1,4,6,3,2,5,3,2,4,5,1,2,1,8,4,4,6,7,2,2,4,1,4,1,6,3,3,3,3)
    #fitdistr(volley.size.obs,"gamma")
    volley.size<-matrix(data=rpois(n=N*length(time),lambda=lambda.volley.size),nrow=length(time),ncol=N)
    #mean(volley.size)
    bulls.per.night<-spawning.night*volley.size
    
    mean(colSums(bulls.per.night))
    
    dates<-ymd(first.day)+days(time)-1
    total.data<-data.frame(dates,"nbulls"=rowSums(bulls.per.night))
    
    sampled.data<-subset(total.data,subset=total.data$dates %in% dmy(as.character(ech[which(!is.na(ech[,2])),1])))
    #sampled.data<-subset(total.data,subset=as.logical(colSums(sapply(total.data$dates, '%within%', interval(ech$start,ech$end),simplify=T))))
    
    return(c(sum(sampled.data$nbulls,na.rm=T),max(sampled.data$nbulls,na.rm=T)))
  }
  #This is the same function as above, but using only the number of females as an argument
  #because easyABC algorithms work with functions whose only arguments are the parameters to infer
  alt.shad.spawn.4ABC<-function(n.females){
    alt.shad.spawn(N=round(n.females))
  }
  
  ########## END of FUNCTIONS #############  
  
### Plot the distributions & relations corresponding to user's input parameters
  #Histogram of delay until a female's first spawning act
  output$plot.retard <- renderPlot({
    hist(rnegbin(1000,mu=input$mu.retard,theta=input$mu.retard^2/(input$var.retard-input$mu.retard))+1, freq=F,main="Délai entre le premier bull de la saison\n et le premier bull de chaque femelle",xlab="Délai (jours)",ylab="Fréquence" )
  })
  #Histogram of duration of presence of a female on the spawning ground
  output$plot.presence <- renderPlot({
    hist(round(rnorm(1000,mean=input$mean.presence,sd=input$sd.presence)),freq=F,main="Nombre de jour de présence\n de chaque femelle sur la frayère",xlab="Présence (jours)",ylab="Fréquence"  )
  })
  #Line plot of the sinus function for oocyte maturation
  output$plot.maturation <- renderPlot({
    plot(1:input$mean.presence,0.5+0.5*sin((2*pi/input$periode.maturation)*(1:input$mean.presence)),type="l",main="Rythme de maturation des ovocytes",xlab="Temps (jours)",ylab="Maturité du lot d'ovocytes")
  })
  #Line plot of the logistic relation between temperature and probability that a volley of spawning act will occur
  output$plot.thermie <- renderPlot({
    plot(seq(12,22,0.1),1/(1+exp(-(input$intercept.thermie+input$slope.thermie*seq(12,22,0.1)))),type="l",main="Effet de la température sur\n la probabilité de faire au moins un bull",xlab="Température (°C)",ylab="p(bull>0)")
  })
  #Histogram of the number of spawning acts in a volley
  output$plot.volley <- renderPlot({
    hist(rpois(n=1000,lambda=input$lambda.volley.size),freq=F,main="Nombre de bulls dans une série",xlab="Nombre de bulls",ylab="Fréquence")
  })
  
  dodo<-reactive(read.csv(input$file1$datapath,
                          header = input$header,
                          sep = input$sep,
                          quote = input$quote))
  output$contents <- renderTable({
    
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, head of that data file by default,
    # or all rows if selected, will be shown.
    
    req(input$file1)
    
    # when reading semicolon separated files,
    # having a comma separator causes `read.csv` to error
    tryCatch(
      {
        df <- read.csv(input$file1$datapath,
                       header = input$header,
                       sep = input$sep,
                       quote = input$quote)
      },
      error = function(e) {
        # return a safeError if a parsing error occurs
        stop(safeError(e))
      }
    )
    
    return(df)
    
  })
  
  observeEvent(input$mouline,{
    prior.abc<-list(c("unif",input$min.prior,input$max.prior))
    summary.stats.abc<-c(sum(dodo()[,2],na.rm=T),max(dodo()[,2],na.rm=T))
    #summary.stats.abc<-isolate(c(input$bull_total,input$bull_max))
    abc.lenormand<-ABC_sequential(method="Lenormand",model=alt.shad.spawn.4ABC,prior=prior.abc,nb_simul=100,summary_stat_target = summary.stats.abc)
    d<-density(abc.lenormand$param,weights=abc.lenormand$weights)
    x<-data.frame(t(wtd.quantile(x=abc.lenormand$param, weights=abc.lenormand$weights*1000, probs=c(0.025,0.5,0.975))))
    colnames(x)<-c('Quantile 0.025','Mediane','Quantile 0.975')
    output$post.plot<-renderPlot({
      plot(c(input$min.prior,input$max.prior),dunif(x=c(input$min.prior,input$max.prior),min=input$min.prior,max=input$max.prior)
           ,type="l",lwd=2,lty=3,ylim=c(0,max(d[['y']])),main="Distribution",xlab="Nombre de femelles",ylab="Probabilite")
      lines(d,type="l",col=2,lwd=2)
      abline(v=x,col="blue",lwd=c(1,2,1),lty=2)
      legend(x="topleft",legend=c("a priori","a posteriori","Mediane","Quantiles 0.025 & 0.975"),col=c("black","red",rep("blue",3)),lwd=c(rep(2,3),1),lty=c(3,1,2,2))
    })
    output$abc.output<-renderTable({
      x
    })
  })

}

