require 'open-uri'
require 'nokogiri'
require 'csv'

class Juego
  attr_accessor :nombre, :precio_inicial, :precio_final, :rating

  def initialize(nombre, precio_inicial, precio_final, rating)
    @nombre = nombre
    @precio_inicial = precio_inicial
    @precio_final = precio_final
    @rating = rating
  end

  def descuento
    ((@precio_inicial - @precio_final) / @precio_inicial * 100).round(2)
  end
end


class Scraper
  def initialize(url)
    @url = url
  end

  def obtener_datos
    datos = URI.open(@url).read
    Nokogiri::HTML(datos)
  end

  def obtener_juegos(parsed_content)
    parsed_content.css('.ng-star-inserted .paginated-products-grid.grid .ng-star-inserted')
  end
end


# Pregunta 1: ¿Cuáles son los 20 videojuegos con mayor descuento del género de aventura?
class AnalizadorDescuentos
  def initialize(juegos)
    @juegos = juegos
  end

  def obtener_primeros_20_descuentos
    juegos_con_descuento = []

    @juegos.each do |aventura|
      nombre = aventura.css('.product-tile__info .product-tile__title').inner_text.strip
      precio_final = aventura.css('.ng-star-inserted .final-value').inner_text.strip.gsub(/\$/, '').to_f
      precio_inicial = aventura.css('.ng-star-inserted .base-value.ng-star-inserted').inner_text.strip.gsub(/\$/, '').to_f
      nombre = nombre.sub(/^DLC\n \n/, '')

      if nombre != '' && precio_inicial != '' && precio_final != ''
        juego = Juego.new(nombre, precio_inicial, precio_final, nil)
        juegos_con_descuento << juego
      end
    end

    juegos_con_descuento.sort_by! { |juego| juego.descuento }.reverse!.take(20)
  end
end


url_aventura = 'https://www.gog.com/en/games/adventure'
scraper_aventura = Scraper.new(url_aventura)
parsed_content_aventura = scraper_aventura.obtener_datos
juegos_aventura = scraper_aventura.obtener_juegos(parsed_content_aventura)

analizador_descuentos = AnalizadorDescuentos.new(juegos_aventura)
primeros_20_juegos_descuento = analizador_descuentos.obtener_primeros_20_descuentos

CSV.open('juegos_con_descuento.csv', 'w', write_headers: true, headers: ['Nombre', 'Precio Inicial', 'Precio Final', 'Descuento']) do |csv|
  primeros_20_juegos_descuento.each do |juego|
    csv << [juego.nombre, juego.precio_inicial, juego.precio_final, juego.descuento]
  end
end


# Pregunta 2: ¿Cuáles son los 15 primeros juegos con los mejores ratings del género de estrategia que estén en idioma inglés?
class AnalizadorRatings
  def initialize(juegos)
    @juegos = juegos
  end

  def obtener_mejores_15_ratings
    juegos_con_rating = []

    @juegos.each do |estrategia|
      nombre = estrategia.css('.product-tile__info .product-tile__title.ng-star-inserted').inner_text.strip

      if nombre != ''
        nombre_formateado = nombre.downcase.gsub(/[^a-z0-9]+/, '_') # Reemplazar espacios y dos puntos por guiones bajos
        url_juego = "https://www.gog.com/en/game/#{nombre_formateado}" # URL para cada juego

        gog_juego = URI.open(url_juego)
        datos_juego = gog_juego.read

        parsed_juego = Nokogiri::HTML(datos_juego)
        rating_text = parsed_juego.css('.rating').inner_text.strip
        rating = rating_text.match(/\d+\.\d+/) ? rating_text.to_f : 0.0

        # Guardar el nombre, precios con null y rating en un hash
        juego = Juego.new(nombre, nil, nil, rating)
        juegos_con_rating << juego
      end
    end

    juegos_con_rating.sort_by! { |juego| -juego.rating }.take(15)
  end
end

url_estrategia = 'https://www.gog.com/en/games/strategy'
scraper_estrategia = Scraper.new(url_estrategia)
parsed_content_estrategia = scraper_estrategia.obtener_datos
juegos_estrategia = scraper_estrategia.obtener_juegos(parsed_content_estrategia)

analizador_ratings = AnalizadorRatings.new(juegos_estrategia)
mejores_15_juegos_ratings = analizador_ratings.obtener_mejores_15_ratings

CSV.open('mejores_juegos.csv', 'w', write_headers: true, headers: ['Juego', 'Rating']) do |csv|
  mejores_15_juegos_ratings.each do |juego|
    csv << [juego.nombre, juego.rating]
  end
end


# Pregunta 3: ¿Cuál es la cantidad de videojuegos de los géneros de action, adventure, shooting, indie, strategy?

class AnalizadorCantidadJuegos
  def initialize(genero)
    @genero = genero
  end

  def obtener_cantidad_juegos
    link_genero = "https://www.gog.com/en/games/#{@genero.downcase}"
    gog_genero = URI.open(link_genero)
    datos_genero = gog_genero.read

    juegos_pagina1 = []

    parsed_content = Nokogiri::HTML(datos_genero)
    juegos = parsed_content.css('.ng-star-inserted .paginated-products-grid.grid')
    juegos.css('.ng-star-inserted').each do |juego|
      nombre = juego.css('.product-tile__info .product-tile__title.ng-star-inserted').inner_text.strip

      if nombre != ''
        juegos_pagina1 << { nombre: nombre }
      end
    end

    num_juegos_pag1 = juegos_pagina1.length

    # Map para extraer y convertir los números de página directamente en un arreglo de enteros
    numeros_paginas_totales = parsed_content.css('.catalog__display-wrapper.catalog__grid-wrapper .catalog__navigation .small-pagination__item').map(&:text).map(&:to_i)
    num_paginas_totales = numeros_paginas_totales.max

    resultado = num_juegos_pag1 * num_paginas_totales
    { genero: @genero, cantidad: resultado }
  end
end

generos = ['action', 'adventure', 'shooting', 'indie', 'strategy']
resultados_cantidad = []
generos.each do |genero|
  analizador_cantidad = AnalizadorCantidadJuegos.new(genero)
  cantidad_resultado = analizador_cantidad.obtener_cantidad_juegos
  resultados_cantidad << cantidad_resultado
end

CSV.open('genero_cantidad.csv', 'w', write_headers: true, headers: ['Genero', 'Cantidad']) do |csv|
  resultados_cantidad.each do |resultado|
    csv << [resultado[:genero], resultado[:cantidad]]
  end
end

puts 'Los resultados se han guardado en "juegos_con_descuento.csv", "mejores_juegos.csv" y "genero_cantidad.csv"'
