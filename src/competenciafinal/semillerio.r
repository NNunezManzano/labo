# limpio la memoria
rm(list = ls()) # remove all objects
gc() # garbage collection

require("data.table")

# Parametros del script
PARAM <- list()
PARAM$experimento <- "1002"
PARAM$path <- "./exp/Semillerio/"
PARAM$cantidad_semillas <- 10

options(error = function() {
    traceback(20)
    options(error = NULL)
    stop("exiting after script error")
})

setwd("~/Documents/Facu/1-Maestria/DMEF")


semillerio <- function(semillas) {
    for (i in 1:PARAM$cantidad_semillas)
    {
        semilla <- semillas[i]

        dataset <- fread(paste0(PARAM$path, PARAM$experimento, "/exp_ZZ", PARAM$experimento, "_ZZ", PARAM$experimento, "_", semilla, "_resultados.csv"))

        dataset_base <- dataset_base[, paste0("prob", semilla) := dataset[, .(prob)]]
    }
}

semillas <- fread(paste0(PARAM$path, PARAM$experimento, "/exp_ZZ", PARAM$experimento, "_ksemillas.csv"))

dataset_base <- fread(paste0(PARAM$path, PARAM$experimento, "/exp_ZZ", PARAM$experimento, "_ZZ", PARAM$experimento, "_", semillas[1], "_resultados.csv"))

dataset_base <- dataset_base[, .(numero_de_cliente)]

semillerio(semillas)


fwrite(dataset_base,
    file = paste0(PARAM$path, PARAM$experimento, "/semillerio_modelo", PARAM$experimento, ".csv"),
    sep = ","
)

fwrite(dataset_base[, .(Predicted = rowMeans(.SD)), by = numero_de_cliente],
    file = paste0(PARAM$path, PARAM$experimento, "/promedio_modelo", PARAM$experimento, ".csv"),
    sep = ","
)


dataset_pred <- dataset_base[, .(Predicted = rowMeans(.SD)), by = numero_de_cliente]


cortes <- seq(
    from = 10000,
    to = 14000,
    by = 500
)


setorder(dataset_pred, -Predicted)

for (corte in cortes)
{
    dataset_pred[, Predicted := 0L]
    dataset_pred[1:corte, Predicted := 1L]

    nom_submit <- paste0(
        PARAM$path,
        PARAM$experimento,
        "/modelo_",
        PARAM$experimento,
        "_",
        sprintf("%05d", corte),
        ".csv"
    )

    fwrite(dataset_pred[, list(numero_de_cliente, Predicted)],
        file = nom_submit,
        sep = ","
    )
}
