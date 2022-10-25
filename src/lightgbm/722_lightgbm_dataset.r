# Generacion de Datasets

# limpio la memoria
rm(list = ls()) # remove all objects
gc() # garbage collection

require("data.table")

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

# configuro work directory
setwd("~/Documents/Facu/1-Maestria/DMEF")

# cargo el dataset con el feature engineering de la primera compotencia (arma secreta + total deuda + total payroll + ratio endeudamiento)
dataset <- fread("./datasets/fe_competencia2_2022.csv.gz")

# Elimino los campos payroll ya que los tengo en la nueva variable total payroll

dataset[, mpayroll := NULL]
dataset[, mpayroll2 := NULL]


# arranco rankeando las variables que solo tiene valores positivos y encontré data drifting en el PDF generado por el ../drifting/613_graficar_densidades.r

# genero una lista con todos los campos a reankear
rankear <- c(
  "ccajas_consultas",
  "ccajas_transacciones",
  "mpasivos_margen",
  "nn_deuda_total",
  "mcomisiones",
  "mprestamos_personales",
  "mcomisiones_mantenimiento",
  "mcomisiones_otras",
  "ccajas_otras",
  "ccomisiones_mantenimiento",
  "mrentabilidad_annual",
  "mcaja_ahorro",
  "mtarjeta_visa_consumo",
  "ccomisiones_otras",
  "mcuentas_saldo",
  "Visa_mpagominimo",
  "Visa_mconsumototal",
  "Visa_msaldototal",
  "Visa_msaldopesos",
  "mcuenta_corriente",
  "ccajas_depositos",
  "mttarjeta_visa_debitos_automaticos",
  "Master_Fvencimiento",
  "mextraccion_autoservicio",
  "Master_mpagominimo",
  "Master_mconsumototal",
  "ccallcenter_transacciones",
  "mtransferencias_emitidas",
  "Visa_mpagosdolares",
  "matm_other",
  "matm",
  "mcaja_ahorro_dolares",
  "mcheques_depositados",
  "ctransferencias_emitidas",
  "cpagomiscuentas",
  "ccheques_depositados",
  "Visa_mconsumospesos",
  "catm_trx_other",
  "catm_trx",
  "mcheques_depositados_rechazados",
  "mtransferencias_recibidas",
  "mpagomiscuentas",
  "Visa_delinquency",
  "ccheques_emitidos",
  "mcaja_ahorro_adicional",
  "ctarjeta_debito_transacciones",
  "ctarjeta_master_transacciones",
  "mtarjeta_master_consumo",
  "cprestamos_prendarios",
  "mprestamos_prendarios",
  "cprestamos_hipotecarios",
  "mprestamos_hipotecarios",
  "cplazo_fijo",
  "cpayroll2_trx",
  "ccuenta_debitos_automaticos",
  "mcuenta_debitos_automaticos",
  "mttarjeta_master_debitos_automaticos",
  "cpagodeservicios",
  "mpagodeservicios",
  "ccajeros_propios_descuentos",
  "mcajeros_propios_descuentos",
  "ctarjeta_visa_descuentos",
  "ctarjeta_master_descuentos",
  "cforex_buy",
  "mforex_buy",
  "cforex_sell",
  "mforex_sell",
  "ctransferencias_recibidas",
  "mcheques_emitidos",
  "ccheques_depositados_rechazados",
  "mcheques_emitidos_rechazados",
  "tcallcenter",
  "chomebanking_transacciones",
  "Master_delinquency",
  "Master_mfinanciacion_limite",
  "Master_Finiciomora",
  "Master_msaldototal",
  "Master_msaldopesos",
  "Master_msaldodolares",
  "Master_mconsumospesos",
  "Master_mconsumosdolares",
  "Master_mlimitecompra",
  "Master_fultimo_cierre",
  "Master_mpagado",
  "Master_mpagospesos",
  "Master_cconsumos",
  "Master_cadelantosefectivo",
  "Visa_mfinanciacion_limite",
  "Visa_Finiciomora",
  "Visa_msaldodolares",
  "Visa_mconsumosdolares",
  "Visa_mlimitecompra",
  "Visa_madelantopesos",
  "Visa_madelantodolares",
  "Visa_fultimo_cierre",
  "Visa_mpagado",
  "Visa_mpagospesos",
  "Visa_cadelantosefectivo"
)

# Antes de rankear creo una lista vacia donde van a agregarse los campos con valores negativos
negativos <- c()
otros <- c()

for (campo in rankear) {
  # verifico que el campo sea de valores positivos
  tryCatch(
    {
      if (min(dataset[, get(campo)]) >= 0) {
        dataset[, paste0("auto_r_", campo, sep = "") := (frankv(dataset, cols = campo) - 1) / (length(dataset[, get(campo)]) - 1)] # ranke entre 0 y 1
        dataset[, paste0(campo) := NULL] # elimino la variable original
      } else {
        negativos <- c(negativos, campo)
      }
    },
    # por si algun campo no tiene valor minimo o hay un typo en la lista
    error = function(e) {
      otros <- c(otros, campo)
    }
  )
}

# ahora separo las variables que tienen rangos negativos y positivos
rankear_pend <- c()
negativos_solo <- c()

for (campo in negativos) {
  # verifico que el campo sea de valores positivos y negativos
  if (dataset[get(campo) < 0, .N] > 0) {
    dataset[, paste0(campo, "_neg") := ifelse(get(campo) < 0, get(campo), 0)]
    dataset[, paste0(campo, "_pos") := ifelse(get(campo) > 0, get(campo), 0)]
    dataset[, paste0(campo) := NULL] # elimino la variable original

    rankear_pend <- c(rankear_pend, paste0(campo, "_neg"), paste0(campo, "_pos")) # agrego a la lista para rankearlos en el siguiente paso # nolint
  } else {
    negativos_solo <- c(negativos_solo, campo)
  }
}

# rankeo las variables que separe en el paso anterior

for (campo in rankear_pend) {
  dataset[, paste0("auto_r_", campo, sep = "") := (frankv(dataset, cols = campo) - 1) / (length(dataset[, get(campo)]) - 1)] # ranke entre 0 y 1
  dataset[, paste0(campo) := NULL] # elimino la variable original
}

# verifico que no haya quedado nada en negativos_solo
if (length(negativos_solo) == 0) {

  # guardo el nuevo dataset
  fwrite(dataset,
    file = "rdd_competencia2_2022.csv",
    sep = ","
  )
}
#--------------------------------------


quit(save = "no")
