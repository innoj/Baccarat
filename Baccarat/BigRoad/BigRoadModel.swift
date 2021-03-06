//
//  BigRoadModel.swift
//  Baccarat
//
//  Created by Jonni Akesson on 2022-03-01.
//

import Foundation

class BigRoadModel {
    
    
    private var currentSection = 0
    private var currentIndex = 0
    private var prevHand = ""
    private var sectionIndexBeforeDragon = 0
    private var dragonIndex = 0
    private var didStartDragon = false
    
    let model: ModelController
    var gridSections: [GridSection] = []
    
    
    init(model: ModelController) {
        self.model = model
    }
    
    func addPlayer() {
        model.addPlayer()
    }
    
    func addBanker() {
        model.addBanker()
    }
    
    func addTie() {
        model.addTie()
    }
    
    func reset() {
        currentSection = 0
        currentIndex = 0
        prevHand = ""
        sectionIndexBeforeDragon = 0
        dragonIndex = 0
        didStartDragon = false
        //deleteIndex = [:]
        deleteIDXs = []
    }
    
    func createNewShoe() {
        reset()
        createGrid()
    }
    
    func createGrid() {
        var sectionHands: [GridSection] = []
        for _ in 0..<70 {
            var hands = [GridItem]()
            for _ in 0..<6 {
                hands.append(GridItem())
            }
            let sections = GridSection(hands: hands)
            sectionHands.append(sections)
        }
        self.gridSections = []
        self.gridSections = sectionHands
    }
    
    private var deleteIDXs = [IndexPath]()
    //private var deleteIndex = [String : IndexPath]()
    
    
    func delete() {
        let idx = deleteIDXs.removeLast()
        let gridItemToDelete = gridSections[idx.section].hands.remove(at: idx.item)
        //let uuidStr = gridItemToDelete.hand?.uuid.uuidString
        //deleteIndex[uuidStr!] = nil
        gridSections[idx.section].hands.insert(GridItem(hand: nil), at: idx.item)
        model.deleteHand()
       
     
    }
    
    private func updateDeleteIndex(sectionIndex: Int, itemIndex: Int, hand: Hand) {
        let idx = IndexPath(item: itemIndex, section: sectionIndex)
        //deleteIndex[hand.uuid.uuidString] = idx
        deleteIDXs.append(idx)
    }
    
    private func updateHand(sectionIndex: Int, itemIndex: Int, hand: Hand) {
        gridSections[sectionIndex].hands.remove(at: itemIndex)
        let gridItem = GridItem(hand: hand)
        gridSections[sectionIndex].hands.insert(gridItem, at: itemIndex)
    }
    
    func add(hand: Hand) {
        //First hand
        if prevHand == "" {
            if hand.title == "T" {
                updateHand(sectionIndex: currentSection, itemIndex: currentIndex, hand: hand)
                
                updateDeleteIndex(sectionIndex: currentSection, itemIndex: currentIndex, hand: hand)
                
                prevHand = "T"
                
            } else if hand.title == "P" {
                updateHand(sectionIndex: currentSection, itemIndex: currentIndex, hand: hand)
                
                updateDeleteIndex(sectionIndex: currentSection, itemIndex: currentIndex, hand: hand)
                
                currentIndex += 1
                
                prevHand = "P"
                
            }  else if hand.title == "B" {
                updateHand(sectionIndex: currentSection, itemIndex: currentIndex, hand: hand)
                
                updateDeleteIndex(sectionIndex: currentSection, itemIndex: currentIndex, hand: hand)
                
                currentIndex += 1
                
                prevHand = "B"
                
            } else {
                print("EMPTY")
            }
            return
        }
        
        //Scond hand, if T
        if prevHand == "T" {
            if hand.title == "P" {
                hand.title = "PT"
                //Save
                updateHand(sectionIndex: currentSection, itemIndex: currentIndex, hand: hand)
                
                updateDeleteIndex(sectionIndex: currentSection, itemIndex: currentIndex, hand: hand)
                
                currentIndex += 1
                
                prevHand = "P"
                
            }
            if hand.title == "B" {
                updateHand(sectionIndex: currentSection, itemIndex: currentIndex, hand: hand)
                hand.title = "BT"
                //Save
                
                updateDeleteIndex(sectionIndex: currentSection, itemIndex: currentIndex, hand: hand)
                
                currentIndex += 1
                
                prevHand = "B"
                
            }
            return
        }
        
        if !didStartDragon {
            sectionIndexBeforeDragon = currentSection // x
            dragonIndex = currentIndex - 1  // y
        }
        
        if hand.title == "T" || hand.title == "PT" || hand.title == "BT"{
            if prevHand == "P"  || prevHand == "PT"{
                hand.title = "PT"
                updateHand(sectionIndex: currentSection, itemIndex: currentIndex - 1, hand: hand)
                
                
                //Save
                
                updateDeleteIndex(sectionIndex: currentSection, itemIndex: currentIndex - 1, hand: hand)
                
                prevHand = "P"
                
                
            } else if prevHand == "B" {
                updateHand(sectionIndex: currentSection, itemIndex: currentIndex - 1, hand: hand)
                hand.title = "BT"
                
                updateDeleteIndex(sectionIndex: currentSection, itemIndex: currentIndex - 1, hand: hand)
                
                prevHand = "B"
                
                
            } else {
                
            }
        }
        
        if hand.title == "P" {
            if prevHand == "P" {
                if didStartDragon == false && currentIndex < 6 && gridSections[currentSection].hands[currentIndex].hand == nil { // If true, dragon tail will start.
                    
                    updateHand(sectionIndex: currentSection, itemIndex: currentIndex, hand: hand)
                    
                    updateDeleteIndex(sectionIndex: currentSection, itemIndex: currentIndex, hand: hand)
                    
                    currentIndex += 1
                    
                } else {
                    currentSection += 1 //shift sectionIndex, not the same hand
                    
                    updateHand(sectionIndex: currentSection, itemIndex: dragonIndex, hand: hand)
                    
                    updateDeleteIndex(sectionIndex: currentSection, itemIndex: dragonIndex, hand: hand)
                    
                    
                    didStartDragon = true
                }
            } else {
                if didStartDragon {
                    //dragonIndex == 1, test if we are on the first row after mutliple dragon tails.
                    currentSection = dragonIndex == 0 ? (currentSection + 1) : (sectionIndexBeforeDragon + 1)
                    
                    //Reset dragon
                    didStartDragon = false
                    sectionIndexBeforeDragon = 0
                    dragonIndex = 0
                    
                    updateHand(sectionIndex: currentSection, itemIndex: 0, hand: hand)
                    
                    updateDeleteIndex(sectionIndex: currentSection, itemIndex: 0, hand: hand)
                    
                    currentIndex = 1
                    
                    
                } else {
                    currentSection += 1
                    
                    updateHand(sectionIndex: currentSection, itemIndex: 0, hand: hand)
                    
                    updateDeleteIndex(sectionIndex: currentSection, itemIndex: 0, hand: hand)
                    
                    currentIndex = 1
                    
                    
                }
            }
            prevHand = "P"
        }
        
        
        if hand.title == "B" {
            if prevHand == "B" {
                if didStartDragon == false && currentIndex < 6 && gridSections[currentSection].hands[currentIndex].hand == nil {
                    
                    updateHand(sectionIndex: currentSection, itemIndex: currentIndex, hand: hand)
                    
                    updateDeleteIndex(sectionIndex: currentSection, itemIndex: currentIndex, hand: hand)
                    
                    currentIndex += 1
                    
                    
                    
                } else {
                    currentSection += 1 //shift section
                    
                    updateHand(sectionIndex: currentSection, itemIndex: dragonIndex, hand: hand)
                    
                    updateDeleteIndex(sectionIndex: currentSection, itemIndex: dragonIndex, hand: hand)
                    
                    
                    didStartDragon = true
                }
            } else {
                if didStartDragon {
                    currentSection = dragonIndex == 0 ? (currentSection + 1) : (sectionIndexBeforeDragon + 1)
                    
                    //Reset dragon
                    didStartDragon = false
                    sectionIndexBeforeDragon = 0
                    dragonIndex = 0
                    
                    updateHand(sectionIndex: currentSection, itemIndex: 0, hand: hand)
                    
                    updateDeleteIndex(sectionIndex: currentSection, itemIndex: 0, hand: hand)
                    
                    currentIndex = 1
                    
                    
                    
                } else {
                    currentSection += 1
                    
                    updateHand(sectionIndex: currentSection, itemIndex: 0, hand: hand)
                    
                    updateDeleteIndex(sectionIndex: currentSection, itemIndex: 0, hand: hand)
                    
                    currentIndex = 1
                    
                    
                }
            }
            prevHand = "B"
        }
    }
}
