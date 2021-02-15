import UIKit

class MemoListTableViewController: UIViewController {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(MemoListTableViewCell.self, forCellReuseIdentifier: MemoListTableViewCell.identifier)
        return tableView
    }()
    
    var memoList: [Memo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        decodeData()
        addSubView()
        configureAutoLayout()
        
        self.tableView.reloadData()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func decodeData() {
        let memoListDecodeJSON: DecodeJSON = DecodeJSON()
        
        if let memoListDecodedData = memoListDecodeJSON.decodeJSONFile(fileName: "sample", type: [Memo].self) {
            memoList = memoListDecodedData
        }
    }
    
    func addSubView() {
        view.addSubview(tableView)
    }
    
    func configureAutoLayout() {
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: guide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
    }
}

extension MemoListTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.identifier, for: indexPath) as! MemoListTableViewCell
        
        cell.listTitle.text = self.memoList[indexPath.row].title
        cell.listDate.text = convertDateToString(date: self.memoList[indexPath.row].lastModifiedDate)
        cell.listBody.text = self.memoList[indexPath.row].body
        
        return cell
    }
    
    func convertDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}
