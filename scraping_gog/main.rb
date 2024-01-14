require 'open-uri'
require 'nokogiri'
require 'csv'

require 'open-uri'
require 'nokogiri'
require 'csv'

gog = URI.open('https://www.gog.com/en/games/adventure')
datos = gog.read

parsed_content = Nokogiri::HTML(datos)
juegos = parsed_content.css('.ng-star-inserted .paginated-products-grid.grid')

# Crear un array para almacenar los juegos con sus datos
juegos_con_descuento = []

juegos.css('.ng-star-inserted').each do |juego|
  nombre = juego.css('.product-tile__info .product-tile__title.ng-star-inserted').inner_text.strip
  precioFinal = juego.css('.ng-star-inserted .final-value').inner_text.strip.gsub(/\$/, '')
  precioInicial = juego.css('.ng-star-inserted .base-value.ng-star-inserted').inner_text.strip.gsub(/\$/, '')

  # Verifica si los datos no están vacíos antes de almacenar en el array
  if nombre != '' && precioInicial != '' && precioFinal != ''
    juegos_con_descuento << { nombre: nombre, precioInicial: precioInicial.to_f, precioFinal: precioFinal.to_f }
  end
end

# Ordenar el array por el mayor descuento
juegos_con_descuento.sort_by! { |juego| (juego[:precioInicial] - juego[:precioFinal]) / juego[:precioInicial] }.reverse!

# Tomar solo los primeros 20 juegos
primeros_20_juegos = juegos_con_descuento.take(20)

# Abre un archivo CSV en modo de escritura
CSV.open('juegos_con_descuento.csv', 'w') do |csv|
  # Escribe las cabeceras
  csv << ['Nombre', 'Precio Inicial', 'Precio Final', 'Descuento']

  primeros_20_juegos.each do |juego|
    descuento = ((juego[:precioInicial] - juego[:precioFinal]) / juego[:precioInicial] * 100).round(2)
    # Escribe los datos en el archivo CSV
    csv << [juego[:nombre], juego[:precioInicial], juego[:precioFinal], descuento]
  end
end



#Pregunta2 :¿Cuáles son los 15 primeros juegos con los mejores ratings del género de estrategia que estén en idioma inglés? 



#Pregunta 3: ¿Cuál es la cantidad de videojuegos de los géneros de acción, aventura, deportes y estrategia? 