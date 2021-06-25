//
//  MetadataItem.swift
//  IIIF Presenter
//
//  Created by Jakub Fiser on 30/04/2017.
//  Copyright © 2017 Jakub Fiser. All rights reserved.
//  Edits by Christy Ye, (c) University of Southern California 
import Foundation

struct MetadataItem: Codable {
    
    fileprivate var label: String?
    fileprivate var value: String?
    fileprivate var valueList: [String]?
    fileprivate var labelTranslations: [String:String]?
    fileprivate var valueTranslations: [String:String]?
    
    init?(json: [String:Any]) {
        if let key = json["label"] as? String {
            self.label = key.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let keys = json["label"] as? [[String:String]] {
            labelTranslations = [:]
            for key in keys {
                guard let lang = key["@language"], let value = key["@value"] else {
                    print("Language or value not present in metadata label item.")
                    continue
                }
                let valueTrimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                labelTranslations![lang] = valueTrimmed
                if let simpleLang = lang.components(separatedBy: "-").first {
                    labelTranslations![simpleLang] = valueTrimmed
                }
            }
        } else {
            print("Unexpected label format: \(String(describing: json["label"])).")
            return nil
        }
        
        if let value = json["value"] as? String {
            self.value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let values = json["value"] as? [String] {
            valueList = values.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
        } else if let values = json["value"] as? [[String:String]] {
            valueTranslations = [:]
            for key in values {
                guard let lang = key["@language"], let value = key["@value"] else {
                    print("Language or value not present in metadata value item.")
                    continue
                }
                let valueTrimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                valueTranslations![lang] = valueTrimmed
                if let simpleLang = lang.components(separatedBy: "-").first {
                    valueTranslations![simpleLang] = valueTrimmed
                }

            }
        } else {
            print("Unexpected value format: \(String(describing: json["value"])).")
            return nil
        }
    }
    
    func getLabel(forLanguage lang: String) -> String? {
        let search = labelTranslations?[lang] ?? label
        let def = labelTranslations?["en"] ?? labelTranslations?.values.first
        return search ?? def
    }
    
    //adding multiple values together into one string for ContentView
    func getValue(forLanguage lang: String) -> String? {
        var temp = ""
        if (valueList?.count ?? 0 > 0) {
            temp = valueList?.joined(separator: ", ") ?? value!
        }
        let search = valueTranslations?[lang] ?? temp
        //let def = valueTranslations?["en"] ?? valueTranslations!.values.first
        return search //?? def
    }
}
