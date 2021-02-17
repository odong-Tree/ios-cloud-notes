import UIKit

class MemoViewController: UIViewController {
    let memoListView = MemoListTableViewController()
    let memoContentsView = MemoContentsViewController()
    let enrollButton = UIButton()
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        traitCollectionDidChange(traitCollection)
    }
    
    func configureNavigationBar() {
        configureEnrollButton()
        navigationItem.title = "메모"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: enrollButton)
    }
    
    func configureEnrollButton() {
        enrollButton.translatesAutoresizingMaskIntoConstraints = false
        enrollButton.setImage(UIImage(systemName: "plus"), for: .normal)
        enrollButton.addTarget(self, action: #selector(moveToEnrollView), for: .touchUpInside)
    }
    
    @objc func moveToEnrollView(sender: UIButton) {
        let savedTraitCollection = UITraitCollection.current
        
        switch (savedTraitCollection.horizontalSizeClass) {
//        case (.regular):
         // 테이블 셀 1개 추가
         // 우측에 새로운 텍스트뷰 1개 생성
            
        case (.compact):
            self.navigationController?.pushViewController(memoContentsView, animated: true)
            
        default: break
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let savedTraitCollection = UITraitCollection.current
        
        switch (savedTraitCollection.horizontalSizeClass) {
        case (.regular):
            rightView.isHidden = false
            leftView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width / 3, height: UIScreen.main.bounds.size.height)
            rightView.frame = CGRect(x: UIScreen.main.bounds.size.width / 3, y: 0, width: (UIScreen.main.bounds.size.width / 3) * 2, height: UIScreen.main.bounds.size.height)
            
//            navigationController?.size(forChildContentContainer: leftView as! UIContentContainer, withParentContainerSize: CGSize(width: 100, height: 4))
        
//            UINavigationBar.appearance().frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 210.0)
        
            self.navigationController?.navigationBar.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 210.0)
            
        case (.compact):
            rightView.isHidden = true
            leftView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)

        default: break
        }
    }
}
