library(tidyverse)

df <- readRDS("data/db_hex.rds")

colnames(df)

length(unique(df$fakultaet))

table(df$fakultaet)
unique(df$MINT_MN)

df_nonMINT <- df |> filter(MINT_MN==0 & MINT_T==0)
