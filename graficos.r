#install.packages("dplyr")
#install.packages("plotly")
#install.packages("ggplot")
#install.packages("ggplot2")
#install.packages("knitr")
#install.packages("MASS")
#install.packages("tidyr")
#install.packages("kableExtra")

library(dplyr)
library(ggplot2)
library(knitr)
library(plotly)
library(kableExtra)
library(MASS)
library(tidyr)

#----------------------------------------------------------------------------------------
#------------------------- LOGROS DE UN JUEGO -------------------------------------------
#----------------------------------------------------------------------------------------

juego <- readline("Ingrese un juego para ver sus logros: ")
nombre_archivo <- paste0(juego, ".csv")
datos <- read.csv(nombre_archivo)

# Eliminar el símbolo "%" y convertir la columna Porcentaje a numérica
datos$Porcentaje <- as.numeric(sub("%", "", datos$Porcentaje))

# Crear intervalos y agregar una nueva columna intervalo
datos <- datos %>%
  mutate(intervalo = cut(Porcentaje, breaks = c(0, 10, 20, 40, 60, 90, 100),
                         labels = c("0-10%", "10-20%", "20-40%", "40-60%", "60-90%", "90-100%")))

# Crear un gráfico de barras agrupado por intervalo de porcentaje
ggplot(datos, aes(x = intervalo, fill = intervalo)) +
  geom_bar() +
  theme_minimal() +
  labs(title = "Cantidad de logros por porcentaje de usuarios que lo han obtenido", 
       x = "Pocentaje de usuarios", y = "Número de Logros")

#----------------------------------------------------------------------------------------
#-------------------- TABLA DE INFORMACION DE LOS JUEGOS --------------------------------
#----------------------------------------------------------------------------------------

datos2 <- read.csv("InfoJuegos.csv")

kable(datos2, format = "html") %>%
  kable_styling(
    full_width = FALSE,
    bootstrap_options = c("striped", "hover", "condensed", "responsive"),
    font_size = 15,
    latex_options = c("scale_down")
  ) %>%
  column_spec(1, bold = TRUE, color = "black", background = "lightblue")

#----------------------------------------------------------------------------------------
#----------------------- COMPARACION DE JUEGOS ------------------------------------------
#----------------------------------------------------------------------------------------


# Cargar los datos
datos3 <- read.csv("comparacion.csv")

# Divide la columna y cuenta los elementos
datos_expandidos <- datos3 %>%
  separate_rows(Plataformas, sep = "\\|") %>%
  group_by(Nombre) %>%
  summarize(NumPlataformas = n_distinct(Plataformas), Precio = first(Precio))

# Extraer la parte numérica del precio y convertir a numérico
datos_expandidos$Precio <- as.numeric(gsub("\\$| USD", "", datos_expandidos$Precio))

# Muestra el resultado con el nombre del juego en la leyenda
parcoord(datos_expandidos[, c("NumPlataformas", "Precio")], col = 2:7, lty = 1)

# Crear una leyenda con el nombre del juego
legend("topright", legend = datos_expandidos$Nombre, col = 2:7, lty = 1, bty = "n")

View(datos_expandidos)
