//
//  PassageViewController.swift
//  ITSC
//
//  Created by hbd on 2022/11/9.
//

import UIKit



class PassageViewController: UIViewController {
    
    var url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if url != "" {
            fetch(path: url)
        }
    }
    
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
                                let content = string
                                var views:[UIView] = []
                                //var totalHeight = 0
                                let scrollView = UIScrollView(frame: self.view.frame)
                                let innerView = UIView(frame: self.view.frame)
                                // make title: <h1 class="arti_title">信息化中心召开师生座谈交流会</h1>
                                var titleIndex = content.range(of: "<h1 class=\"arti_title\">")!.upperBound
                                var titleContent = ""
                                while content[titleIndex] != "<" {
                                    titleContent.append(content[titleIndex])
                                    titleIndex = content.index(titleIndex, offsetBy: 1)
                                }
                                let titleLabel = UILabel()
                                titleLabel.text = titleContent
                                titleLabel.font = titleLabel.font.withSize(24)
                                titleLabel.textAlignment = .center
                                // titleLabel.isScrollEnabled = false
                                titleLabel.numberOfLines = 0
                                // titleLabel.lineBreakMode =
                                innerView.addSubview(titleLabel)
                                titleLabel.translatesAutoresizingMaskIntoConstraints = false
                                titleLabel.topAnchor.constraint(equalTo: innerView.topAnchor, constant: 32).isActive = true
                                titleLabel.leadingAnchor.constraint(equalTo: innerView.leadingAnchor, constant: 16).isActive = true
                                titleLabel.trailingAnchor.constraint(equalTo: innerView.trailingAnchor, constant: -16).isActive = true
                                views.append(titleLabel)
                                //totalHeight += titleLabel.frame.height + CGFloat(32)
                                
                                
                                var startIndex = content.range(of: "<div class=\'wp_articlecontent\'>")!.upperBound
                                var paras:[String] = []
                                while true {
                                    var i = 0
                                    var para = ""
                                    while true {
                                        para.append(content[content.index(startIndex, offsetBy: i)])
                                        i += 1
                                        if content[content.index(startIndex, offsetBy: i-1)] == ">"
                                            && content[content.index(startIndex, offsetBy: i-2)] == "p"
                                            && content[content.index(startIndex, offsetBy: i-3)] == "/"
                                            && content[content.index(startIndex, offsetBy: i-4)] == "<" {
                                            paras.append(para)
                                            startIndex = content.index(startIndex, offsetBy: i)
                                            break
                                        }
                                    }
                                    if content[content.index(startIndex, offsetBy: 0)] == "<"
                                        && content[content.index(startIndex, offsetBy: 1)] == "/"
                                        && content[content.index(startIndex, offsetBy: 2)] == "d"
                                        && content[content.index(startIndex, offsetBy: 3)] == "i" {
                                        break
                                    }
                                }
                                
                                for i in 0..<paras.count {
                                    let para = paras[i]
                                    if para.range(of: "<img") == nil {
                                        var result = ""
                                        var read = true
                                        for ch in para {
                                            if ch == "<" {
                                                read = false
                                            } else if ch == ">" {
                                                read = true
                                            } else if read {
                                                result.append(ch)
                                            }
                                        }
                                        while result.range(of: "&nbsp;") != nil {
                                            let blankStart = result.range(of: "&nbsp;")!.lowerBound
                                            let blankEnd = result.range(of: "&nbsp;")!.upperBound
                                            let range = blankStart..<blankEnd
                                            result.removeSubrange(range)
                                            //result.insert("", at: blankStart)
                                        }
                                        if result != "" {
                                            result = "        " + result
                                            let paraLabel = UILabel()
                                            paraLabel.text = result
                                            paraLabel.numberOfLines = 0
                                            innerView.addSubview(paraLabel)
                                            paraLabel.translatesAutoresizingMaskIntoConstraints = false
                                            paraLabel.topAnchor.constraint(equalTo: views.last!.bottomAnchor, constant: 16).isActive = true
                                            paraLabel.leadingAnchor.constraint(equalTo: innerView.leadingAnchor, constant: 16).isActive = true
                                            paraLabel.trailingAnchor.constraint(equalTo: innerView.trailingAnchor, constant: -16).isActive = true
                                            views.append(paraLabel)
                                            
                                        }
                                    } else {
                                        startIndex = para.range(of: "src=\"")!.upperBound
                                        var picUrl = "https://itsc.nju.edu.cn"
                                        for i in 0... {
                                            if para[para.index(startIndex, offsetBy: i)] != "\"" {
                                                picUrl.append(para[para.index(startIndex, offsetBy: i)])
                                            } else {
                                                break
                                            }
                                        }

                                        var data: Data = Data()
                                        do {
                                            data = try Data(contentsOf: URL(string: picUrl)!)
                                        } catch {
                                            
                                        }
                                        let image: UIImage = UIImage(data: data) ?? UIImage()
                                        let imageView:UIImageView = UIImageView(image: image)
                                        imageView.contentMode = UIView.ContentMode.scaleAspectFit
                                        // imageView.layer.masksToBounds = true
                                        innerView.addSubview(imageView)
                                        imageView.translatesAutoresizingMaskIntoConstraints = false
                                        imageView.topAnchor.constraint(equalTo: views.last!.bottomAnchor, constant: 16).isActive = true
                                        imageView.leadingAnchor.constraint(equalTo: innerView.leadingAnchor, constant: 16).isActive = true
                                        imageView.trailingAnchor.constraint(equalTo: innerView.trailingAnchor, constant: -16).isActive = true
                                        views.append(imageView)
                                    }
                                }
                                scrollView.addSubview(innerView)
                                
                                var totalHeight = 0.0
                                for view in views {
                                    if view is UILabel {
                                        let label = view as! UILabel
                                        totalHeight += (Double(label.intrinsicContentSize.width) / Double(innerView.frame.size.width - 40) * Double(label.intrinsicContentSize.height)) + 18
                                    } else {
                                        totalHeight += Double(view.frame.height) + 18
                                    }
                                }
                                print("******")
                                
                                scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: CGFloat(totalHeight + Double(views.count * 18)))
                                self.view.addSubview(scrollView)
                            }
            }
        })
        task.resume()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
