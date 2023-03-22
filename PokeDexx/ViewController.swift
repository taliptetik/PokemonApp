//
//  ViewController.swift
//  PokeDexx
//
//  Created by Talip on 22.03.2023.
//

import UIKit
import PokemonAPI
import SDWebImage

class ViewController: UIViewController {
    
    
    var newData = [Result]()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Method Calling
        parsingJSON { data  in
            self.newData = data
            DispatchQueue.main.async {
                self.tableView.reloadData()
                print("The new data is : \(self.newData)")
            }
        }
    }
    
    func parsingJSON(completion : @escaping ([Result])->() )
    {
        let urlString = "https://pokeapi.co/api/v2/pokemon?limit=50&offset=0"
        let url = URL(string: urlString)
        
        guard url != nil else
        {
            print("error")
            return
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) { data, response, error in
            //Checking errors
            
            if error == nil , data != nil
            {
                //parsing json file
                let decoder = JSONDecoder()
                do{
                    let parsingData = try decoder.decode(AllPokemons.self, from: data!)
                    //print(parsingData)
                    //Closure calling
                    completion(parsingData.results)

                }catch{
                    print("Parsing Error")
                }
                
            }
        }
        dataTask.resume()
        
    }
        
    
    
    
}

extension ViewController : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        cell.textLabel?.text = newData[indexPath.row].name
        cell.textLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        
        PokemonAPI().pokemonService.fetchPokemon(self.newData[indexPath.row].name) { result in
            switch result {
            case .success(let pokemon):
                //self.pokemonLabel.text = pokemon.name // bulbasaur
                DispatchQueue.main.async {
                    cell.imageView?.sd_setImage(with: URL(string: (pokemon.sprites?.frontDefault)!), placeholderImage: UIImage(named: "indir"))
                }
                
            case .failure(let error):
                    print(error.localizedDescription)
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = DetailViewController()
        self.performSegue(withIdentifier: "mainToIndividual", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "mainToIndividual"
        {
            let destView = segue.destination as! DetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            
            PokemonAPI().pokemonService.fetchPokemon(newData[indexPath!.row].name) { result in
                switch result {
                case .success(let pokemon):
                    //self.pokemonLabel.text = pokemon.name // bulbasaur
                    DispatchQueue.main.async {
                        destView.nameLabel.text = "Name: \(pokemon.name ?? "")"
                        destView.abilityLabel.text = "Species: \(pokemon.abilities![0].ability?.name ?? "")"
                        destView.isHiddenLabel.text = "Can Hide?: \(pokemon.abilities![0].isHidden! ? "Hidden" : "Not-Hidden")"
                        destView.slotLabel.text = "No of Slot:  \(String(pokemon.abilities![0].slot!))"
                        destView.pokeImageView.sd_setImage(with: URL(string: (pokemon.sprites?.frontDefault)!), placeholderImage: UIImage(named: ""))
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }

            
        }
    }
}
