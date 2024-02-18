//
//  BlockViewController.swift
//  BlockNumberDemo
//
//  Created by Bhumita Panara on 15/01/24.
//

import UIKit
import CallKit
import Contacts
import Foundation

class BlockViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{

    //MARK: - OUTLETS
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblError: UILabel!
    
    //MARK: - GLOBAL VARIABLES
    var phoneNumberArray: [String] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    //MARK: - UI VIEW CONTROLLER LIFE CYCLES
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberArray = appDelegate.getBlockedContacts()
        if phoneNumberArray.count > 0{
            tblView.reloadData()
        }
    }
    
    //MARK: - ACTIONS
    @IBAction func onClickBtnBlock(_ sender: UIButton){
        self.view?.endEditing(true)
        if (txtPhoneNumber.text != nil){
            if validatePhoneNumber(number: txtPhoneNumber.text!).0{
                lblError.isHidden = true
                appDelegate.updateBlockedContactsList(contacts: phoneNumberArray)
                CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "com.test.BlockNumberDemo.BlockNumberDirectory", completionHandler: nil)
                txtPhoneNumber.text?.removeAll()
            }else{
                lblError.isHidden = false
                lblError.text = validatePhoneNumber(number: txtPhoneNumber.text!).1
            }
        }
    }
    
    //MARK: - OTHER METHODS
    
    func validatePhoneNumber(number: String) -> (Bool,String){
        var value = number
        if !value.hasPrefix("+") {
            return (false,"Enter country dial code followed by phone number")
        }
        value = value.removeFormat()
        
        if self.phoneNumberArray.contains(value) {
            return (false,"Already exists")
        }
        
        // add num to blocklist
        print("BlockedNumber - \(value)")
        self.phoneNumberArray.append(value)
        tblView.reloadData()
        print("BlockList = \(phoneNumberArray)")
        return (true,"")
    }
    
    func unBlockNumber(number: String){
        for index in 0..<phoneNumberArray.count{
            if phoneNumberArray[index] == number{
                print("Unblocked NUmber - \(phoneNumberArray[index])")
                phoneNumberArray.remove(at: index)
                appDelegate.updateBlockedContactsList(contacts: phoneNumberArray)
                CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "com.test.BlockNumberDemo.BlockNumberDirectory", completionHandler: nil)
                tblView.reloadData()
            }
        }
    }
    
    //MARK: - UI TABLE VIEW DELEGATE AND DATASOURCE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phoneNumberArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "phoneCell", for: indexPath)
        
        cell.textLabel?.text = phoneNumberArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = UIContextualAction(style: .destructive, title: "UnBlock") { contextualAction, view, BoolValue in
            self.unBlockNumber(number: self.phoneNumberArray[indexPath.row])
        }
        item.image = UIImage(systemName: "delete")
        let swipeActions = UISwipeActionsConfiguration(actions: [item])
        return swipeActions
    }
}

//MARK: - HELPERS
extension String {
    func removeFormat() -> String {
        var mobileNumber: String = self
        mobileNumber = mobileNumber.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        mobileNumber = mobileNumber.trimmingCharacters(in: CharacterSet.symbols)
        mobileNumber = mobileNumber.trimmingCharacters(in: CharacterSet.punctuationCharacters)
        mobileNumber = mobileNumber.trimmingCharacters(in: CharacterSet.controlCharacters)
        mobileNumber = mobileNumber.replacingOccurrences(of: "+", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: " ", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: "-", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: "\u{00a0}", with: "")
        return mobileNumber
    }
}
