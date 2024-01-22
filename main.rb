require 'open-uri'
require 'nokogiri'
require 'csv'

class URLResolver
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def resolver()
    html = URI.open(url, { read_timeout: 60 }).read
    doc = Nokogiri::HTML(html)
    return doc
  end

  def saveData(archivo, data, mode)
    CSV.open(archivo, mode) do |csv|
      csv << data
    end
  end

  def header(archivo, top_line)
    CSV.open(archivo, 'w') do |csv|
      csv << top_line
    end
  end

  def clear(archivo)
    CSV.open(archivo, 'w') do |csv|
    end
  end
end

class GameAchivements
  attr_reader :url, :nombreJuego

  def initialize(url, nombreJuego)
    @url = url
    @nombreJuego = nombreJuego
  end

  def calcularLogros()
    rawLogros = URLResolver.new(url)
    archivo_juego = nombreJuego + ".csv"
    rawLogros.clear(archivo_juego)
    rawLogros.header(archivo_juego, ["Logros", "Descripcion", "Porcentaje"])
    doc = rawLogros.resolver()
    logros = doc.css("div#mainContents")
    logros.css("div.achieveRow").each do |logro|
      datos = []
      datos << logro.at(".achieveTxt h3").text.strip
      unless logro.at(".achieveTxt h5").text == ""
        datos << logro.at(".achieveTxt h5").text.strip
      else
        datos << "No Description"
      end
      datos << logro.css("div.achievePercent").text.strip
      rawLogros.saveData(nombreJuego + ".csv", datos, "a")
    end
  end
  
end

juegos_dicc = {}

doc = URLResolver.new("https://store.steampowered.com/search/?supportedlang=spanish&tags=21&filter=topsellers&ndl=1").resolver()
games = doc.css('div#search_resultsRows')
games.css("a").each do |game|
  juego = game.css("span.title").text.gsub("®", "")
  id_juego = game.attr("data-ds-appid")
  link_logros = "https://steamcommunity.com/stats/" + id_juego + "/achievements"
  link_juego = game.attr("href")
  juegos_dicc[juego.downcase] = {"logros" => link_logros, "link" => link_juego}
end

puts "Bienvenido a Steam Search"
puts "Ingrese el nombre del juego que desea buscar"
juego = gets.chomp.downcase
if juegos_dicc.key?(juego)
  datosInfo = []
  rawData = URLResolver.new(juegos_dicc[juego]["link"])
  docjuego = rawData.resolver()
  detalles = docjuego.css("div.block_content_inner")
  unless detalles.empty?
    datosInfo << docjuego.at("b").next.text.strip
    generos = []
    detalles.css("span a").each do |genero|
      generos << genero.text
    end
    datosInfo << generos.join("|")
    datosInfo << detalles.at("b:contains('Developer:') + a").text.strip
    unless detalles.at("b:contains('Publisher:') + a").nil?
      datosInfo << detalles.at("b:contains('Publisher:') + a").text.strip
    else
      datosInfo << "No info"
    end
    unless detalles.at("b:contains('Franchise:') + a").nil?
      datosInfo << detalles.at("b:contains('Franchise:') + a").text.strip
    else
      datosInfo << "No info"
    end
    datosInfo << detalles.at("b:contains('Date:')").next.text.strip
    rawData.saveData("InfoJuegos.csv", datosInfo, "a")
    logros = GameAchivements.new(juegos_dicc[juego]["logros"], juego)
    logros.calcularLogros()
  else
    puts "Página restringida"
  end
else
  puts "No se encontro el juego #{juego}"
end
