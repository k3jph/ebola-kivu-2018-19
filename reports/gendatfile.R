library("ProjectTemplate")
ProjectTemplate::reload.project(reset = TRUE)

datfile <- "ebola_estimation.dat"

ebola.2019.cod.weekly <- ebola.2019.cod.weekly[complete.cases(ebola.2019.cod.weekly)]
n <- nrow(ebola.2019.cod.weekly)

write_lines("# ebola_estimation.dat\n", datfile, append = FALSE)

numlist <- paste(1:n, collapse = " ")
setsi <- paste("set S_SI :=", numlist, ";")
write_lines(setsi, datfile, append = TRUE)

popparam <- "10000000"
write_lines(paste("param P_POP :=", popparam, ";"), datfile, append = TRUE)

write_lines("param P_REP_CASES default 0.0 :=", datfile, append = TRUE)
dattxt <- paste(" ", ebola.2019.cod.weekly[, .I], ebola.2019.cod.weekly[, cases])
for(i in dattxt)
    write_lines(i, datfile, append = TRUE)
write_lines(";", datfile, append = TRUE)

ebola.plot <- autoplot(ebola.2019.cod.xts) + ylab("Number of Infective Cases") + xlab("") + ylim(c(0, 400))
ggsave(filename = "ebola-i-cases-byweek.pdf", plot = ebola.plot, device = "pdf")

datfile <- "ebola_estimation26.dat"
n <- nrow(ebola.2019.cod.xts)
ebola.2019.R0 <- data.frame()

for(j in 28:n) {
    ebola.2019.cod.weekly.26 <- data.table(ebola.2019.cod.xts[(j - 25):j])
    numlist <- paste(1:26, collapse = " ")
    setsi <- paste("set S_SI :=", numlist, ";")
    write_lines(setsi, datfile, append = FALSE)
    write_lines(paste("param P_POP :=", popparam, ";"), datfile, append = TRUE)
    write_lines("param P_REP_CASES default 0.0 :=", datfile, append = TRUE)
    dattxt <- paste(" ", ebola.2019.cod.weekly.26[, .I], ebola.2019.cod.weekly.26[, cases])
    for(i in dattxt)
        write_lines(i, datfile, append = TRUE)
    write_lines(";", datfile, append = TRUE)

    date <- date(ebola.2019.cod.xts[j])
    R0 <- system("pyomo solve --solver=/Users/howarjp1/coin-or/dist/bin/ipopt --logging=quiet ebola26.py ebola_estimation26.dat", intern = TRUE)

    ebola.2019.R0 <- rbind(ebola.2019.R0, data.frame(weekend = weekend, R0 = as.numeric(R0)))
}

ebola.2019.R0 <- data.table(ebola.2019.R0)

ebola.2019.R0$date <- as.Date(ebola.2019.R0$date)
ebola.2019.R0.xts <- as.xts(ebola.2019.R0)

R0.plot <- autoplot(ebola.2019.R0.xts) + ylab("26-Week R0") + xlab("") + ylim(c(0, 20))
ggsave(filename = "ebola-R0-byweek.pdf", plot = R0.plot, device = "pdf")
