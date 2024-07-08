//
//  Message.swift
//  starleet
//
//  Created by Peter Tran on 06/07/2024.
//
import Foundation

struct Message: Identifiable {
    let id = UUID()
    let sender: String
    let content: String
    let time: String
}
