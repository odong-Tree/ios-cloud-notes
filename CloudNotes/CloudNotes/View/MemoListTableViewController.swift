import UIKit

class MemoListTableViewController: UITableViewController {
    var memoList = [Memo]()
    var isCellSelected: Bool = false
    private let plusButton = UIButton()
    private var selectedMemo: Int = 0
    
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
        plusButton.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell") as? MemoListTableViewCell else {
            return UITableViewCell()
        }
        cell.receiveLabelsText(memo: memoList[indexPath.row])
        
        return cell
    }
    
    @objc func showActionSheet(sender: UIButton) {
        showActionSheetMessage()
    }
    
    private func deleteMemo() {
        let indexPath = IndexPath(row: selectedMemo, section: 0)
        memoList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        selectedMemo = 0
        
        let memoContentsView = MemoContentsViewController()
        memoContentsView.receiveText(memo: memoList[0])
        
        if UITraitCollection.current.horizontalSizeClass == .regular {
            self.splitViewController?.showDetailViewController(memoContentsView, sender: nil)
        }
        isCellSelected = true
    }
}

// MARK: UITableViewDelegate
extension MemoListTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memoContentsView = MemoContentsViewController()
        memoContentsView.receiveText(memo: memoList[indexPath.row])
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
    
    private func showActionSheetMessage() {
        let actionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let shareAction = UIAlertAction(title: "Share", style: .default, handler: { [self]
            (action: UIAlertAction) in showActivityView(memo: memoList[selectedMemo])
        })
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
            (action: UIAlertAction) in self.showDeleteMessage()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionMenu.addAction(shareAction)
        actionMenu.addAction(deleteAction)
        actionMenu.addAction(cancelAction)
        
        self.present(actionMenu, animated: true, completion: nil)
    }
    
    private func showDeleteMessage() {
        let deleteMenu = UIAlertController(title: "진짜요?", message: "정말로 삭제하시겠어요?", preferredStyle: UIAlertController.Style.alert)
        
        let cancleAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive, handler: {
            (action: UIAlertAction) in self.deleteMemo()
        })
        deleteMenu.addAction(cancleAction)
        deleteMenu.addAction(deleteAction)
        
        present(deleteMenu, animated: true, completion: nil)
    }
}

// MARK: UIActivityViewController
extension MemoListTableViewController {
    private func showActivityView(memo: Memo) {
        let memoToShare = [memo.title, memo.body, memo.lastModifiedDateString]
        let activityViewController = UIActivityViewController(activityItems: memoToShare, applicationActivities: nil)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
}
