//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Spiros Raptis on 30/03/2015.
//  Copyright (c) 2015 Spiros Raptis. All rights reserved.
//


extension GetStudentInformations{
    
    struct Constants {
        
        // MARK: Keys
        static let ApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseApplicationID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    }
    
    // MARK: - Methods
    struct Methods {
        static let AuthenticationSessionNew = "https://www.udacity.com/api/session"
        static let UserData = "https://www.udacity.com/api/users/"
        static let StudentLocations = "https://api.parse.com/1/classes/StudentLocation"
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        static let Session = "session"
        static let Account = "account"
        static let Key = "key"
        static let Id = "id"
        static let User = "user"
        static let Last_Name = "last_name"
        static let First_Name = "first_name"
        static let Results = "results"
        static let ObjectID = "objectId"
        static let UpdatedAt = "updatedAt"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
        
        // MARK: Account
        static let UserID = "id"
        
        
        static let AccessToken = "access_token"
        static let FacebookMobile = "facebook_mobile"
    }
    
    struct JSONBody{
        // MARK: Body for POST
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        static let objectId = "objectId"
        static let uniqueKey = "uniqueKey"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
    }
    
}
