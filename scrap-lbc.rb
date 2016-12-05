require 'open-uri'
require 'nokogiri'
#sauvegarde des données
require 'json'
require 'byebug'

$base_url         = "https://www.leboncoin.fr/informatique/"
$result_file_name = "search_results.json"
#tableau des différentes annonces
annonces = ["1052391354", "1054523971", "1042370055"]

def create_url_for_id(id)
  $base_url + id + ".htm"
end

#id_test = "1052391354"

def get_lbc_information(id)
  stream = open(create_url_for_id(id))
  html   = Nokogiri::HTML(stream.read)

  title  = html.search(".adview_header").text.strip
  price  = html.search(".item_price span:nth-child(3)").text.strip
  #hash contenant les informations
  {"title" => title, "price" => price, "id" => id}
end

def load_previous_results
  JSON.parse(open($result_file_name).read)
end

#on compare les résultats avec un nouvelle fonction entre les anciens et les nouveaux
def compare_results(old_results, results)
  # 1 je prend chaque résultat
  results.each do |result|
    #vérifie si l'id de l'ancien résultat et égal id du résultat que je recherche
    old = old_results.find{ |old_result| result["id"] == old_result["id"]}
    #on compare les résultats
    if (result["title"] != old["title"]) then
      puts "Attention le titre de l'annonce \"#{old["title"]}\" a changé \t=> #{result["title"]}"
    end
    #Est-ce-que le prix a été modifié
    if (result["price"] != old["price"]) then
      puts "Attention le prix de l'annonce \"#{old["title"]}\" a changé \t=> #{result["price"]}"
      #system("say \"Houaou, prix modifié sur l'annonce\" #{result["title"]}")
    end
  end
end

results  = annonces.map{|add_id|get_lbc_information(add_id)}

#vérifie si le fichier existe
if File.exists? $result_file_name then
  old_results = load_previous_results
  compare_results(old_results, results)
end

#pour sauvegarder les résultats dans un fichier, j'ouvre le fichier avec argument qui dit qu'on ouvre en écriture
File.open($result_file_name, "w")  do |file|
  file << JSON.generate(results)
end
