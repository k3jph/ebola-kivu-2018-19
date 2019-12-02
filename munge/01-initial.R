# Example preprocessing script.

ebola.2019 <- data.table(Data.DRC.Ebola.Outbreak..North.Kivu.and.Ituri.MOH.Total)

ebola.2019.cod <- ebola.2019[country == "COD"]
ebola.2019.cod[, week := ceiling_date(as_date(report_date), unit = "week")]
ebola.2019.cod[, newcases := as.numeric(as.character(ebola.2019.cod$total_cases_change))]

ebola.2019.cod.weekly <- ebola.2019.cod[, list(cases = sum(newcases, na.rm = TRUE)), by = week]
setorderv(ebola.2019.cod.weekly, c("week"), order = 1)

ebola.2019.cod.xts <- as.xts(ebola.2019.cod.weekly)
ebola.2019.cod.xts <- rollapply(ebola.2019.cod.xts, FUN = sum, width = 3, align = "right")

ebola.2019.cod.weekly <- data.table(ebola.2019.cod.xts)
