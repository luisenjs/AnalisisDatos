# install.packages("ggplot2")

library(ggplot2)
library(readr)

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






#FUNCIONA
# Crea el gráfico con ggplot2
ggplot(juegos_con_descuento, aes(x = Descuento, y = Nombre)) +
  geom_bar(stat = "identity", fill = "plum1", color = "black") +
  #geom_segment(aes(x = 0, xend = Descuento, y = 0, yend = 19),color = "gray", lwd = 1)
  geom_text(aes(label = paste0(Descuento, "%")), vjust = -0.5) +
  labs(title = "20 videojuegos con mayor descuento del género de aventura",
       x = "Descuento (%)",
       y = "Juego") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))