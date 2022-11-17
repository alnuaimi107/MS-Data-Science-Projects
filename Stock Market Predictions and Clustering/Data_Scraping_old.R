#install.packages("pdfetch")
library(pdfetch)
# The following company is selected to do the analysis (the duration is 10 years)
# Apple : AAPL
# Microsoft : MSFT
# Alphabet (Google) : GOOG
# Amazon : AMZN
# Tesla : TSLA
install.packages('quantmod')
library("quantmod")
getSymbols("AAPL", src = "yahoo")   
Apple.S = pdfetch_YAHOO("AAPL", from = "2011-01-01", to = "2021-12-31")
Microsoft.S = pdfetch_YAHOO("MSFT", from = "2011-01-01", to = "2021-12-31")
Google.S = pdfetch_YAHOO("GOOG", from = "2011-01-01", to = "2021-12-31")
Amazon.S = pdfetch_YAHOO("AMZN", from = "2011-01-01", to = "2021-12-31")
Tesla.S = pdfetch_YAHOO("TSLA", from = "2011-01-01", to = "2021-12-31")
head(Tesla.S)
# Checking for NA in each table 
cbind(
  lapply(
    lapply(Apple.S, is.na)
    , sum)
)
cbind(
  lapply(
    lapply(Microsoft.S, is.na)
    , sum)
)
cbind(
  lapply(
    lapply(Google.S, is.na)
    , sum)
)
cbind(
  lapply(
    lapply(Amazon.S, is.na)
    , sum)
)
cbind(
  lapply(
    lapply(Tesla.S, is.na)
    , sum)
)

# For Data Analysis & clustering 
Apple.S = pdfetch_YAHOO("AAPL", from = "2011-01-01", to = "2021-12-31")
Microsoft.S = pdfetch_YAHOO("MSFT", from = "2011-01-01", to = "2021-12-31")
Google.S = pdfetch_YAHOO("GOOG", from = "2011-01-01", to = "2021-12-31")
Amazon.S = pdfetch_YAHOO("AMZN", from = "2011-01-01", to = "2021-12-31")
Tesla.S = pdfetch_YAHOO("TSLA", from = "2011-01-01", to = "2021-12-31")
BerkshireHathaway.S = pdfetch_YAHOO("BRK-A", from = "2011-01-01", to = "2021-12-31")
Mastercard.S = pdfetch_YAHOO("MA", from = "2011-01-01", to = "2021-12-31")
NVIDIA.S = pdfetch_YAHOO("NVDA", from = "2011-01-01", to = "2021-12-31")
UnitedHealthCare.S = pdfetch_YAHOO("UNH", from = "2011-01-01", to = "2021-12-31")
JJ.S = pdfetch_YAHOO("JNJ", from = "2011-01-01", to = "2021-12-31")
VISA.S = pdfetch_YAHOO("V", from = "2011-01-01", to = "2021-12-31")
Walmart.S = pdfetch_YAHOO("WMT", from = "2011-01-01", to = "2021-12-31")
JPMorgen.S = pdfetch_YAHOO("JPM", from = "2011-01-01", to = "2021-12-31")
P.and.G.S = pdfetch_YAHOO("PG", from = "2011-01-01", to = "2021-12-31")
ExxonMobil.S = pdfetch_YAHOO("UNH", from = "2011-01-01", to = "2021-12-31")

# The below table having the closing price for each of the above companies 
# in a duration of 10 years ( I removed Facebook since it has a lot of NAs , replace it with Mastercard)

Com.Table <- cbind(Apple.S$AAPL.close,Microsoft.S$MSFT.close,Google.S$GOOG.close,Amazon.S$AMZN.close,
                        Tesla.S$TSLA.close,BerkshireHathaway.S$`BRK-A.close`, Mastercard.S$MA.close, NVIDIA.S$NVDA.close,
                        UnitedHealthCare.S$UNH.close, JJ.S$JNJ.close, VISA.S$V.close, Walmart.S$WMT.close, JPMorgen.S$JPM.close,
                        P.and.G.S$PG.close, ExxonMobil.S$UNH.close)
Com.Table
