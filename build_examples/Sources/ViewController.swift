import UIKit
import crypto_sdk

class ViewController: UIViewController {
    
    lazy var inputLabel: UILabel = {
        let valueLabel = UILabel()
        valueLabel.text = "I'm the plain text"
        valueLabel.textAlignment = .center
        return valueLabel
    }()
    
    lazy var outputLabel: UILabel = {
        let valueLabel = UILabel()
        valueLabel.textAlignment = .center
        return valueLabel
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.borderStyle = .line
        textField.isSecureTextEntry = true
        textField.placeholder = "Enter password here"
        return textField
    }()
    
    lazy var saveButton: UIButton = {
        let saveButton = UIButton()
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.blue, for: .normal)
        saveButton.setTitleColor(.lightGray, for: .highlighted)
        saveButton.addTarget(self, action: #selector(encrypt), for: .touchUpInside)
        return saveButton
    }()
    
    let crypto = Crypto()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10.0
        
        stackView.addArrangedSubview(inputLabel)
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(saveButton)
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(outputLabel)
        
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 250),
            stackView.heightAnchor.constraint(equalToConstant: 250)
            ])
    }
    
    @objc private func encrypt() {
        guard let plainText = self.inputLabel.text,
            let data = plainText.data(using: .utf8),
            let password = self.textField.text,
            password.count > 0 else {
                self.outputLabel.text = "Invalid input"
                return
        }
        self.textField.text = nil
        do {
            let userKeyPair = try crypto.generateUserKeyPair(password: password)
            
            let plainFileKey = try crypto.generateFileKey()
            _ = try encryptData(fileKey: plainFileKey, plainData: data)
            _ = try crypto.encryptFileKey(fileKey: plainFileKey, publicKey: userKeyPair.publicKeyContainer)
            self.outputLabel.text = "Successfully encrypted"
        } catch {
            self.outputLabel.text = error.localizedDescription
        }
        
    }
    
    /*
     For further encryption and decryption examples check out CryptoSDK.playground
     */
    private func encryptData(fileKey: PlainFileKey, plainData: Data) throws -> Data {
        let bufferSize = 200 * 1024
        let encryptionCipher = try crypto.createEncryptionCipher(fileKey: fileKey)
        let inputStream = InputStream(data: plainData)
        var encryptedData = Data()
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        inputStream.open()
        defer {
            buffer.deallocate()
            inputStream.close()
        }
        
        while inputStream.hasBytesAvailable {
            let read = inputStream.read(buffer, maxLength: bufferSize)
            if read > 0 {
                var plainData = Data()
                plainData.append(buffer, count: read)
                let encData = try encryptionCipher.processBlock(fileData: plainData)
                encryptedData.append(encData)
            } else if let error = inputStream.streamError {
                throw error
            }
        }
        try encryptionCipher.doFinal()
        
        return encryptedData
    }
}

