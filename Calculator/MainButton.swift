import UIKit

class MainButton: UIButton {
    
    var buttonTitle: String
    var buttonTag: Int
    var buttonColor: UIColor

    required init(buttonTitle: String, buttonTag: Int, buttonColor: UIColor){
        self.buttonTitle = buttonTitle
        self.buttonTag = buttonTag
        self.buttonColor = buttonColor
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }

    func setup() {
        self.setTitle(buttonTitle, for: .normal)
        self.tag = buttonTag
        self.backgroundColor = buttonColor
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.lightGray, for: .highlighted)
        self.setTitleColor(UIColor.black, for: .selected)
        self.titleLabel?.font = .boldSystemFont(ofSize: 22)
        self.tintColor = UIColor.white
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
    }
}
