//
//  MailSyncronizer.swift
//  Railway
//
//  Created by Евгений Соболь on 6/8/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import GoogleSignIn
import GoogleAPIClientForREST

protocol MailSyncronizer {
    
    var isSyncronizing: Observable<Bool> { get }
    var newTickets: Observable<Ticket> { get }
    var isAuthenticated: Observable<Bool> { get }
    
    func requestSignIn(on viewController: UIViewController) -> Single<Void>
    func signOut()
    func sync()
}

class GmailSyncronizer: NSObject, MailSyncronizer {
    
    var isSyncronizing: Observable<Bool> {
        return isSyncronizingRelay.asObservable()
    }

    var newTickets: Observable<Ticket> {
        return newTicketsSubject.asObservable()
    }
    
    var isAuthenticated: Observable<Bool> {
        return isAuthenticatedRelay.asObservable()
    }
    
    private let isSyncronizingRelay = BehaviorRelay<Bool>(value: false)
    private let isAuthenticatedRelay = BehaviorRelay<Bool>(value: false)
    private let newTicketsSubject = PublishSubject<Ticket>()
    private let googleSignIn: GIDSignIn
    private let gmailService: GTLRGmailService
    private var signInHandler: ((SingleEvent<Void>) -> Void)?
    private let disposeBag = DisposeBag()
    private let databaseManager: DatabaseManager
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        googleSignIn = GIDSignIn.sharedInstance()
        gmailService = GTLRGmailService()
        super.init()
        
        isAuthenticated
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe { _ in
                self.sync()
        }
            .disposed(by: disposeBag)
        
        isAuthenticated
            .bind(to: isSyncronizingRelay)
            .disposed(by: disposeBag)
        
        newTickets
            .subscribe(onNext: { ticket in
                databaseManager.add(ticket)
            })
            .disposed(by: disposeBag)
        
        googleSignIn.delegate = self
        googleSignIn.scopes = [kGTLRAuthScopeGmailReadonly]
        googleSignIn.restorePreviousSignIn()

        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
            .withLatestFrom(isAuthenticated) { ($0, $1) }
            .filter { $1 }
            .subscribe(onNext: { [weak self] _ in
                self?.sync()
            })
            .disposed(by: disposeBag)
    }
    
    func requestSignIn(on viewController: UIViewController) -> Single<Void> {
        googleSignIn.presentingViewController = viewController
        googleSignIn.signIn()
        return Single.create(subscribe: { handler -> Disposable in
            let disposable = Disposables.create()
            self.signInHandler = handler
            return disposable
        })
    }
    
    func signOut() {
        googleSignIn.signOut()
        isAuthenticatedRelay.accept(false)
    }

    func sync() {
        isSyncronizingRelay.accept(true)
        fetchMessagesList()
            .asObservable()
            .flatMap { messages in
                Observable.from(messages)
            }
            .flatMap { message in
                self.fetchMessageDetails(for: message)
                    .asObservable()
            }
            .flatMap { message in
                self.fetchAttachment(from: message)
                    .map(Optional.init)
                    .catchErrorJustReturn(nil)
                    .filter { $0 != nil }
                    .map { $0! }
            }
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .map { data in
                MessageProcessor.process(messageData: data)
            }
            .observeOn(MainScheduler.instance)
            .flatMap { tickets in
                Observable.from(tickets)
            }
            .subscribe(onNext: { ticket in
                self.newTicketsSubject.onNext(ticket)
            }, onError: { _ in
                self.isSyncronizingRelay.accept(false)
            }, onCompleted: {
                self.isSyncronizingRelay.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchMessagesList() -> Single<[GTLRGmail_Message]> {
        let query = GTLRGmailQuery_UsersMessagesList.query(withUserId: "me")
        query.q = "from: admpoezd@mnsk.rw.by " +
            (lastSyncQuery() ?? firstSyncQuery())
        return Single.create { handler -> Disposable in
            let disposable = Disposables.create()
            self.gmailService.executeQuery(query) { (ticket, data, error) in
                if let error = error {
                    handler(.failure(error))
                    return
                }
                guard let data = data else {
                    handler(.failure(GenericError.message("Unable to get data from server")))
                    return
                }
                guard let messagesList = data as? GTLRGmail_ListMessagesResponse,
                    let messages = messagesList.messages else {
                    handler(.failure(GenericError.message("Incorrect data type from server")))
                    return
                }
                self.saveSyncDate()
                handler(.success(messages))
            }
            return disposable
        }
    }
    
    private func fetchMessageDetails(for message: GTLRGmail_Message) -> Single<GTLRGmail_Message> {
        return Single.create { handler -> Disposable in
            let disposable = Disposables.create()
            guard let id = message.identifier else {
                handler(.failure(GenericError.message("Nil message identifier")))
                return disposable
            }
            let query = GTLRGmailQuery_UsersMessagesGet.query(withUserId: "me", identifier: id)
            self.gmailService.executeQuery(query) { (_, data, error) in
                if let error = error {
                    handler(.failure(error))
                    return
                }
                guard let data = data else {
                    handler(.failure(GenericError.message("Unable to get data from server")))
                    return
                }
                guard let message = data as? GTLRGmail_Message else {
                    handler(.failure(GenericError.message("Incorrect data type from server")))
                    return
                }
                handler(.success(message))
            }
            return disposable
        }
    }
    
    private func fetchAttachment(from message: GTLRGmail_Message) -> Single<String>  {
        return Single.create { handler -> Disposable in
            let disposable = Disposables.create()
            guard let messageId = message.identifier,
                let attachmentId = message.payload?.parts?.first(where: { $0.mimeType == "application/pdf"})?.body?.attachmentId else {
                handler(.failure(GenericError.message("Unable to get attachment")))
                return disposable
            }
            let query = GTLRGmailQuery_UsersMessagesAttachmentsGet.query(withUserId: "me", messageId: messageId, identifier: attachmentId)
            self.gmailService.executeQuery(query) { (_, data, error) in
                if let error = error {
                    handler(.failure(error))
                    return
                }
                guard let data = data else {
                    handler(.failure(GenericError.message("Unable to get data from server")))
                    return
                }
                guard let attachment = data as? GTLRGmail_MessagePartBody,
                    let attachmentData = attachment.data else {
                    handler(.failure(GenericError.message("Incorrect data type from server")))
                    return
                }
                handler(.success(attachmentData))
            }
            return disposable
        }
    }
    
    private func lastSyncQuery() -> String? {
        guard let date = lastSyncDate() else { return nil }
        return "after: \(Int(date.timeIntervalSince1970))"
    }

    private func firstSyncQuery() -> String {
        let date = Date().addingTimeInterval(-60 * 60 * 24 * 365)
        return "after: \(Int(date.timeIntervalSince1970))"
    }
    
    private func saveSyncDate() {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "GmailSyncDate")
    }
    
    private func lastSyncDate() -> Date? {
        let timestamp = UserDefaults.standard.double(forKey: "GmailSyncDate")
        if timestamp < 1.0 { return nil }
        return Date(timeIntervalSince1970: timestamp)
    }
}

//MARK: - GIDSignInDelegate
extension GmailSyncronizer: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        defer {
            signInHandler = nil
        }
        if let error = error {
            print(error.localizedDescription)
            isAuthenticatedRelay.accept(false)
            signInHandler?(.failure(error))
            return
        }
        guard let user = user else {
            isAuthenticatedRelay.accept(false)
            signInHandler?(.failure(GenericError.message("Unable to get user data")))
            return
        }
        gmailService.authorizer = user.authentication.fetcherAuthorizer()
        isAuthenticatedRelay.accept(true)
        signInHandler?(.success(()))
        
    }
}
