//
//  Typealiases.swift
//  Railway
//
//  Created by Евгений Соболь on 6/8/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation

enum Response<T, E: Error> {
    case success(T)
    case failure(E)
}

enum SimpleResponse<E: Error> {
    case success
    case failure(E)
}

enum GenericError: Error {
    case message(String)
}

typealias ResponseCompletion<T, E: Error> = (Response<T, E>) -> Void
typealias SimpleResponseCompletion<E: Error> = (SimpleResponse<E>) -> Void
