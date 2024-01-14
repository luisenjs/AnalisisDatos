require 'open-uri'
require 'nokogiri'
require 'csv'

#Pregunta 1: ¿Cuáles son los 20 videojuegos con mayor descuento del género de aventura? 

gogAventura = URI.open('https://www.gog.com/en/games/adventure')
datos = gogAventura.read

parsed_content = Nokogiri::HTML(datos)
juegosAventura = parsed_content.css('.ng-star-inserted .paginated-products-grid.grid')

juegos_con_descuento = []  # Array para almacenar los juegos con descuentos

juegosAventura.css('.ng-star-inserted').each do |aventura|
  nombre = aventura.css('.product-tile__info .product-tile__title.ng-star-inserted').inner_text.strip
  precioFinal = aventura.css('.ng-star-inserted .final-value').inner_text.strip.gsub(/\$/, '') #para eliminar el $
  precioInicial = aventura.css('.ng-star-inserted .base-value.ng-star-inserted').inner_text.strip.gsub(/\$/, '') #para eliminar el $

  # Verifica si los datos no están vacíos antes de almacenar en el array
  if nombre != '' && precioInicial != '' && precioFinal != ''
    juegos_con_descuento << { nombre: nombre, precioInicial: precioInicial.to_f, precioFinal: precioFinal.to_f }
  end
end

# Ordenar el array por el mayor descuento
juegos_con_descuento.sort_by! { |aventura| (aventura[:precioInicial] - aventura[:precioFinal]) / aventura[:precioInicial] }.reverse!

primeros_20_juegos = juegos_con_descuento.take(20) # Tomar solo los primeros 20 juegos

CSV.open('juegos_con_descuento.csv', 'w') do |csv|
  csv << ['Nombre', 'Precio Inicial', 'Precio Final', 'Descuento'] #cabeceras

  primeros_20_juegos.each do |aventura| #obtengo el descuento
    descuento = ((aventura[:precioInicial] - aventura[:precioFinal]) / aventura[:precioInicial] * 100).round(2)
    csv << [aventura[:nombre], aventura[:precioInicial], aventura[:precioFinal], descuento]
  end
end



#Pregunta2 :¿Cuáles son los 15 primeros juegos con los mejores ratings del género de estrategia que estén en idioma inglés? 



# Pregunta 3: ¿Cuál es la cantidad de videojuegos de los géneros de action, adventure, shooting, indie, strategy?

generos = ['action', 'adventure', 'shooting', 'indie', 'strategy']

# Array para almacenar los resultados antes de escribirlos en el CSV
resultados = []

generos.each do |genero|
  linkGeneros = "https://www.gog.com/en/games/#{genero.downcase}"
  gogGeneros = URI.open(linkGeneros)
  datosGeneros = gogGeneros.read

  # Array para guardar los juegos de la pagina para luego contarlos
  juegosPagina1 = []
  
  parsed_content = Nokogiri::HTML(datosGeneros)
  juegos = parsed_content.css('.ng-star-inserted .paginated-products-grid.grid')
  juegos.css('.ng-star-inserted').each do |juego|
    nombre = juego.css('.product-tile__info .product-tile__title.ng-star-inserted').inner_text.strip
  
    if nombre != ''
      juegosPagina1 << { nombre: nombre }
    end
  end

  numJuegosPag1 = juegosPagina1.length
  puts "Número de juegos en la página 1 para #{genero}: #{numJuegosPag1}"

  #map para extraer y convertir los números de página directamente en un arreglo de enteros
  numerosPaginasTotales = parsed_content.css('.catalog__display-wrapper.catalog__grid-wrapper .catalog__navigation .small-pagination__item').map(&:text).map(&:to_i)
  numPaginasTotales = numerosPaginasTotales.max
  puts "Número total de páginas para #{genero}: #{numPaginasTotales}"

  resultado = numJuegosPag1 * numPaginasTotales
  puts "Resultado para #{genero}: #{resultado}"

  # Agrega el resultado al array de resultados
  resultados << { genero: genero, cantidad: resultado }
  puts "----------------------------------------"
end

CSV.open('genero_cantidad.csv', 'w', write_headers: true, headers: ['Genero', 'Cantidad']) do |csv|
  resultados.each do |resultado|
    csv << [resultado[:genero], resultado[:cantidad]]
  end
end