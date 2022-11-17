#install.packages("tidyquant")
library(tidyquant)

from_date <- "2011-01-01"
to_date <- "2021-12-31"
Amazon <- getSymbols("AMZN", from = from_date, to = to_date, arnings = FALSE,auto.assign = TRUE)
df_stocks <- cbind(AAPL$AAPL.Close,AMZN$AMZN.Close,`BRK-A`$`BRK-A.Close`, GOOG$GOOG.Close, HMC$HMC.Close,JNJ$JNJ.Close
, JPM$JPM.Close ,MSFT$MSFT.Close, NVDA$NVDA.Close, PG$PG.Close,TSLA$TSLA.Close , TTM$TTM.Close,
UNH$UNH.Close , V$V.Close , WIP$WIP.Close , WMT$WMT.Close )
colnames(df_stocks) <- c( 'Apple' ,  'Amazon.com' ,  'BerkshireHathaway' ,'Google' ,  'Honda_Motor_Co' , 	
'Johnson_Johnson' , 'JPMorgan_Chase_Co.' , 'Microsoft_Corporation' , 'NVIDIA_Corporation',
'The_Procter_Gamble_Company' , 'Tesla' , 'Tata_Motors_Limited' , 'UnitedHealth_Group' , 'Visa' , 
  'Wipro_Limited' , 'Walmart')

head(df_stocks)
tail(df_stocks)


df_stocks_D <- data.frame(df_stocks)
df_stocks_N <- cbind(Time = rownames(df_stocks_D), df_stocks_D)

rownames(df_stocks_N) <- 1:nrow(df_stocks_D)

head(df_stocks_N)
tail(df_stocks_N)


# forecast dates for 6 weeks (Change this according to the time)

df_stocks_N
write.csv(df_stocks_N, "/Users/abdullatifalnuaimi/Desktop/Spring 2022/STAT 656/Project/Final_ShinyApp/data.csv", row.names=FALSE)
