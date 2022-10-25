# para correr el Google Cloud
#   8 vCPU
#  64 GB memoria RAM
# 256 GB espacio en disco

# son varios archivos, subirlos INTELIGENTEMENTE a Kaggle

# limpio la memoria
rm(list = ls()) # remove all objects
gc() # garbage collection

require("data.table")

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

# configuro work directory
setwd("~/Documents/Facu/1-Maestria/DMEF")

# cargo el dataset donde voy a entrenar
dataset <- fread("./datasets/fe_competencia2_2022.csv.gz")

rankear <- c(
  "cliente_edad",
  "cliente_antiguedad",
  "cproductos",
  "tcuentas",
  "ccuenta_corriente",
  "ccaja_ahorro",
  "cdescubierto_preacordado",
  "ctarjeta_debito",
  "ctarjeta_debito_transacciones",
  "ctarjeta_visa",
  "ctarjeta_visa_transacciones",
  "ctarjeta_master",
  "ctarjeta_master_transacciones",
  "cprestamos_personales",
  "cprestamos_prendarios",
  "cprestamos_hipotecarios",
  "cplazo_fijo",
  "cinversion1",
  "cinversion2",
  "cseguro_vida",
  "cseguro_auto",
  "cseguro_vivienda",
  "cseguro_accidentes_personales",
  "ccaja_seguridad",
  "cpayroll_trx",
  "cpayroll2_trx",
  "ccuenta_debitos_automaticos",
  "ctarjeta_visa_debitos_automaticos",
  "ctarjeta_master_debitos_automaticos",
  "cpagodeservicios",
  "cpagomiscuentas",
  "ccajeros_propios_descuentos",
  "ctarjeta_visa_descuentos",
  "ctarjeta_master_descuentos",
  "ccomisiones_mantenimiento",
  "ccomisiones_otras",
  "cforex",
  "cforex_buy",
  "cforex_sell",
  "ctransferencias_recibidas",
  "ctransferencias_emitidas",
  "cextraccion_autoservicio",
  "ccheques_depositados",
  "ccheques_emitidos",
  "ccheques_depositados_rechazados",
  "ccheques_emitidos_rechazados",
  "tcallcenter",
  "ccallcenter_transacciones",
  "thomebanking",
  "chomebanking_transacciones",
  "ccajas_transacciones",
  "ccajas_consultas",
  "ccajas_depositos",
  "ccajas_extracciones",
  "ccajas_otras",
  "catm_trx",
  "catm_trx_other",
  "ctrx_quarter",
  "tmobile_app",
  "cmobile_app_trx",
  "Master_delinquency",
  "Master_status",
  "Master_Fvencimiento",
  "Master_Finiciomora",
  "Master_fultimo_cierre",
  "Master_fechaalta",
  "Master_cconsumos",
  "Master_cadelantosefectivo",
  "Visa_delinquency",
  "Visa_status",
  "Visa_Fvencimiento",
  "Visa_Finiciomora",
  "Visa_fultimo_cierre",
  "Visa_fechaalta",
  "Visa_cconsumos",
  "Visa_cadelantosefectivo"
)


for (rank in rankear) {
  dataset[, (paste0("nn_r", rank, sep = "")) := frankv(dataset, cols = rank)]
  dataset[, paste0(rank) := NULL]
}




#--------------------------------------

# guardo el nuevo dataset
tb_nuevodt <- dataset

fwrite(tb_nuevodt,
  file = "rank_competencia2_2022.csv",
  sep = ","
)

#--------------------------------------


quit(save = "no")
