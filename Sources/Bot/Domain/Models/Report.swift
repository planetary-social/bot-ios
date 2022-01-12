//
//  Report.swift
//  
//
//  Created by Martin Dutra on 5/1/22.
//

import Foundation

/**
 A Report is an object that encapsulates a notification of some kind: somebody liked your post,
 somebody followed you etc.
 */
public struct Report {

    /// Identity that received this report
    public var authorIdentity: Identity

    /// Identifier of the message that generated this report
    public var messageIdentifier: MessageIdentifier

    /// Kind of report (follow, like, etc)
    public var reportType: ReportType

    /// Time of report creation (for sorting purposes)
    public var createdAt: Date

    /// Message that generated this report
    public var keyValue: KeyValue

}
