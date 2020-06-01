import UIKit

struct Conversion : Codable {
    let success: Bool
    let timestamp: Int
    let base: String
    let date: String
    let rates: [String : Double]
}

class CalculatorController: UIViewController , UIPickerViewDataSource , UIPickerViewDelegate {

    // MARK: - Properties
    
    enum Operators : Int {
        case plus = 10
        case minus = 11
        case divide = 12
        case multiply = 13
        case result = 14
        case none = 0
    }
    
    let currencyEndpoint = "http://data.fixer.io/api/latest?access_key=15ad160a06946226faca13d30644091a&base=EUR&symbols="
    let currenciesArray = ["USD", "JPY", "GBP", "AUD", "CAD", "CHF", "CNY", "HKD", "NZD"]
    var calculationsDisplay = UITextField()
    var operationSelected: Int = Operators.none.rawValue
    var currentOperand = 1
    var firstOperand: String = "0"
    var secondOperand: String = "0"
    var toCurrencyPickerView = UIPickerView()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toCurrencyPickerView.dataSource = self
        self.toCurrencyPickerView.delegate = self
        configureCalculatorUI()
    }

    // MARK: - Handlers
    
    func configureCalculatorUI() {
        calculationsDisplay.backgroundColor = .black
        calculationsDisplay.textColor = .white
        calculationsDisplay.text = "0"
        calculationsDisplay.font = UIFont.systemFont(ofSize: 44.0)
        calculationsDisplay.adjustsFontSizeToFitWidth = true
        calculationsDisplay.textAlignment = .right
        calculationsDisplay.isUserInteractionEnabled = false
        
        self.view.addSubview(calculationsDisplay)
        calculationsDisplay.translatesAutoresizingMaskIntoConstraints = false
        calculationsDisplay.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        calculationsDisplay.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        calculationsDisplay.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        calculationsDisplay.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.25).isActive = true
        
        let convertCurrencyView = UIView()
        
        self.view.addSubview(convertCurrencyView)
        convertCurrencyView.translatesAutoresizingMaskIntoConstraints = false
        convertCurrencyView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        convertCurrencyView.topAnchor.constraint(equalTo: calculationsDisplay.bottomAnchor).isActive = true
        convertCurrencyView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        convertCurrencyView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.1).isActive = true
        
        let buttonClear = MainButton(buttonTitle: "C", buttonTag: 33, buttonColor: UIColor.CalculatorColors.darkGray)
        buttonClear.addTarget(self, action: #selector(clear), for: .touchUpInside)
        
        convertCurrencyView.addSubview(buttonClear)
        buttonClear.translatesAutoresizingMaskIntoConstraints = false
        buttonClear.leadingAnchor.constraint(equalTo: convertCurrencyView.leadingAnchor).isActive = true
        buttonClear.topAnchor.constraint(equalTo: convertCurrencyView.topAnchor).isActive = true
        buttonClear.bottomAnchor.constraint(equalTo: convertCurrencyView.bottomAnchor).isActive = true
        buttonClear.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.25).isActive = true
    
        let fromCurrency = MainButton(buttonTitle: "EUR", buttonTag: 33, buttonColor: UIColor.CalculatorColors.darkGray)
        fromCurrency.isEnabled = false
        
        convertCurrencyView.addSubview(fromCurrency)
        fromCurrency.translatesAutoresizingMaskIntoConstraints = false
        fromCurrency.leadingAnchor.constraint(equalTo: buttonClear.trailingAnchor).isActive = true
        fromCurrency.topAnchor.constraint(equalTo: convertCurrencyView.topAnchor).isActive = true
        fromCurrency.bottomAnchor.constraint(equalTo: convertCurrencyView.bottomAnchor).isActive = true
        fromCurrency.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.25).isActive = true
        
        let convertCurrencyButton = MainButton(buttonTitle: "→", buttonTag: 33, buttonColor: UIColor.CalculatorColors.darkGray)
        convertCurrencyButton.addTarget(self, action: #selector(changeCurrency), for: .touchUpInside)
        
        convertCurrencyView.addSubview(convertCurrencyButton)
        convertCurrencyButton.translatesAutoresizingMaskIntoConstraints = false
        convertCurrencyButton.leadingAnchor.constraint(equalTo: fromCurrency.trailingAnchor).isActive = true
        convertCurrencyButton.topAnchor.constraint(equalTo: convertCurrencyView.topAnchor).isActive = true
        convertCurrencyButton.bottomAnchor.constraint(equalTo: convertCurrencyView.bottomAnchor).isActive = true
        convertCurrencyButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.25).isActive = true
        
        toCurrencyPickerView.backgroundColor = .orange
        toCurrencyPickerView.layer.borderWidth = 1
        
        convertCurrencyView.addSubview(toCurrencyPickerView)
        toCurrencyPickerView.translatesAutoresizingMaskIntoConstraints = false
        toCurrencyPickerView.leadingAnchor.constraint(equalTo: convertCurrencyButton.trailingAnchor).isActive = true
        toCurrencyPickerView.topAnchor.constraint(equalTo: convertCurrencyView.topAnchor).isActive = true
        toCurrencyPickerView.bottomAnchor.constraint(equalTo: convertCurrencyView.bottomAnchor).isActive = true
        toCurrencyPickerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.25).isActive = true
        
        let buttonsView = UIStackView()
        buttonsView.axis  = NSLayoutConstraint.Axis.vertical
        buttonsView.distribution  = UIStackView.Distribution.fillEqually
        buttonsView.isLayoutMarginsRelativeArrangement = true
        
        self.view.addSubview(buttonsView)
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        buttonsView.topAnchor.constraint(equalTo: fromCurrency.bottomAnchor).isActive = true
        buttonsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        buttonsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        let firstRow = UIStackView()
        firstRow.axis  = NSLayoutConstraint.Axis.horizontal
        firstRow.distribution  = UIStackView.Distribution.fillEqually
        firstRow.isLayoutMarginsRelativeArrangement = true
        
        let secondRow = UIStackView()
        secondRow.axis  = NSLayoutConstraint.Axis.horizontal
        secondRow.distribution  = UIStackView.Distribution.fillEqually
        secondRow.isLayoutMarginsRelativeArrangement = true
        
        let thirdRow = UIStackView()
        thirdRow.axis  = NSLayoutConstraint.Axis.horizontal
        thirdRow.distribution  = UIStackView.Distribution.fillEqually
        thirdRow.isLayoutMarginsRelativeArrangement = true
        
        let fourthRow = UIStackView()
        fourthRow.axis  = NSLayoutConstraint.Axis.horizontal
        fourthRow.distribution  = UIStackView.Distribution.fillEqually
        fourthRow.isLayoutMarginsRelativeArrangement = true
        
        buttonsView.addArrangedSubview(firstRow)
        buttonsView.addArrangedSubview(secondRow)
        buttonsView.addArrangedSubview(thirdRow)
        buttonsView.addArrangedSubview(fourthRow)
        
        let buttonSeven = MainButton(buttonTitle: "7", buttonTag: 7, buttonColor: UIColor.CalculatorColors.lightGray)
        buttonSeven.addTarget(self, action: #selector(appendNumber), for: .touchUpInside)
        
        let buttonEight = MainButton(buttonTitle: "8", buttonTag: 8, buttonColor: UIColor.CalculatorColors.lightGray)
        buttonEight.addTarget(self, action: #selector(appendNumber), for: .touchUpInside)
        
        let buttonNine = MainButton(buttonTitle: "9", buttonTag: 9, buttonColor: UIColor.CalculatorColors.lightGray)
        buttonNine.addTarget(self, action: #selector(appendNumber), for: .touchUpInside)
        
        let buttonPlus = MainButton(buttonTitle: "+", buttonTag: Operators.plus.rawValue, buttonColor: UIColor.CalculatorColors.darkGray)
        buttonPlus.addTarget(self, action: #selector(toggleOperation), for: .touchUpInside)
        
        firstRow.addArrangedSubview(buttonSeven)
        firstRow.addArrangedSubview(buttonEight)
        firstRow.addArrangedSubview(buttonNine)
        firstRow.addArrangedSubview(buttonPlus)
        
        let buttonFour = MainButton(buttonTitle: "4", buttonTag: 4, buttonColor: UIColor.CalculatorColors.lightGray)
        buttonFour.addTarget(self, action: #selector(appendNumber), for: .touchUpInside)
        
        let buttonFive = MainButton(buttonTitle: "5", buttonTag: 5, buttonColor: UIColor.CalculatorColors.lightGray)
        buttonFive.addTarget(self, action: #selector(appendNumber), for: .touchUpInside)
        
        let buttonSix = MainButton(buttonTitle: "6", buttonTag: 6, buttonColor: UIColor.CalculatorColors.lightGray)
        buttonSix.addTarget(self, action: #selector(appendNumber), for: .touchUpInside)
        
        let buttonMinus = MainButton(buttonTitle: "-", buttonTag: Operators.minus.rawValue, buttonColor: UIColor.CalculatorColors.darkGray)
        buttonMinus.addTarget(self, action: #selector(toggleOperation), for: .touchUpInside)
        
        secondRow.addArrangedSubview(buttonFour)
        secondRow.addArrangedSubview(buttonFive)
        secondRow.addArrangedSubview(buttonSix)
        secondRow.addArrangedSubview(buttonMinus)
        
        let buttonOne = MainButton(buttonTitle: "1", buttonTag: 1, buttonColor: UIColor.CalculatorColors.lightGray)
        buttonOne.addTarget(self, action: #selector(appendNumber), for: .touchUpInside)
        
        let buttonTwo = MainButton(buttonTitle: "2", buttonTag: 2, buttonColor: UIColor.CalculatorColors.lightGray)
        buttonTwo.addTarget(self, action: #selector(appendNumber), for: .touchUpInside)
        
        let buttonThree = MainButton(buttonTitle: "3", buttonTag: 3, buttonColor: UIColor.CalculatorColors.lightGray)
        buttonThree.addTarget(self, action: #selector(appendNumber), for: .touchUpInside)

        let buttonMultiply = MainButton(buttonTitle: "X", buttonTag: Operators.multiply.rawValue, buttonColor: UIColor.CalculatorColors.darkGray)
        buttonMultiply.addTarget(self, action: #selector(toggleOperation), for: .touchUpInside)
        
        thirdRow.addArrangedSubview(buttonOne)
        thirdRow.addArrangedSubview(buttonTwo)
        thirdRow.addArrangedSubview(buttonThree)
        thirdRow.addArrangedSubview(buttonMultiply)
        
        let buttonDot = MainButton(buttonTitle: ".", buttonTag: 40, buttonColor: UIColor.CalculatorColors.lightGray)
        buttonDot.addTarget(self, action: #selector(addDot), for: .touchUpInside)
        
        let buttonZero = MainButton(buttonTitle: "0", buttonTag: 0, buttonColor: UIColor.CalculatorColors.lightGray)
        buttonZero.addTarget(self, action: #selector(appendNumber), for: .touchUpInside)
        
        let buttonResult = MainButton(buttonTitle: "=", buttonTag: 14, buttonColor: UIColor.CalculatorColors.orange)
        buttonResult.addTarget(self, action: #selector(result), for: .touchUpInside)

        let buttonDivide = MainButton(buttonTitle: "/", buttonTag: Operators.divide.rawValue, buttonColor: UIColor.CalculatorColors.darkGray)
        buttonDivide.addTarget(self, action: #selector(toggleOperation), for: .touchUpInside)
        
        fourthRow.addArrangedSubview(buttonDot)
        fourthRow.addArrangedSubview(buttonZero)
        fourthRow.addArrangedSubview(buttonResult)
        fourthRow.addArrangedSubview(buttonDivide)
    }
    
    @objc func appendNumber(sender: UIButton){
        if(operationSelected != Operators.none.rawValue) {
            if(secondOperand == "0"){
                if(operationSelected == Operators.result.rawValue){
                    calculationsDisplay.text = String(sender.tag)
                    firstOperand = String(sender.tag)
                    operationSelected = 0
                    currentOperand = 1
                }
                else{
                    calculationsDisplay.text = String(sender.tag)
                    secondOperand = String(sender.tag)
                    currentOperand = 2
                }
            }
            else{
                calculationsDisplay.text = calculationsDisplay.text! + String(sender.tag)
                secondOperand = secondOperand + String(sender.tag)
            }
        }
        else{
            if(calculationsDisplay.text == "0"){
                calculationsDisplay.text = String(sender.tag)
                firstOperand = String(sender.tag)
            }
            else{
                calculationsDisplay.text = calculationsDisplay.text! + String(sender.tag)
                firstOperand = firstOperand + String(sender.tag)
            }
        }
    }
    
    @objc func toggleOperation(sender: UIButton) {
        if (secondOperand != "0") {
            result(sender: sender)
            currentOperand = 2
        }
        else {
            operationSelected = sender.tag
            calculationsDisplay.text = sender.titleLabel?.text
            currentOperand = 2
        }
    }
    
    @objc func clear() {
        firstOperand = "0"
        secondOperand = "0"
        calculationsDisplay.text = "0"
        operationSelected = Operators.none.rawValue
        currentOperand = 1
    }
    
    @objc func addDot() {
        let charset = CharacterSet(charactersIn: "+-/X")
        if calculationsDisplay.text!.rangeOfCharacter(from: charset) != nil {
            return
        }
        else {
            if (currentOperand == 1) {
                firstOperand = firstOperand + "."
                calculationsDisplay.text = firstOperand
            }
            else {
                secondOperand = secondOperand + "."
                calculationsDisplay.text = secondOperand
            }
        }
    }
    
    @objc func result(sender: UIButton) {
        switch operationSelected {
        case Operators.minus.rawValue:
            firstOperand = String(Double(firstOperand)! - Double(secondOperand)!)
        case Operators.plus.rawValue:
            firstOperand = String(Double(firstOperand)! + Double(secondOperand)!)
        case Operators.divide.rawValue:
            firstOperand = String(Double(firstOperand)! / Double(secondOperand)!)
        case Operators.multiply.rawValue:
            firstOperand = String(Double(firstOperand)! * Double(secondOperand)!)
        default:
            print("Nothing happened!")
        }
        if (sender.tag != Operators.result.rawValue) {
            operationSelected = sender.tag
            calculationsDisplay.text = sender.titleLabel?.text
        }
        else {
            let formattedNumber = Double(firstOperand)
            calculationsDisplay.text = String(format:"%g", formattedNumber!)
            operationSelected = Operators.result.rawValue
        }
        secondOperand = "0"
    }
    
    @objc func changeCurrency() {
        
        if((operationSelected != Operators.none.rawValue) && (operationSelected != Operators.result.rawValue)) {
            return
        }
        let toCurrency = currenciesArray[toCurrencyPickerView.selectedRow(inComponent: 0)]
        let url = currencyEndpoint + toCurrency
        let request = URLRequest(url: URL(string: url)!)
        let session = URLSession.shared

        session.dataTask(with: request) {data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "There was an error while communicating with fixer.io. Please try again later!", preferredStyle: .alert)
                    self.present(alert, animated: true)
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when){
                      alert.dismiss(animated: true, completion: nil)
                    }
                }
                return
            }
            
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
                do {
                    let jsonData = dataString.data(using: .utf8)!
                    let jsonDictionary = try! JSONDecoder().decode(Conversion.self, from: jsonData)
                    if (jsonDictionary.success == false) {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error", message: "Something went wrong!", preferredStyle: .alert)
                            self.present(alert, animated: true)
                            let when = DispatchTime.now() + 2
                            DispatchQueue.main.asyncAfter(deadline: when){
                              alert.dismiss(animated: true, completion: nil)
                            }
                        }
                        return
                    }
                    else {
                        let rate = jsonDictionary.rates[toCurrency]
                        DispatchQueue.main.async {
                            let displayTextToNumber = Double(self.calculationsDisplay.text!)
                            let convertedValue = displayTextToNumber! * rate!
                            self.calculationsDisplay.text = String(format:"%g", convertedValue)
                            self.firstOperand = String(format:"%g", convertedValue)
                            self.secondOperand = "0"
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
               }.resume()
    }
    
    // MARK: - UIPicker Functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currenciesArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currenciesArray[row]
    }
}
