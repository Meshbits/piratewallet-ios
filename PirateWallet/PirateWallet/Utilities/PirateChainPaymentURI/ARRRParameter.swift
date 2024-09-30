//
//  ARRRParameter.swift
//  PirateWallet
//
//  Created by Lokesh on 30/09/24.
//

import Foundation

/// Parameter model.
open class ARRRParameter {
    
    /// The paramenter value.
    open fileprivate(set) var value: String
    
    /// A boolean indicating if the parameter is required.
    open fileprivate(set) var required: Bool

    /**
      Constructor.
     
      - parameter value : The parameter value.
      - parameter required : A boolean indicating if the parameter is required.
    */
    public init(value: String, required: Bool) {
        self.value = value
        self.required = required
    }

}
