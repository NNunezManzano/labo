# para correr el Google Cloud
#   8 vCPU
#  64 GB memoria RAM
# 256 GB espacio en disco

# son varios archivos, subirlos INTELIGENTEMENTE a Kaggle

#limpio la memoria
rm( list=ls() )  #remove all objects
gc()             #garbage collection

require("data.table")

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

#configuro work directory
setwd( "~/Documents/Facu/1-Maestria/DMEF" )

#cargo el dataset donde voy a entrenar
dataset  <- fread("./datasets/competencia2_2022.csv.gz")

#Aplico Feature Engineering
dataset[
  is.na(Visa_mconsumototal),
  Visa_mconsumototal:=0
  ]

dataset[
  is.na(Master_mconsumototal),
  Master_mconsumototal:=0
  ]

#Sumo toda la deuda
dataset[,nn_deuda_total :=  (
                              mprestamos_personales + 
                              mprestamos_prendarios + 
                              mprestamos_hipotecarios + 
                              mcomisiones_mantenimiento + 
                              Master_mconsumototal + 
                              Visa_mconsumototal
                             )]

#Agrego al calculo anterior el sabregiro de cuenta corriente
dataset[
  mcuenta_corriente < 0,
  nn_deuda_total:= (
    nn_deuda_total - mcuenta_corriente
    )
  ]

#Calculo el ingreso total
dataset[,
        nn_tpayroll := (
          mpayroll + mpayroll2
          )
        ]

#Saco ratio de endeudamiento
dataset[
  nn_tpayroll > 0, 
  nn_ratio_endudamiento := (
    nn_deuda_total/nn_tpayroll
    ) 
  ]

dataset[ , campo1 := as.integer( ctrx_quarter <14 & mcuentas_saldo < -1256.1 & cprestamos_personales <2 ) ]

dataset[ , campo2 := as.integer( ctrx_quarter <14 & mcuentas_saldo>= -1256.1 & mcaja_ahorro <2601.1 ) ]

dataset[ , campo3 := as.integer( ctrx_quarter>=14 & ( Visa_status>=8 | is.na(Visa_status) ) & ( Master_status>=8 | is.na(Master_status) ) ) ]

dataset[ , campo4 := as.integer( ctrx_quarter>=14 & Visa_status <8 & !is.na(Visa_status) & ctrx_quarter <38 ) ]

#--------------------------------------

#guardo el nuevo dataset
tb_nuevodt  <-  dataset 

fwrite( tb_nuevodt, 
        file= "fe_competencia2_2022.csv", 
        sep= "," )

#--------------------------------------


quit( save= "no" )
