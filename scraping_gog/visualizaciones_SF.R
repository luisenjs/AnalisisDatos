# install.packages("ggplot2")

library(ggplot2)
library(readr)

#Pregunta 1
juegos_con_descuento <- read_csv("D:/Escritorio/AnalisisDatos/scraping_gog/juegos_con_descuento.csv")
#View(juegos_con_descuento)
juego <- juegos_con_descuento$Nombre
descuentos <- juegos_con_descuento$Descuento

# Crea el gráfico con ggplot2
ggplot(juegos_con_descuento, aes(x = descuentos, y = juego)) +
  #geom_bar(stat = "identity", fill = "plum1", color = "black") +
  geom_segment(aes(x =0 , xend =descuentos, y = reorder(juego, descuentos), yend = reorder(juego, descuentos)),color = "plum1", lwd = 2)+
  geom_point(size = 7.5, colour=5) +
  
  geom_text(aes(label = paste0(Descuento, "%")), size=3) +
  labs(title = "20 videojuegos con mayor descuento del género de aventura",
       x = "Descuento (%)",
       y = "Juego") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#Pregunta 2

mejores_juegos <- read.csv("D:/Escritorio/AnalisisDatos/scraping_gog/mejores_juegos.csv")
juegos <- mejores_juegos$Juego
rating <- mejores_juegos$Rating
library(ggplot2)

ggplot(mejores_juegos, aes(x = juegos, y = rating, fill = juegos)) +
  geom_bar(stat = "identity")

#Pregunta 3

#install.packages("treemapify")
library(treemapify)
library(ggplot2)

genero_cantidad <- read.csv("D:/Escritorio/AnalisisDatos/scraping_gog/genero_cantidad.csv")
cantidad <- genero_cantidad$Cantidad
genero <- genero_cantidad$Genero
ggplot(genero_cantidad, aes(area = cantidad, fill = genero, label = cantidad)) +
  geom_treemap()+
  geom_treemap_text(colour = "white",place = "centre")





