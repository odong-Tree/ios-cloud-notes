import UIKit

class MemoContentsViewController: UIViewController {
    let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.dataDetectorTypes = UIDataDetectorTypes.all
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubView()
        configureAutoLayout()
    }
    
    func addSubView() {
        view.addSubview(textView)
    }
    
    func configureAutoLayout() {
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: guide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
    }
}
