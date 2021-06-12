

# 동기화 메모장

CoreData와 dropbox와 연동하여 변경사항을 실시간으로 연동할 수 있는 메모장

- 프로젝트 진행 기간: 2021.2.15 ~ 2021.3.5
- 팀 프로젝트: Green, 오동나무
- 구현 키워드: CoreData, Delegate Pattern, Locale, SPM, Swift, TableView RowAction, UISplitView, UITableView, UITextField

<br>

# 구현한 기능

### 1.

![memo1](https://user-images.githubusercontent.com/73867548/121781678-ed57d000-cbe0-11eb-86c9-4e06f0778e98.gif)

![memo(iPad)](https://user-images.githubusercontent.com/73867548/121781680-f052c080-cbe0-11eb-8829-479a8d894db4.gif)

- UISplitView 사용하여 SizeClass에 대응하도록 구현
- 메모를 입력하면 title과 body가 분리되도록 구현
- 메모를 수정하면 tableView에서 최상단으로 이동하도록 구현
- textView의 변동사항이 tableView에 실시간으로 반영되도록 구현
- 메모장은 CoreData를 이용하여 저장

<br>

### 2.

![memo(button)](https://user-images.githubusercontent.com/73867548/121781685-f2b51a80-cbe0-11eb-8a84-bd0c177bd052.gif)

- action Sheet를 이용하여 공유, 삭제 버튼 추가
- 삭제 버튼으로 메모를 삭제할 수 있으며, tableView에서 스와이프로도 삭제 가능하도록 구현
- 공유버튼은 UIActivityViewController로 UI만 구현

<br>

### 3.

![memo(searchBar)](https://user-images.githubusercontent.com/73867548/121781690-f8aafb80-cbe0-11eb-839a-62455e3bea0b.gif)

- 메모장 검색이 가능하도록 Search Bar 구현

<br>

### 4.

![May-02-2021_15-41-29](https://user-images.githubusercontent.com/73867548/121781691-fc3e8280-cbe0-11eb-98f0-cd5a5451102a.gif)

- UITextView의 dataDetectorType을 이용하여 메모장에 URL, 번호, 이메일 등을 입력하면 자동으로 감지하고 동작하도록 구현
- 현재 DataDetectorType가 일반 텍스트와 동일하게 표시되는 문제는 해결하지 못함.

<br>

### 5.

![Untitled](https://user-images.githubusercontent.com/73867548/121781695-ffd20980-cbe0-11eb-98d1-5f829e328103.png)

- Swift Package Manager를 활용하여 Dropbox 클라우드 연동

<br>

# 주요 고민 포인트
## 🤔 객체 간 소통하기: Notification → Delegate Pattern

![_2021-05-03__4 03 45](https://user-images.githubusercontent.com/73867548/121781699-02ccfa00-cbe1-11eb-8918-a21204b8d222.jpg)


 MemoListTableViewController는 MemoContentsViewController의 내용과 변경사항에 대해서 실시간으로 메세지를 받아 업데이트하도록 구현해야 했습니다. 이에 대해 결합도를 낮추기 위해 처음에는 NotificationCenter를 이용하여 구현하였으나 코드리뷰를 받은 후 결과적으로 Delegate Pattern을 사용하게 되었습니다. <br>

### **1. NotificationCenter**

```swift
enum NotificationName: String {
    case updateTableViewList = "updateTableViewList"
  case deleteCell = "deleteCell"
  case moveCellToTop = "moveCellToTop"
  case resignFirstResponder = "resignFirstResponder"
}

extension MemoListTableViewController {
    ...

    private func setUpNotification() {
          NotificationCenter.default.addObserver(self, selector: #selector(updateTableViewList), name: NSNotification.Name(NotificationName.updateTableViewList.rawValue), object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(deleteCell), name: NSNotification.Name(rawValue: NotificationName.deleteCell.rawValue), object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(moveCellToTop), name: NSNotification.Name(rawValue: NotificationName.moveCellToTop.rawValue), object: nil)
    }

    ...
}

```

 NotificationCenter를 사용할 경우 다수의 객체에게 메세지를 보낼 수 있고, UserInfo를 통해 정보를 전달할 수 있는 장점이 있었지만 이 경우 해당사항이 없다고 판단했고, Notification.Name 문자열을 관리해주어야 한다는 것이 불편하게 느껴졌습니다. 코드리뷰에서 protocol 이라는 힌트를 얻어 Delegate Pattern에 대해 알게되었고 적용해보았습니다.
 
 <br>

### **2. Delegate Pattern**

```swift
protocol TableViewListManagable: class {
    func updateTableViewList()
    func deleteCell(at indexPathRow: Int) throws
    func moveCellToTop()
    func changeEnrollButtonStatus(textViewIsEmpty: Bool)
}

```

 Delegation 패턴은 protocol을 사용하기 때문에 Notification보다 명확한 메서드를 사용할 수 있다는 점이 좋았습니다. 또한 제 3의 객체인 NotificationCenter을 사용하는 것보다 코드를 구조적으로 작성하고 관리하고 용이했습니다. <br>
 
 하지만 이때 NotificationCenter에 비해 객체 간의 결합도 측면에서는 불리해지기도 했습니다. (TableViewListManagable를 채택하는 프로퍼티를 만들어 할당해주어야하기 때문.) 그러나 Delegate 패턴으로서 얻는 가독성과 명확해진 객체 간의 관계의 이점이 더 크다고 생각하여 결과적으로 Delegate 패턴을 채택하게 되었습니다.
 
 <br>

## 🤔 프로퍼티 초기화

```swift
class MemoContentsViewController: UIViewController {
    ...

    let disclosureBarButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self,action: #selector(showActionSheet))

    ...
}

```

```swift
class CoreDataSingleton {
    ...

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext

    ...
}

```

 위와 같은 식으로 코드를 작성할 경우 에러가 발생했습니다. <br>

 클래스는 모든 프로퍼티가 초기화된 후에 초기화되기 때문에 위와 같이 정의한 프로퍼티에서 self라는 클래스 자체, 혹은 appDelegate와 같은 프로퍼티가 아직 초기화되지 않은 상태에서는 프로퍼티 초기화를 할 수 없었습니다. <br>

 이 문제들은 메서드 안에서 프로퍼티를 초기화하거나, `lazy var`를 사용하여 해결해줄 수 있었습니다. 지연 저장 프로퍼티는 코드가 최초로 사용되는 시점에 초기화가 이루어집니다. <br>

 하지만 지연 저장 프로퍼티는 변수로만 사용 가능하기 때문에 반드시 상수로 선언되어야 하는 경우라면

1. 메서드 내부에서 초기화를 하거나,
2. Optional 타입을 사용하거나,
3. `private(set) lazy var`를 사용하는 방법이 있을 것 같습니다.

 Optional을 사용하는 경우에는 nil 값이 들어갈 수 있다는 점과 옵셔널 바인딩을 해주어야하는 번거로움이 있고, `private(set) lazy var`를 사용하는 경우에는 초기화 후 값이 변경되지 않기 때문에 원하는 시점에 초기화되도록 주의해야할 것 같습니다.
 
 <br>

## 🤔 dataDetectorType

 메모장에서 URL, 전화번호 등을 인지하여 알맞게 동작하게 하려면 UITextView의 `dataDetectorType` 프로퍼티를 이용해야했습니다. 하지만 dataDetectorType은 isEditable이 false일 때에만 유효한데 단순히 isEditable 값을 false로 해줄 경우 텍스트를 수정할 수 없었기에 까다로웠습니다. 만약 isEditable 값을 false로 해주더라도 TextView를 터치하면 터치한 지점이 아닌 텍스트의 제일 마지막 부분에 커서가 찍히는 문제가 있었습니다. <br>

 **TextView 터치시 dataDetectorType을 터치하면 해당 URL로 이동하고, 그 외의 부분을 터치하면 터치한 지점에서 편집이 가능하도록** 구현하고 싶었습니다. <br>

 아래는 한 외국 블로그를 참고해서, 다른 캠퍼들에게 물어가며 작성하게된 코드입니다.

```swift
// MARK: dataDetectorTypes & isEditable
extension MemoContentsViewController {
    @objc func textViewDidTapped(_ recognizer: UITapGestureRecognizer) {
        if memoTextView.isEditable { return }

        guard let textView = recognizer.view as? UITextView else {
            return
        }
        let tappedLocation = recognizer.location(in: textView)
        let glyphIndex = textView.layoutManager.glyphIndex(for: tappedLocation, in: textView.textContainer)

        if glyphIndex < textView.textStorage.length,
           textView.textStorage.attribute(NSAttributedString.Key.link, at: glyphIndex, effectiveRange: nil) == nil {
            placeCursor(textView, tappedLocation)
            makeTextViewEditable()

            navigationItem.rightBarButtonItems?.insert(finishButton, at: 0)
        }

        if glyphIndex >= textView.textStorage.length {
            makeTextViewEditable()
        }
    }

    private func placeCursor(_ myTextView: UITextView, _ location: CGPoint) {
        if let tapPosition = myTextView.closestPosition(to: location) {
            let uiTextRange = myTextView.textRange(from: tapPosition, to: tapPosition)

            if let start = uiTextRange?.start, let end = uiTextRange?.end {
                let loc = myTextView.offset(from: myTextView.beginningOfDocument, to: tapPosition)
                let length = myTextView.offset(from: start, to: end)
                myTextView.selectedRange = NSMakeRange(loc, length)
            }
        }
    }

    private func makeTextViewEditable() {
        memoTextView.isEditable = true
        memoTextView.becomeFirstResponder()
    }
}

```

1. UITapGestureRecognizer의 location 메서드로 터치 지점을 알아낼 수 있습니다.
2. 텍스트 문자와 레이아웃 및 표시를 조정하는 객체인 NSLayoutManager의 `glyphIndex(for:in:)` 메서드로 glyph의 index 값을 구합니다. (* glyph: 정보 기술에서 문자의 모양이나 형태를 나타내는 그래픽 기호)
3. glyphIndex가 text 중간에 위치하는지, text 밖에 위치하는지, link로된 dataDetectorType인지 구분하여 코드를 작성합니다.
4. `placeCursor(_myTextView:_location:)` 메서드는 터치지점에서 가장 가까운 위치에 커서를 가져다 놓습니다.

<br>

## 🤔 메모의 Title과 Body 구분하기

 하나의 TextView에서 Title과 Body을 구분해주어야 했습니다. 만약 Title과 Body 프로퍼티를 따로 만들 경우에는 처음 메모장을 불러올 때에는 깔끔하게 불러올 수 있었지만 실시간으로 메모를 작성해야할 때에는 구분해주기 쉽지 않았습니다. 그 결과 Title과 Body를 묶어 하나의 text로 관리하는 방법을 찾게 되었습니다.

```swift
class MemoContentsViewController: UIViewController {
    func makeAttributedString(text: String)  -> NSAttributedString  {
         let attributedText = NSMutableAttributedString(string: text)
         let splitedString = text.split(separator: "\\n")
         let titleFontSize = UIFont.preferredFont(forTextStyle: .largeTitle)
         let bodyFontSize = UIFont.preferredFont(forTextStyle: .body)
         let enterCount = countEnter(text: text)

         guard let title = splitedString.first else {
             attributedText.addAttributes([.font: titleFontSize], range: NSRange(location: 0, length: text.count))
             return attributedText
         }

         attributedText.addAttributes([.font: titleFontSize], range: NSRange(location: 0, length: title.count))
         attributedText.addAttributes([.font: bodyFontSize], range: NSRange(location: title.count, length: text.count - title.count))
         let titleCount = title.count + enterCount
         let bodyCount = text.count - titleCount

         attributedText.addAttributes([.font: titleFontSize], range: NSRange(location: 0, length: titleCount))
         attributedText.addAttributes([.font: bodyFontSize], range: NSRange(location: titleCount, length: bodyCount))

         return attributedText
     }
}

extension MemoContentsViewController: UITextViewDelegate {
    ...

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.attributedText = makeAttributedString(text: textView.text)
        textView.selectedRange = range
        return true
    }
}

```

- NSMutableAttributedString 클래스를 이용하면 원하는 문자열의 속성을 변경할 수 있습니다.
- NSRange를 이용하여 Title과 Body의 영역을 나누어주었습니다.
- UITextViewDelegate의 `textView(_:shouldChangeTextIn:replacementText:)` 메서드를 사용하여 TextView의 Text를 NSMutableAttributedString으로 변경해주었습니다.

<br>

# 프로젝트 회고

- 코어데이터를 비롯하여 메모장과 관련된 다양한 기능들을 경험해볼 수 있어서 좋았습니다.
- 외부 라이브러리(dropbox)를 사용해보았는데 코드가 어떻게 짜여져있는지 쉽게 파악하지 못했습니다. 관심있는 라이브러리를 열어보는 것도 좋은 공부가 될 것 같습니다.
- 지금까지의 프로젝트 중에서 가장 많은 양의 코드를 작성하는 프로젝트였습니다. 프로젝트를 진행하면서 코드를 수정할 일이 생기면 연쇄적으로 해결해야하는 문제가 발생하기도 했고, 코드가 쉽게 찾아지지 않는 경우도 있었습니다. 앞으로 이보다 더 많은 양의 코드를 자주 만나고 작성하게 될텐데, 가독성과 유지, 보수에 유리한 설계의 중요성을 절실하게 깨달을 수 있는 프로젝트였습니다.

<br>

