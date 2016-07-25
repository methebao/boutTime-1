//
//  ViewController.swift
//  boutTime
//
//  Created by Alex Millius on 22.07.16.
//  Copyright © 2016 TumTum. All rights reserved.
//

import Foundation
import UIKit
import GameKit

// MARK: Protocol
protocol RoundType {
    var event1:Event { get }
    var event2:Event { get }
    var event3:Event { get }
    var event4:Event { get }
    var infosLink:String { get }
    var currentCorrectOrder:[Event] { get }
    init (event1:Event, event2:Event, event3: Event, event4: Event, infosLink:String)
    static func mooveEvent(inout events:[Event],buttonTag:Int)
    func checkIfCorrectOrder(proposition proposition:[Event], correct:[Event]) -> Bool
}

protocol BoutTimeGame {
    static func getRandomRound(lastIndexes:[Int], rounds:[RoundType]) -> (round:Round,randomIndex:Int)
}

protocol EventType {
    var position:PositionEvents { get }
    var title:String { get }
    init (position:PositionEvents, title:String)
}

// MARK: Error Type

enum EventsError: ErrorType {
    case InvalidResource(String)
    case ConversionError(String)
    case InvalidKey(String)
}

// MARK: objects

enum PositionEvents {
    case First
    case Second
    case Third
    case Fourth
}

struct Event:EventType {
    let position: PositionEvents
    let title: String
    
    init (position:PositionEvents = PositionEvents.First, title:String = "empty"){
        self.position = position
        self.title = title
    }
}

class Round:RoundType {
    var event1: Event
    var event2: Event
    var event3: Event
    var event4: Event
    var infosLink: String
    var currentCorrectOrder: [Event]
    required init (event1:Event = Event(), event2:Event = Event(), event3: Event = Event(), event4: Event = Event(), infosLink:String = ""){
        self.event1 = event1
        self.event2 = event2
        self.event3 = event3
        self.event4 = event4
        self.infosLink = infosLink
        self.currentCorrectOrder = [self.event1,self.event2,self.event3,self.event4]
    }
    
    func getEventsRandomized(events:[Event]) -> [Event] {
        var tempEvents = events
        // Randomize the events
        repeat {
            for index in 0..<tempEvents.count {
                
                // Current event
                let currentEvent = tempEvents[index]
                
                // Randomly choose another index
                let randomIndex = GKRandomSource.sharedRandom().nextIntWithUpperBound(tempEvents.count)
                
                // Swap events at the two indexes
                tempEvents[index] = tempEvents[randomIndex]
                tempEvents[randomIndex] = currentEvent
            }
        } while checkIfCorrectOrder(proposition: tempEvents, correct: events)
        return tempEvents
    }
    
    class func mooveEvent(inout events:[Event],buttonTag:Int) {
        //Arrow buttons are tagged from top to bottom; from 1 to 6
        // 1-3-5 are down button
        // 2-4-6 are up button
        func swapEvent(index1:Int,_ index2:Int){
            let currentEvent = events[index1]
            events[index1] = events[index2]
            events[index2] = currentEvent
        }
        switch buttonTag {
        case 1: swapEvent(0, 1)
        case 2: swapEvent(0, 1)
        case 3: swapEvent(1, 2)
        case 4: swapEvent(1, 2)
        case 5: swapEvent(2, 3)
        case 6: swapEvent(2, 3)
        default: break
        }
    }
    
    
    func checkIfCorrectOrder(proposition proposition:[Event], correct:[Event]) -> Bool {
        for index in 0..<proposition.count {
            //TODO: delete print
            print(proposition[index].position)
            print(correct[index].position)
            if proposition[index].position != correct[index].position {
                return false
            }
        }
        return true
    }
}

class GameControl: BoutTimeGame {
    
    class func getRandomRound(lastIndexes:[Int], rounds:[RoundType]) -> (round:Round,randomIndex:Int) {
        var currentIndex = Int()
        
        //While the currentIndex as already been used, generate a new random index
        repeat {
            currentIndex = GKRandomSource.sharedRandom().nextIntWithUpperBound(rounds.count)
        }while lastIndexes.contains(currentIndex)
        
        if rounds[currentIndex] is Round {
            let round = rounds[currentIndex] as! Round
            return (round,currentIndex)
        } else {
            return (Round(),currentIndex)
        }
    }
}


//MARK: Converter

class PlistConverter {
    class func dictionaryFromFile(resource: String, ofType type: String) throws -> [String : AnyObject] {
        
        guard let path = NSBundle.mainBundle().pathForResource(resource, ofType: type) else {
            throw EventsError.InvalidResource("Invalid Ressource")
        }
        
        guard let Dictionary = NSDictionary(contentsOfFile: path), let castDictionary = Dictionary as? [String: AnyObject] else {
            throw EventsError.ConversionError("Conversion Error")
        }
        
        return castDictionary
    }
}

class EventUnarchiver {
    class func eventInventoryFromDictionary(dictionary: [String: AnyObject]) throws -> [RoundType] {
        
        var rounds = [RoundType]()
        
        for (_, value) in dictionary {
            if let eventDict = value as? [String: String], let event1 = eventDict["event1"], let event2 = eventDict["event2"], let event3 = eventDict["event3"], let event4 = eventDict["event4"], let infosLink = eventDict["infos"] {
                
                let firstEvent = Event(position: .First, title: event1)
                let secondEvent = Event(position: .Second, title: event2)
                let thirdEvent = Event(position: .Third, title: event3)
                let fourthEvent = Event(position: .Fourth, title: event4)
                
                let round = Round(event1: firstEvent, event2: secondEvent, event3: thirdEvent, event4: fourthEvent, infosLink: infosLink)
                
                rounds.append(round)
            } else {
                throw EventsError.InvalidKey("Invalid Key")
            }
        }
        
        return rounds
    }
}

















