setwd("D:/RLearning/All-in-one")
install.packages("XML")
install.packages("RCurl")
install.packages("plyr")
install.packages("ggplot2")
install.packages("xtable")
install.packages("cowplot")
install.packages("httr")
library(xtable)
library(XML)
library(RCurl)
library(plyr)
library(ggplot2)
library(reshape2)
library(cowplot)
library(httr)
url <- "https://www.basketball-reference.com/leagues/NBA_2019_per_game.html"
# These produce the same results: url <- "https://stats.nba.com/leaders/"
urldata <-  getURL(url)
data <- readHTMLTable(urldata, stringsAsFactors = FALSE, encoding = "UTF-8")
dat <- structure(data, row.names = c(NA, -734), .Names = seq_along(data), class = "data.frame")
#This one does not work dat3 <- as.data.frame(data, col.names = names(data), headers = TRUE)

#This one works - But all variables are characters
stats18 <- ldply(data, data.frame)
# Adjusting variable names
colnames(stats18)[12] <- "FGpct"; colnames(stats18)[13] <- "3P"; colnames(stats18)[14] <- "3PA"; colnames(stats18)[15] <- "3Ppct"; colnames(stats18)[16] <- "2P"; colnames(stats18)[17] <- "2PA"; colnames(stats18)[18] <- "2Ppct"; colnames(stats18)[19] <- "eFG"; colnames(stats18)[22] <- "FTpct"

#Removing irrelevant variables, NAs, and converting to numeric
stats18$.id <- NULL
stats18$Rk <- NULL
#Removing Non English Characters from Traded Players
stats18[399:401,1] <- "Skal"; stats18[446:448,1] <- "Boban"; stats18[430:432,1] <- "Timothe"; stats18[484:486,1] <- "Nikola Mirotic"; stats18[599:601,1] <- "Dario"; stats18[680:682,1] <- "Jonas Valanciunas"; stats18[107,2] <- "SF"

##Numeric needs to ignore the character variables
stats18numeric <- as.data.frame(sapply(stats18[c(3,5:29)], as.numeric))
stats18numeric[is.na(stats18numeric)] <- 0

#Isolating all traded players that show up as double in the data set 
TOTplayer <- subset(stats18, Tm == "TOT")
#Cleaning traded duplicates and adding in traded players totals
statsTraded <- subset(stats18, Player %in% c("Ryan Anderson", "Trevor Ariza", "Ron Baker", "Harrison Barnes", "Avery Bradley", "Corey Brewer", "Reggie Bullock", "Trey Burke", "Alec Burks", "Jimmy Butler", "Isaiah Canaan", "Michael Carter-Williams", "Tyson Chandler", "Wilson Chandler", "Marquese Chriss", "Robert Covington", "Mitch Creek", "Sam Dekker", "Matthew Dellavedova", "Tyler Dorsey", "Henry Ellenson", "Wayne Ellington", "James Ennis", "Jawun Evans", "Kenneth Faried", "Tim Frazier", "Marc Gasol", "Pau Gasol", "JaMychal Green", "Tim Hardaway", "Tobias Harris", "Andrew Harrison", "George Hill", "Justin Holiday", "Rodney Hood", "Justin Jackson", "John Jenkins", "B.J. Johnson", "Stanley Johnson", "Tyler Johnson", "Wesley Johnson", "DeAndre Jordan","Enes Kanter", "Brandon Knight", "Kyle Korver", "Skal", "Courtney Lee", "Jeremy Lin", "Timothe", "Shelvin Mack", "Thon Maker", "Boban", "Wesley Matthews", "Patrick McCaw", "C.J. Miles", "Nikola Mirotic", "Greg Monroe", "Eric Moreland", "Markieff Morris", "Mike Muscala", "Sviatoslav Mykhailiuk", "James Nunnally", "Kelly Oubre", "Jabari Parker", "Cameron Payne", "Otto Porter", "Bobby Portis", "Austin Rivers", "Dario", "Mike Scott", "Wayne Selden", "Landry Shamet", "Iman Shumpert", "Jonathon Simmons", "Dennis Smith", "Jason Smith", "Ray Spalding", "Nik Stauskas", "Caleb Swanigan", "Garrett Temple", "Emanuel Terry", "Jonas Valanciunas", "Christian Wood", "Delon Wright", "Tyler Zeller", "Ivica Zubac"))
"%ni%" <- Negate("%in%")
statsnotTraded <- subset(stats18, Player %ni% c("Ryan Anderson", "Trevor Ariza", "Ron Baker", "Harrison Barnes", "Avery Bradley", "Corey Brewer", "Reggie Bullock", "Trey Burke", "Alec Burks", "Jimmy Butler", "Isaiah Canaan", "Michael Carter-Williams", "Tyson Chandler", "Wilson Chandler", "Marquese Chriss", "Robert Covington", "Mitch Creek", "Sam Dekker", "Matthew Dellavedova", "Tyler Dorsey", "Henry Ellenson", "Wayne Ellington", "James Ennis", "Jawun Evans", "Kenneth Faried", "Tim Frazier", "Marc Gasol", "Pau Gasol", "JaMychal Green", "Tim Hardaway", "Tobias Harris", "Andrew Harrison", "George Hill", "Justin Holiday", "Rodney Hood", "Justin Jackson", "John Jenkins", "B.J. Johnson", "Stanley Johnson", "Tyler Johnson", "Wesley Johnson", "DeAndre Jordan","Enes Kanter", "Brandon Knight", "Kyle Korver", "Skal", "Courtney Lee", "Jeremy Lin", "Timothe", "Shelvin Mack", "Thon Maker", "Boban", "Wesley Matthews", "Patrick McCaw", "C.J. Miles", "Nikola Mirotic", "Greg Monroe", "Eric Moreland", "Markieff Morris", "Mike Muscala", "Sviatoslav Mykhailiuk", "James Nunnally", "Kelly Oubre", "Jabari Parker", "Cameron Payne", "Otto Porter", "Bobby Portis", "Austin Rivers", "Dario", "Mike Scott", "Wayne Selden", "Landry Shamet", "Iman Shumpert", "Jonathon Simmons", "Dennis Smith", "Jason Smith", "Ray Spalding", "Nik Stauskas", "Caleb Swanigan", "Garrett Temple", "Emanuel Terry", "Jonas Valanciunas", "Christian Wood", "Delon Wright", "Tyler Zeller", "Ivica Zubac"))
statsbind <- rbind(statsnotTraded, TOTplayer)
#Eliminating the extraneous "player" headers from the HTML Table
statsbind2 <- subset(statsbind, Player %ni% c("Player"))
statsbindcharacters <- subset(statsbind, Player %ni% c("Player"))
#Proof that there are no duplicates
statsbindcharacters$Duplicates <- duplicated(statsbindcharacters$Player)
ifelse(statsbindcharacters$Duplicates == "TRUE",1,0)

#Calculating Z Scores
#
statsbind2 <- as.data.frame(sapply(statsbind2[c(3,5:29)], as.numeric))
statsbind2[is.na(statsbind2)] <- 0
statsbind2$PTSZ <- (statsbind2$PTS - mean(statsbind2$PTS))/sd(statsbind2$PTS)
statsbindScale <- scale(statsbind2[,1:27])
##Problem here is that they need identical rows so the orignal needs to be subset
statscbindScale <- cbind(statsbindcharacters[c(1,2,4)], statsbindScale)
statscbindScale$NegTOV <- statscbindScale$TOV * -1
statscbindScale$NegPF <- statscbindScale$PF * -1
##Creating the all-in-one value
statscbindScale[,33] <- rowSums(statscbindScale[c(11,14,17,18,23,24,25,26,29,31,32)])
statscbindScale$combined_Z <- statscbindScale[,33]/11
statscbindScale <- statscbindScale[with(statscbindScale,order(-combined_Z)),]

##Data vizualization section
#
##Top 20/Bottom 20 Diverging Bars Visualization
statscbindScale$abovebelow_Z <- ifelse(statscbindScale$combined_Z < 0, "below", "above")
top20bot20 <- ggplot(statscbindScale[c(1:20,511:530),], aes(x=reorder(Player,combined_Z), y=combined_Z, label="Combined Z Score")) + geom_bar(stat='identity', aes(fill=abovebelow_Z), width=.5) + scale_fill_manual(name= "Z Score", labels=c("Above 0", "Below 0"), values=c("above"="#FF2E00", "below"="#0078FF")) +labs(title ="Normalized Production for the 2018-19 NBA Season") + coord_flip() + xlab("Player") + ylab("Combined Z Score")
##Diverging Bars players with over 20 games played
statscbindScalegames <- subset(statscbindScale, G > -1.14)
top20bot20g <- ggplot(statscbindScalegames[c(1:20,404:423),], aes(x=reorder(Player,combined_Z), y=combined_Z, label="Combined Z Score")) + geom_bar(stat='identity', aes(fill=abovebelow_Z), width=.5) + scale_fill_manual(name="Z Score", labels=c("Above 0", "Below 0"), values=c("above"="#FF2E00", "below"="#0078FF")) +labs(title ="Normalized Production for the 2018-19 NBA Season", subtitle = "Players with over 20 games played") + coord_flip() + xlab("Player") + ylab("Combined Z Score")
#Top 25 Players by Normalized Position 
top25 <- ggplot(subset(statscbindScale[1:25,]), aes(x=reorder(Player,combined_Z), y=combined_Z, label="Combined Z Score")) + geom_bar(stat='identity', aes(fill=Pos), width=.5) + scale_fill_manual(name="Position", labels=c("Center", "Power Forward", "Point Guard", "Small Forward", "Shooting Guard"), values=c("PG"="#C49A00", "SG"="#00B6EB", "SF"="#FB61D7", "PF"="#53B400","C"="#F8766D")) +labs(title ="Top 25 Players by Normalized Production") + coord_flip() + xlab('Player') + ylab('Combined Z Score')
#Pie Chart and Frequency table
freqtable <- c(8/25, 1/25, 8/25, 6/25, 2/25)
freqmatrix <- matrix(freqtable, ncol=5, byrow = TRUE)
freqmatrix <- t(freqmatrix)
freqframe <- as.data.frame(freqmatrix)
freqframe[,2] <- c("Center", "Power Forward", "Point Guard", "Small Forward", "Shooting Guard")
names(freqframe)[1] <- "Prop"
names(freqframe)[2] <- "PlayerPosition"
piechart <- ggplot(freqframe, aes(x="", y= Prop, fill = factor(PlayerPosition))) + geom_bar(width = 1, stat = "identity") + theme(axis.line = element_blank(), plot.title = element_text(hjust = 0.5), axis.text.x = element_blank()) + labs(fill = "Position", x = NULL, y = NULL, title = "Proportion of Positions in the Top 25 Players") + coord_polar(theta = "y", start = 0) + geom_text(aes(label=Prop), position = position_stack(vjust = 0.5))
##Position totals bar charts -- not used
statscbindNoScale <- cbind(statsbindcharacters[c(1,2,4)], statsbind2)
posTOT <- tapply(statscbindNoScale$FG, statscbindNoScale$Pos, FUN = sum)
posagg <- aggregate(. ~ statscbindNoScale$Pos, statscbindNoScale[c(11, 14, 18, 23, 24, 25, 26, 27, 28, 29)], sum)
names(posagg)[1] <- "Pos"
posagg5 <- subset(posagg, TRB > 9)
names(posagg5)[2] <- "ThreeP"; names(posagg5)[3] <- "TwoP"
posagg5 = mutate(posagg5, ThreeP = ThreeP/sum(ThreeP), TwoP = TwoP/sum(TwoP), FT = FT/sum(FT), TRB = TRB/sum(TRB), AST = AST/sum(AST), STL = STL/sum(STL), BLK = BLK/sum(BLK), TOV = TOV/sum(TOV), PF = PF/sum(PF), PTS = PTS/sum(PTS))
posagglong <- melt(posagg5, id.vars = c("Pos"))
posagglong[,3] <- round(posagglong[,3], 2)
ggplot(posagglong, aes(fill = Pos, y = value, x = variable)) + geom_bar(position="fill", stat = "identity") + geom_text(aes(label = value), position = position_stack(vjust = 0.5), size = 4) + ylab("Percentage") + xlab("Box Score Variables")

##Defensive winners
statscbindNoScale$firstdefense <- ifelse(statscbindNoScale$Player == "Rudy Gobert" | statscbindNoScale$Player == "Paul George" | statscbindNoScale$Player == "Marcus Smart" | statscbindNoScale$Player == "Eric Bledsoe" | statscbindNoScale$Player == "Giannis Antetokounmpo", 1, 0)
statscbindNoScale$seconddefense <- ifelse(statscbindNoScale$Player == "Jrue Holiday" | statscbindNoScale$Player == "Klay Thompson" | statscbindNoScale$Player == "Joel Embiid" | statscbindNoScale$Player == "Draymond Green" | statscbindNoScale$Player == "Kawhi Leonard", 1, 0)
statscbindNoScale$alldefense <- ifelse(statscbindNoScale$firstdefense == 1 | statscbindNoScale$seconddefense == 1 , 1 , 0)

##Some stuff to spice up Part 1
urladv <- "https://www.basketball-reference.com/leagues/NBA_2019_advanced.html"
urladvdata <-  getURL(urladv)
dataadv <- readHTMLTable(urladvdata, stringsAsFactors = FALSE, encoding = "UTF-8")
datadv <- structure(dataadv, row.names =c(NA, -734), .Names = seq_along(dataadv), class = "data.frame")
advstats <- ldply(dataadv, data.frame)
advstats$.id <- NULL
advstats$Rk <- NULL
advstats[,c('PER', 'BPM', 'G')] <- sapply(advstats[,c('PER','BPM', 'G')], as.numeric)
advstats <- subset(advstats, G > 20)
advstats <- advstats[with(advstats,order(-PER)),]
advstats[1:20,]
advstatsHTML <- advstats[1:10,c('Player', 'PER', 'BPM')]
print(xtable(advstatsHTML, caption = "Top 10 Players Sorted by PER"), "html", include.rownames = FALSE, caption.placement = 'top', html.table.attributes = 'align="left"')