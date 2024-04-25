require 'nokogiri'
require 'open-uri'
require 'json'
require 'fileutils'

url = 'https://napista.com.br/busca/carro-em-francisco-beltrao-_-pr/'

html = URI.open(url)
doc = Nokogiri::HTML(html)

#Search for the list ul, of cars on the page
data = doc.css('ul.sc-53e96303-0')

carsFile = 'cars.json'
carsList = []

#Clear old files
File.delete('cars.json') if File.exist?('cars.json')
FileUtils.rm_rf('imagens') if Dir.exist?('imagens')

Dir.mkdir('imagens') unless File.directory?('imagens')

data.search('li').each do |li|

  price = li.search('div.sc-b35e10ef-0.eOIsxb').text
  price = price.gsub(/[^\d,.-]/, '')
  price = price.to_f
  price = sprintf("%.3f", price)
  
  year = li.search('div.sc-b35e10ef-0.kGTXHH').text
  year = year[0..3]

  model = li.search('h2.sc-b35e10ef-0.hXsWso').text
  brand = model.split(' ')[0]

  image_url = li.search('img.sc-61fd7b2f-0.dDhDYm').attr('src')

  # Define o nome do arquivo da imagem
  filename = "#{model.gsub(/[\x00\/\\:\*\?\"<>\|]/, '')}"
  filename = "#{filename.strip.gsub(/\s+/, '_')}"
  filename = "#{filename.strip.gsub(/\./, '-')}.jpg"
  
  local_path = "imagens/#{filename}"

  File.open(local_path, 'wb') do |file|
    file.write URI.open(image_url).read
  end

  carsList << {
    modelo: model,
    marca: brand,
    valor: price,
    ano_fabricacao: '',
    ano_modelo: year,
    local_path: local_path
  }
end

File.open(carsFile, 'w') do |file|
  file.write(JSON.pretty_generate(carsList))
end
