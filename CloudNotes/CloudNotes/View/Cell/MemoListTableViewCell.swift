import UIKit

class MemoListTableViewCell: UITableViewCell {
    static let identifier = "MemoListTableViewCell"
    
    let listTitle: UILabel = {
        let listTitle = UILabel()
        listTitle.translatesAutoresizingMaskIntoConstraints = false
        listTitle.font = .preferredFont(forTextStyle: .headline)
        return listTitle
    }()
    
    let listDate: UILabel = {
        let listDate = UILabel()
        listDate.translatesAutoresizingMaskIntoConstraints = false
        listDate.font = .preferredFont(forTextStyle: .body)
        return listDate
    }()

    let listBody: UILabel = {
        let listBody = UILabel()
        listBody.translatesAutoresizingMaskIntoConstraints = false
        listBody.font = .preferredFont(forTextStyle: .body)
        listBody.textColor = .gray
        return listBody
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addContentView()
        configureAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addContentView() {
        contentView.addSubview(listTitle)
        contentView.addSubview(listDate)
        contentView.addSubview(listBody)
    }
    
    private func configureAutoLayout() {
        NSLayoutConstraint.activate([
            listTitle.topAnchor.constraint(equalTo: contentView.topAnchor),
            listTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            listTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            listDate.topAnchor.constraint(equalTo: listTitle.bottomAnchor),
            listDate.leadingAnchor.constraint(equalTo: listTitle.leadingAnchor),
            listDate.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            listBody.topAnchor.constraint(equalTo: listTitle.bottomAnchor),
            listBody.leadingAnchor.constraint(equalTo: listDate.trailingAnchor, constant: 40),
            listBody.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            listBody.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
