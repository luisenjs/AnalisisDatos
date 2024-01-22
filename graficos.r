#install.packages("dplyr")
#install.packages("ggplot")
#install.packages("ggplot2")

library(dplyr)
library(ggplot2)

datos <- datos <- read.csv("raft.csv")

# Eliminar el símbolo "%" y convertir la columna Porcentaje a numérica
datos$Porcentaje <- as.numeric(sub("%", "", datos$Porcentaje))

# Crear intervalos y agregar una nueva columna intervalo
datos <- datos %>%
  mutate(intervalo = cut(Porcentaje, breaks = c(0, 10, 25, 40, 60, 90, 100),
                         labels = c("0-10%", "10-25%", "25-40%", "40-60%", "60-90%", "90-100%")))

# Crear un gráfico de barras agrupado por intervalo de porcentaje
ggplot(datos, aes(x = intervalo, fill = intervalo)) +
  geom_bar() +
  theme_minimal() +
  labs(title = "Cantidad de logros por porcentaje de usuarios que lo han obtenido", 
       x = "Pocentaje de usuarios", y = "Número de Logros")





