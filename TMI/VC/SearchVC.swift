//
//  SearchVC.swift
//  TMI
//
//  Created by CHOMINJI on 08/02/2019.
//  Copyright © 2019 momo. All rights reserved.
//

import UIKit
import CoreData

class SearchVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)

//    var candies = [Candy]()
//    var filteredCandies = [Candy]()

     private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedTextArray = [Text]()
    private var searchedLocalIdentifier: [String] = []


    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Candies"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        screenshotSearch(keyword: "Instagram")
        searchController.searchBar.scopeButtonTitles = ["All", "Chocolate", "Hard", "Other"]
        searchController.searchBar.delegate = self
    }


    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
//            searchFooter.setIsFilteringToShow(filteredItemCount: filteredCandies.count, of: candies.count)
            return searchedLocalIdentifier.count
        }

//        searchFooter.setNotFiltering()
        return fetchedTextArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        let candy: Candy
//        if isFiltering() {
//            candy = filteredCandies[indexPath.row]
//        } else {
//            candy = candies[indexPath.row]
//        }
        let fetchText: Text
        
        fetchText = fetchedTextArray[indexPath.row]
        cell.textLabel!.text = fetchText.content
        cell.detailTextLabel!.text = fetchText.localIdentifier
        return cell
    }

    // MARK: - Private instance methods

    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
//        filteredCandies = candies.filter({( candy : Candy) -> Bool in
//            let doesCategoryMatch = (scope == "All") || (candy.category == scope)
//
//            if searchBarIsEmpty() {
//                return doesCategoryMatch
//            } else {
//                return doesCategoryMatch && candy.name.lowercased().contains(searchText.lowercased())
//            }
//        })
//        tableView.reloadData()
    }

    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }

    func screenshotSearch(keyword: String){
        if searchedLocalIdentifier.count > 0 {
            searchedLocalIdentifier.removeAll()
        }
        let request: NSFetchRequest<Text> = Text.fetchRequest()
        //SQL query로는 (select * from Text where content LIKE '%keyword%')와 같은 작업
        request.predicate = NSPredicate(format: "content CONTAINS[cd] %@", keyword)
        do {
            fetchedTextArray = try context.fetch(request) //조건에 맞는 레코드들 저장
        } catch {
            print("coredata fetch error")
        }

        if(fetchedTextArray.count > 0){
            for textRecord in fetchedTextArray {
                //각 레코드들의 localIdentifier만 따로 배열에 저장 후 이를 이용해 뷰에 사진 보여주기
                let aTextRecord: Text = textRecord
                searchedLocalIdentifier.append(aTextRecord.localIdentifier!)
            }
        }

        print("***********검색된 사진의 localIdentifier =")
        print(searchedLocalIdentifier)
//        searchedLocalIdentifier.removeAll()
    }

}

extension SearchVC: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension SearchVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}
