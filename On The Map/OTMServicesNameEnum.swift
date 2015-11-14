//
//  OTMServicesNameEnum.swift
//  On The Map
//
//  Enum for the type of action.
//
//  Created by Klaus Villaca on 9/22/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//



enum OTMServicesNameEnum: CustomStringConvertible {
    case updatedAt
    case createdAt
    case createdAtInverted
    case updatedAtInverted
    
    var description: String {
        switch self {
            case .createdAt: return "createdAt"
            case .updatedAt: return "updatedAt"
            case .createdAtInverted: return "-createdAt"
            case .updatedAtInverted: return "-updatedAt"
        }
    }
}
