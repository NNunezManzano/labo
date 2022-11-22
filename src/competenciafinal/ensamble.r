# limpio la memoria
rm(list = ls()) # remove all objects
gc() # garbage collection

require("data.table")

# Parametros del script
PARAM <- list()
PARAM$experimentos <- c("1001", "1002", "1003", "1004")
PARAM$path <- "./exp/Semillerio/"

options(error = function() {
    traceback(20)
    options(error = NULL)
    stop("exiting after script error")
})

setwd("~/Documents/Facu/1-Maestria/DMEF")


ensamble <- function() {
    for (experimento in PARAM$experimentos)
    {
        dataset <- fread(paste0(PARAM$path, experimento, "/promedio_modelo", experimento, ".csv"))

        dataset_base <- dataset_base[, paste0("prob_", experimento) := dataset[, .(Predicted)]]
    }
}

dataset_base <- fread(paste0(PARAM$path, PARAM$experimentos[1], "/promedio_modelo", PARAM$experimentos[1], ".csv"))

dataset_base <- dataset_base[, .(numero_de_cliente)]

ensamble()


fwrite(dataset_base,
    file = paste0(PARAM$path, "/ensamble_modelos.csv"),
    sep = ","
)

fwrite(dataset_base[, .(Predicted = rowMeans(.SD)), by = numero_de_cliente],
    file = paste0(PARAM$path, "/promedio_modelos.csv"),
    sep = ","
)


dataset_pred <- dataset_base[, .(Predicted = rowMeans(.SD)), by = numero_de_cliente]


cortes <- seq(
    from = 9500,
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
        "/ensamble_prob_",
        sprintf("%05d", corte),
        ".csv"
    )

    fwrite(dataset_pred[, list(numero_de_cliente, Predicted)],
        file = nom_submit,
        sep = ","
    )
}
