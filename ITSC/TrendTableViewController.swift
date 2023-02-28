//
//  TrendTableViewController.swift
//  ITSC
//
//  Created by hbd on 2022/11/11.
//

import UIKit

class TrendTableViewController: UITableViewController {

    let prefix = "https://itsc.nju.edu.cn/wlyxqk/list"
    let suffix = ".htm"
    var pageHtml: String = ""
    
    struct News {
        var path: String
        var title: String
        var time: String
    }
    
    var newsList: [News] = []
    
    func fetch(path: String){
        let url = URL(string: path)!
        let task = URLSession.shared.dataTask(with: url, completionHandler: {
            data, response, error in
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("server error")
                return
            }
            if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                        let data = data,
                        let string = String(data: data, encoding: .utf8) {
                            DispatchQueue.main.async {
                                self.pageHtml = string
                                do {
                                    try self.fillList()
                                } catch {
                                      
                                }
                            }
            }
        })
        task.resume()
    }
    
    func fillList() throws {
        var cur = self.pageHtml
        while true {
            let ran = cur.range(of: "<span class=\"news_title\"><a href=\'")
            if ran == nil {
                break
            }
            var s = ""
            for i in 0... {
                if cur[cur.index(ran!.upperBound, offsetBy: i)] != "\'" {
                    s.append(cur[cur.index(ran!.upperBound, offsetBy: i)])
                } else {
                    break
                }
            }
            let newsUrl = "https://itsc.nju.edu.cn" + s
            var titleStart = 0
            for i in 0... {
                if cur[cur.index(ran!.upperBound, offsetBy: i)] == "e" &&
                    cur[cur.index(ran!.upperBound, offsetBy: i+1)] == "=" &&
                    cur[cur.index(ran!.upperBound, offsetBy: i+2)] == "\'" {
                    titleStart = i + 3
                    break
                }
            }
            
            var title = ""
            for i in titleStart... {
                if cur[cur.index(ran!.upperBound, offsetBy: i)] != "\'" {
                    title.append(cur[cur.index(ran!.upperBound, offsetBy: i)])
                } else {
                    titleStart = i
                    break
                }
            }
            
            var issueTime = ""
            let timeBound = cur.range(of: "<span class=\"news_meta\">")!.upperBound
            for i in 0... {
                let c = cur[cur.index(timeBound, offsetBy: i)]
                if c == "<" {
                    break
                } else {
                    issueTime.append(c)
                }
            }
            newsList.append(News(path: newsUrl, title: title, time: issueTime))
            cur = String(cur[cur.index(ran!.upperBound, offsetBy: titleStart)..<cur.endIndex])
        }
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        for i in 1...13 {
            fetch(path: prefix + String(i) + suffix)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.newsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "news", for: indexPath)
        cell.textLabel?.text = self.newsList[indexPath.row].title
        cell.detailTextLabel?.text = self.newsList[indexPath.row].time
        // Configure the cell...
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    var clicked: Int = -1
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        clicked = indexPath.row
        // print(clicked)
        return indexPath
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let controller = segue.destination as! PassageViewController
        controller.url = self.newsList[clicked].path
    }

}
