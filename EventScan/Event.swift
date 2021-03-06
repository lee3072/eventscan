//
//  Event.swift
//  EventScan
//
//  Created by Abid Amirali on 4/15/19.
//  Copyright © 2019 eventScan. All rights reserved.
//

import Foundation

struct Event {
    let name: String
    let location: String
    //    let date: String
    let day: String
    let time: String
    let year: String
    let month: String
    let detail: String
    
    var date: Date {
        
        let year = self.year.count > 0 ? (self.year.count > 2 ? "yyyy" : "yy") : ""
        let day = self.day.count > 0 ? (self.day.count <= 2 ? "dd" : (self.day.count <= 4 ? "E" : "EEEE")) : ""
        let month = self.month.count > 0 ? (self.day.count <= 2 ? "MM" : (self.day.count == 3 ? "MMM" : "MMMM")) : ""
        
        //todo time
        var time = ""
        if self.time.contains(":") {
            let timeComponents = self.time.split(separator: ":")
            if timeComponents.count == 2 {
                time = "HH:mm"
            }
        } else {
            time = "HH"
        }
        
//        if self.time.contains("AM") || self.time.contains("PM") {
//            time += "-a"
//        }
        
        
        var formatString = ""
        formatString += (day.count > 0) ? day + "-" : ""
        formatString += (month.count > 0) ? month + "-" : ""
        formatString += (year.count >  0) ? year + " ": ""
        formatString += (time.count > 0) ? time + "" : ""
        
        var valueString = ""
        
        valueString += (day.count > 0) ? self.day + "-" : ""
        valueString += (month.count > 0) ? self.month + "-" : ""
        valueString += (year.count >  0) ? self.year + " ": ""
        //        valueString += (time.count > 0) ? self.time + "-" : ""
        
        if time.count > 0 {
            if self.time.contains("AM") {
                let timeString = String(self.time[self.time.startIndex..<self.time.index(of: "A")!])
                valueString += timeString

            } else if self.time.contains("PM") {
                var timeString = String(self.time[self.time.startIndex..<self.time.index(of: "P")!])
                if !timeString.isEmpty {
                    if !timeString.contains(":") {
                        timeString = String(Int(timeString)! + 12)
                    } else {
                        let compoenents = timeString.split(separator: ":")
                        timeString = String(Int(compoenents[0])! + 12)
                        timeString += ":" + compoenents[1]
                    }
                }
                valueString += timeString
            } else {
                valueString += self.time
            }
        }
        
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString //Your date format
        print(dateFormatter.timeZone)
        print(formatString, valueString)
        guard let date = dateFormatter.date(from: valueString) else {
            return Date()
        }
        return date
    }
    
}
