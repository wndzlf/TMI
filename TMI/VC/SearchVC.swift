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
    private var recordArray = [Screenshot]()
    private var fetchedRecordArray = [Screenshot]()
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
        return fetchedRecordArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        let candy: Candy
//        if isFiltering() {
//            candy = filteredCandies[indexPath.row]
//        } else {
//            candy = candies[indexPath.row]
//        }
        let fetchText: Screenshot
        
        fetchText = fetchedRecordArray[indexPath.row]
        cell.textLabel!.text = fetchText.text
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
        let request: NSFetchRequest<Screenshot> = Screenshot.fetchRequest()
        //SQL query로는 (select * from Text where content LIKE '%keyword%')와 같은 작업
        request.predicate = NSPredicate(format: "text CONTAINS[cd] %@", keyword)
        do{
            fetchedRecordArray = try context.fetch(request) //조건에 맞는 레코드들 저장
        }catch{
            print("coredata fetch error")
        }
        if(fetchedRecordArray.count > 0){
            for textRecord in fetchedRecordArray{
                //각 레코드들의 localIdentifier만 따로 배열에 저장 후 이를 이용해 뷰에 사진 보여주기
                let aTextRecord:Screenshot = textRecord
                searchedLocalIdentifier.append(aTextRecord.localIdentifier!)
            }
        }
        print("***********검색된 사진의 localIdentifier =")
        print(searchedLocalIdentifier)
        searchedLocalIdentifier.removeAll()
    }
    
    func saveRecord(){
        do{ //디비에 변화 저장하는 메소드
            try context.save()
        }catch{
            print("coredata save error")
        }
    }
    
    private func deleteAllCDRecords() { //디비의 모든 레코드를 삭제하는 메소드
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Text")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            print("deleteAllCDRecords error")
        }
    }
    
    // 디비에서 데이터 삭제할 때 구현
    //    func destroyText(){
    //        context.delete(textArray)
    //        textArray.remove(at: indexPath.row)
    //        saveText()
    //    }

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
