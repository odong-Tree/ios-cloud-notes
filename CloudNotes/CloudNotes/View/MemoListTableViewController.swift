import UIKit
import CoreData

class MemoListTableViewController: UITableViewController {
    var memoList = [Memo]()
    var isCellSelected: Bool = false
    private let plusButton = UIButton()
    private var selectedMemo: Int = 0
    
    lazy var memoData: [NSManagedObject] = {
        return self.fetch()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        tableView.register(MemoListTableViewCell.self, forCellReuseIdentifier: "MemoCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeIsCellSelected), name: NSNotification.Name("ShowTableView"), object: nil)
    }
    
    override init(style: UITableView.Style = .plain) {
        super.init(style: style)
        decodeJSONToMemoList(fileName: "sample")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func changeIsCellSelected() {
        isCellSelected = false
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "메모"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: plusButton)
        configurePlusButton()
    }
    
    private func configurePlusButton() {
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        plusButton.addTarget(self, action: #selector(createMemo), for: .touchUpInside)
    }
    
    @objc func createMemo(sender: UIButton) {
        save(title: "green", body: "red", lastModified: "black")
        
        let memoContentsView = MemoContentsViewController()
        memoContentsView.receiveText(object: self.memoData[0])
        tableView.reloadData()
        self.splitViewController?.showDetailViewController(memoContentsView, sender: nil)
        
        isCellSelected = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memoData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell") as? MemoListTableViewCell else {
            return UITableViewCell()
        }
        let record = self.memoData[indexPath.row]
        
        cell.listTitleLabel.text = record.value(forKey: "title") as? String
        cell.listShortBodyLabel.text = record.value(forKey: "body") as? String
        cell.listLastModifiedDateLabel.text = record.value(forKey: "lastModified") as? String
        
        return cell
    }
    
    func fetch() -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MemoCoreData")
        
        let result = try! managedContext.fetch(fetchRequest)
        return result
    }
    
    func save(title: String, body: String, lastModified: String) {
        let appDelegate =
                UIApplication.shared.delegate as! AppDelegate
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let object = NSEntityDescription.insertNewObject(forEntityName: "MemoCoreData", into: managedContext)
        object.setValue(title, forKey: "title")
        object.setValue(body, forKey: "body")
        object.setValue(lastModified, forKey: "lastModified")
        
        do {
            try managedContext.save()
            self.memoData.insert(object, at: 0)
        } catch {
            managedContext.rollback()
        }
    }
    
    func delete(object: NSManagedObject) {
        let appDelegate =
                UIApplication.shared.delegate as! AppDelegate
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        managedContext.delete(object)
        
        do {
            try managedContext.save()
        } catch {
            managedContext.rollback()
        }
    }
    
    func update(object: NSManagedObject, title: String, body: String, lastModified: String) {
        let appDelegate =
                UIApplication.shared.delegate as! AppDelegate
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        object.setValue(title, forKey: "title")
        object.setValue(body, forKey: "body")
        object.setValue(lastModified, forKey: "lastModified")
        
        do {
            try managedContext.save()
        } catch {
            managedContext.rollback()
        }
        tableView.reloadData()
    }
}

// MARK: UITableViewDelegate
extension MemoListTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memoContentsView = MemoContentsViewController()
        memoContentsView.receiveText(object: self.memoData[indexPath.row])
        self.splitViewController?.showDetailViewController(memoContentsView, sender: nil)
        
        isCellSelected = true
        selectedMemo = indexPath.row
    }
}

// MARK: JSONDecoding
extension MemoListTableViewController {
    private func decodeJSONToMemoList(fileName: String) {
        guard let dataAsset: NSDataAsset = NSDataAsset.init(name: fileName) else {
            return
        }
        let jsonDecoder: JSONDecoder = JSONDecoder()
        do {
            let decodeData = try jsonDecoder.decode([Memo].self, from: dataAsset.data)
            memoList = decodeData
        } catch {
            showAlertMessage(MemoAppError.system.message)
        }
    }
}

// MARK: Alert
extension MemoListTableViewController {
    private func showAlertMessage(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

//// MARK: UIActivityViewController
//extension MemoListTableViewController {
//    private func showActivityView(memo: Memo) {
//        let memoToShare = [memo.title, memo.body, memo.lastModifiedDateString]
//        let activityViewController = UIActivityViewController(activityItems: memoToShare, applicationActivities: nil)
//
//        self.present(activityViewController, animated: true, completion: nil)
//    }
//}
