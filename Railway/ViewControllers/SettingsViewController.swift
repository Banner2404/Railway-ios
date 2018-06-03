//
//  SettingsViewController.swift
//  Railway
//
//  Created by Евгений Соболь on 6/3/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import GoogleSignIn
import GoogleAPIClientForREST
import PDFKit

class SettingsViewController: ViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    private let disposeBag = DisposeBag()
    private let gmailService = GTLRGmailService()
    
    class func loadFromStoryboard() -> SettingsViewController {
        let viewController = loadViewControllerFromStoryboard() as SettingsViewController
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
}

//MARK: - Private
private extension SettingsViewController {
    
    func setupTableView() {
        let gmailSection = SectionModel(model: "test", items: ["section"])
        let sections = Observable.just([gmailSection])
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, String>>(configureCell: { ds, tableView, indexPath, _ in
            let cell = tableView.dequeueReusableCell(withIdentifier: "GmailTableViewCell", for: indexPath)
            return cell
        })
        sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.tableFooterView = UIView()
        tableView.rx.itemSelected
            .filter { $0.section == 0 }
            .subscribe(onNext: { _ in self.connectGmail() })
            .disposed(by: disposeBag)
    }
    
    func connectGmail() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeGmailReadonly]
        GIDSignIn.sharedInstance().signIn()
    }
}

//MARK: - GIDSignInDelegate
extension SettingsViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print(error)
        guard let user = user else { return }
        gmailService.authorizer = user.authentication.fetcherAuthorizer()
        let query = GTLRGmailQuery_UsersMessagesAttachmentsGet.query(withUserId: "me", messageId: "1621bd28468e1755", identifier: "ANGjdJ9XAjdei7-SqkojI8vY_Es54b8sC0hLWRBzijfFNWTGWYSOpw9OgTdTdC1AXJP8G1VJ8IaKQ8bUYLz9thcWq3JKxtKpYtReH9VqrZ1sXLrGvPo7Ms6Goom-W8LD4U0gedFVy-3dph0mIIPCf9FbO6OlAC-zhXm_dHjhBgWkxrfFrix-pOG5QK4dGZ9aXL66yvScLMXX8MgsWp991cJsxLkxRovWcb7GvnWQit-Y5AJygKl77cv0o2nzWzTut7UJp948KgJh2iGELFmJ1omqAsm-qSfsF6VVGfRLDfNwEN1av95q2pVyrycBcH4oj6v7jeBoxBB0o05s6RV4boO-5ogkQIoi9sIDIVzeaxyL28Pg192bjgFYJOTmesjq_m54pXLnqTizkmwmFOP3")
        gmailService.executeQuery(query) { (ticket, data, error) in
            guard let part = data as? GTLRGmail_MessagePartBody,
                let body = part.data else { return }
            print(MessageProcessor.process(messageData: body))
        }
    }
}

//MARK: - GIDSignInUIDelegate
extension SettingsViewController: GIDSignInUIDelegate {
    
}
