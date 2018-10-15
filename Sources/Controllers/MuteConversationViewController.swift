//
//  MuteConversationViewController.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 15/10/18.
//

import Foundation
import Applozic

protocol MuteConversationProtocol: class {
    func mute(conversation: ALMessage, forTime: Int64, atIndexPath: IndexPath)
}

class MuteConversationViewController: UIViewController {
    
    var delegate: MuteConversationProtocol!
    var conversation: ALMessage!
    var indexPath: IndexPath!
    
    private let modalView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let popupTitle: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont(name: "Helvetica", size: 14)
        return label
    }()
    
    private let timePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.showsSelectionIndicator = true
        return picker
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("ConfirmButton", value: SystemMessage.ButtonName.Confirm, comment: ""), for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("ButtonCancel", value: SystemMessage.ButtonName.Cancel, comment: ""), for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    
    private lazy var actionButtons: UIStackView = {
        let buttons = UIStackView(arrangedSubviews: [self.cancelButton, self.confirmButton])
        buttons.axis = .horizontal
        buttons.alignment = .center
        buttons.distribution = .fillEqually
        buttons.spacing = 10.0
        buttons.backgroundColor = UIColor.black
        return buttons
    }()
    
    let timeValues: [String] = {
        let values = [
            NSLocalizedString("EightHour", value: SystemMessage.MutePopup.EightHour, comment: ""),
            NSLocalizedString("OneWeek", value: SystemMessage.MutePopup.OneWeek, comment: ""),
            NSLocalizedString("OneYear", value: SystemMessage.MutePopup.OneYear, comment: "")
        ]
        return values
    }()
    
    init(delegate: MuteConversationProtocol, conversation: ALMessage, atIndexPath: IndexPath) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.conversation = conversation
        self.indexPath = atIndexPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(10, green: 10, blue: 10, alpha: 0.2)
        self.view.isOpaque = false
    }
    
    func updateTitle(_ text: String) {
        self.popupTitle.text = text
    }
    
    @objc func tappedConfirm() {
        
        switch timePicker.selectedRow(inComponent: 0) {
        case 0:
            // 8 hours
            let time: Int64 = 8*60*60*1000
            delegate.mute(conversation: self.conversation, forTime: Int64(time), atIndexPath: indexPath)
            
        case 1:
            // 1 week
            let time: Int64 = 7*24*60*60*1000
            delegate.mute(conversation: self.conversation, forTime: Int64(time), atIndexPath: indexPath)
            
        case 2:
            // 1 year
            let time: Int64 = 365*24*60*60*1000
            delegate.mute(conversation: self.conversation, forTime: Int64(time), atIndexPath: indexPath)
            
        default:
            print("This won't occur")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func tappedCancel() {
         self.dismiss(animated: true, completion: nil)
    }
    
    func setupViews() {
        self.view.addViewsForAutolayout(views: [modalView])
        
        modalView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        modalView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        modalView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        modalView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        modalView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        
        modalView.addViewsForAutolayout(views: [popupTitle, timePicker, actionButtons])
        
        popupTitle.topAnchor.constraint(equalTo: modalView.topAnchor, constant: 10).isActive = true
        popupTitle.centerXAnchor.constraint(equalTo: modalView.centerXAnchor).isActive = true
        
        timePicker.topAnchor.constraint(equalTo: popupTitle.bottomAnchor, constant: 2).isActive = true
        timePicker.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 2).isActive = true
        timePicker.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: 2).isActive = true
        
        actionButtons.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 2).isActive = true
        actionButtons.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 2).isActive = true
        actionButtons.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -2).isActive = true
        actionButtons.bottomAnchor.constraint(equalTo: modalView.bottomAnchor).isActive = true
        
        //Picker view delegate and datasource
        timePicker.delegate = self
        timePicker.dataSource = self
        
        //Default set first row i.e. 8 hours
        timePicker.selectRow(0, inComponent: 0, animated: true)
        
        //Add button actions
        confirmButton.addTarget(self, action: #selector(tappedConfirm), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(tappedCancel), for: .touchUpInside)
        
    }
    
}

extension MuteConversationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.timeValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.timeValues[row]
    }
}
