# para correr el Google Cloud
#   8 vCPU
#  64 GB memoria RAM
# 256 GB espacio en disco

# son varios archivos, subirlos INTELIGENTEMENTE a Kaggle

#limpio la memoria
rm( list=ls() )  #remove all objects
gc()             #garbage collection

require("data.table")
require("lightgbm")


#defino los parametros de la corrida, en una lista, la variable global  PARAM
#  muy pronto esto se leera desde un archivo formato .yaml
PARAM <- list()
PARAM$experimento  <- "KA7248"

PARAM$input$dataset       <- "./datasets/competencia2_2022.csv.gz"
PARAM$input$training      <- c( 202103 )
PARAM$input$future        <- c( 202105 )

PARAM$finalmodel$max_bin           <-     31
PARAM$finalmodel$learning_rate     <-     0.0350021585900007  #0.0142501265
PARAM$finalmodel$num_iterations    <-     114  #615
PARAM$finalmodel$num_leaves        <-     176  #784
PARAM$finalmodel$min_data_in_leaf  <-     1553  #5628
PARAM$finalmodel$feature_fraction  <-     0.449153115995839  #0.8382482539
PARAM$finalmodel$semilla           <-     104659

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#Aqui empieza el programa
setwd( "~/buckets/b1" )

#cargo el dataset donde voy a entrenar
dataset  <- fread(PARAM$input$dataset, stringsAsFactors= TRUE)


dataset[
  is.na(Visa_mconsumototal),
  Visa_mconsumototal:=0
  ]

dataset[
  is.na(Master_mconsumototal),
  Master_mconsumototal:=0
  ]

dataset[,nn_deuda_total :=  (
                              mprestamos_personales + 
                              mprestamos_prendarios + 
                              mprestamos_hipotecarios + 
                              mcomisiones_mantenimiento + 
                              Master_mconsumototal + 
                              Visa_mconsumototal
                             )]

dataset[
  mcuenta_corriente < 0,
  nn_deuda_total:= (
    nn_deuda_total - mcuenta_corriente
    )
  ]

dataset[,
        nn_tpayroll := (
          mpayroll + mpayroll2
          )
        ]

dataset[
  nn_tpayroll > 0, 
  nn_ratio_endudamiento := (
    nn_deuda_total/nn_tpayroll
    ) 
  ]

dataset[ , campo1 := as.integer( ctrx_quarter <14 & mcuentas_saldo < -1256.1 & cprestamos_personales <2 ) ]
#dataset[ , campo2 := as.integer( ctrx_quarter <14 & mcuentas_saldo < -1256.1 & cprestamos_personales>=2 ) ]

dataset[ , campo3 := as.integer( ctrx_quarter <14 & mcuentas_saldo>= -1256.1 & mcaja_ahorro <2601.1 ) ]
#dataset[ , campo4 := as.integer( ctrx_quarter <14 & mcuentas_saldo>= -1256.1 & mcaja_ahorro>=2601.1 ) ]

dataset[ , campo5 := as.integer( ctrx_quarter>=14 & ( Visa_status>=8 | is.na(Visa_status) ) & ( Master_status>=8 | is.na(Master_status) ) ) ]
#dataset[ , campo6 := as.integer( ctrx_quarter>=14 & ( Visa_status>=8 | is.na(Visa_status) ) & ( Master_status <8 & !is.na(Master_status) ) ) ]

dataset[ , campo7 := as.integer( ctrx_quarter>=14 & Visa_status <8 & !is.na(Visa_status) & ctrx_quarter <38 ) ]
#dataset[ , campo8 := as.integer( ctrx_quarter>=14 & Visa_status <8 & !is.na(Visa_status) & ctrx_quarter>=38 ) ]

#--------------------------------------

#paso la clase a binaria que tome valores {0,1}  enteros
#set trabaja con la clase  POS = { BAJA+1, BAJA+2 } 
#esta estrategia es MUY importante
dataset[ , clase01 := ifelse( clase_ternaria %in%  c("BAJA+2","BAJA+1"), 1L, 0L) ]

#--------------------------------------

#los campos que se van a utilizar
campos_buenos  <- setdiff( colnames(dataset), c("clase_ternaria","clase01") )

#--------------------------------------


#establezco donde entreno
dataset[ , train  := 0L ]
dataset[ foto_mes %in% PARAM$input$training, train  := 1L ]

#--------------------------------------
#creo las carpetas donde van los resultados
#creo la carpeta donde va el experimento
# HT  representa  Hiperparameter Tuning
dir.create( "./exp/",  showWarnings = FALSE ) 
dir.create( paste0("./exp/", PARAM$experimento, "/" ), showWarnings = FALSE )
setwd( paste0("./exp/", PARAM$experimento, "/" ) )   #Establezco el Working Directory DEL EXPERIMENTO



#dejo los datos en el formato que necesita LightGBM
dtrain  <- lgb.Dataset( data= data.matrix(  dataset[ train==1L, campos_buenos, with=FALSE]),
                        label= dataset[ train==1L, clase01] )

#genero el modelo
#estos hiperparametros  salieron de una laaarga Optmizacion Bayesiana
modelo  <- lgb.train( data= dtrain,
                      param= list( objective=          "binary",
                                   max_bin=            PARAM$finalmodel$max_bin,
                                   learning_rate=      PARAM$finalmodel$learning_rate,
                                   num_iterations=     PARAM$finalmodel$num_iterations,
                                   num_leaves=         PARAM$finalmodel$num_leaves,
                                   min_data_in_leaf=   PARAM$finalmodel$min_data_in_leaf,
                                   feature_fraction=   PARAM$finalmodel$feature_fraction,
                                   seed=               PARAM$finalmodel$semilla
                                  )
                    )

#--------------------------------------
#ahora imprimo la importancia de variables
tb_importancia  <-  as.data.table( lgb.importance(modelo) ) 
archivo_importancia  <- "impo.txt"

fwrite( tb_importancia, 
        file= archivo_importancia, 
        sep= "\t" )

#--------------------------------------


#aplico el modelo a los datos sin clase
dapply  <- dataset[ foto_mes== PARAM$input$future ]

#aplico el modelo a los datos nuevos
prediccion  <- predict( modelo, 
                        data.matrix( dapply[, campos_buenos, with=FALSE ])                                 )

#genero la tabla de entrega
tb_entrega  <-  dapply[ , list( numero_de_cliente, foto_mes ) ]
tb_entrega[  , prob := prediccion ]

#grabo las probabilidad del modelo
fwrite( tb_entrega,
        file= "prediccion.txt",
        sep= "\t" )

#ordeno por probabilidad descendente
setorder( tb_entrega, -prob )


#genero archivos con los  "envios" mejores
#deben subirse "inteligentemente" a Kaggle para no malgastar submits
cortes <- seq( 5000, 12000, by=500 )
cortes <- append(cortes, 8884)
for( envios  in  cortes )
{
  tb_entrega[  , Predicted := 0L ]
  tb_entrega[ 1:envios, Predicted := 1L ]

  fwrite( tb_entrega[ , list(numero_de_cliente, Predicted)], 
          file= paste0(  PARAM$experimento, "_", envios, ".csv" ),
          sep= "," )
}

#--------------------------------------

quit( save= "no" )
