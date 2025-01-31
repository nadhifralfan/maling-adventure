//
//  LevelSelectScene.swift
//  MalingAdventure
//
//  Created by Nadhif Rahman Alfan on 07/06/24.
//

import Foundation
import SpriteKit

func parseJSONToDictionary(from jsonData: Data) -> [String: Any]? {
    do {
        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
        return json
    } catch {
        print("Error decoding JSON: \(error)")
        return nil
    }
}

func insertDataToScene(scene: MenuScene, debugMode: Bool = false) {
    if let path = Bundle.main.path(forResource: "dataBase", ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            if let levelsDict = parseJSONToDictionary(from: data) {
                var levels: [String:Level] = [:]
                
                for (key, value) in levelsDict {
                    var level = Level()
                    level.level = key
                    if let dict = value as? [String: Any] {
                        if let isUnlocked = dict["isUnlocked"] as? Bool {
                            level.isUnlocked = isUnlocked
                        }
                        if let storiesArray = dict["stories"] as? [[String: Any]] {
                            var stories: [Story] = []
                            for storyDict in storiesArray {
                                if let imageName = storyDict["imageName"] as? String,
                                   let descriptionArray = storyDict["description"] as? [String] {
                                    let story = Story()
                                    story.image = SKSpriteNode(imageNamed: imageName)
                                    story.desc = descriptionArray
                                    stories.append(story)
                                }
                            }
                            level.stories = stories
                        }
                        if let sectionsArray = dict["section"] as? [[String: Any]] {
                            for sectionDict in sectionsArray {
                                for (_, value) in sectionDict {
                                    if let sectionData = value as? [String: Any] {
                                        let section = Section()
                                        if let transitionNextData = sectionData["transitionNext"] as? String {
                                            section.transitionNext = transitionNextData
                                        }
                                        if let transitionBackData = sectionData["transitionBack"] as? String {
                                            section.transitionBack = transitionBackData
                                        }
                                        if let background = sectionData["background"] as? String {
                                            section.background = SKSpriteNode(imageNamed: background)
                                        }
                                        if let platforms = sectionData["platforms"] as? [[String: Any]] {
                                            for platform in platforms {
                                                section.platforms.append(platform)
                                            }
                                        }
                                        if let doorEntryData = sectionData["doorEntry"] as? [String: Any] {
                                            let doorEntry = Door()
                                            if let doorTypeString = doorEntryData["doorType"] as? String,
                                               let doorType = DoorTypeEnum(from: doorTypeString) {
                                                doorEntry.doorType = createDoorType(for: doorType)
                                            }
                                            if let x = doorEntryData["x"] as? CGFloat,
                                               let y = doorEntryData["y"] as? CGFloat {
                                                doorEntry.doorPosition = CGPoint(x: x, y: y)
                                            }
                                            section.doorEntry = doorEntry
                                        }
                                        if let spawnEntry = sectionData["spawnEntry"] as? [String: Any] {
                                            if let x = spawnEntry["x"] as? CGFloat,
                                               let y = spawnEntry["y"] as? CGFloat {
                                                let spawnPoint = CGPoint(x: x, y: y)
                                                section.spawnEntry = spawnPoint
                                            }
                                        }
                                        if let spawnExit = sectionData["spawnExit"] as? [String: Any] {
                                            if let x = spawnExit["x"] as? CGFloat,
                                               let y = spawnExit["y"] as? CGFloat {
                                                let spawnPoint = CGPoint(x: x, y: y)
                                                section.spawnExit = spawnPoint
                                            }
                                        }
                                        if let doorExitData = sectionData["doorExit"] as? [String: Any] {
                                            let doorExit = Door()
                                            if let doorTypeString = doorExitData["doorType"] as? String,
                                               let doorType = DoorTypeEnum(from: doorTypeString) {
                                                doorExit.doorType = createDoorType(for: doorType)
                                            }
                                            if let x = doorExitData["x"] as? CGFloat,
                                               let y = doorExitData["y"] as? CGFloat {
                                                doorExit.doorPosition = CGPoint(x: x, y: y)
                                            }
                                            section.doorExit = doorExit
                                        }
                                        if let finalDoorData = sectionData["finalDoor"] as? [String: Any] {
                                            let finalDoor = Door()
                                            if let doorTypeString = finalDoorData["doorType"] as? String,
                                               let doorType = DoorTypeEnum(from: doorTypeString) {
                                                finalDoor.doorType = createDoorType(for: doorType)
                                            }
                                            if let x = finalDoorData["x"] as? CGFloat,
                                               let y = finalDoorData["y"] as? CGFloat {
                                                finalDoor.doorPosition = CGPoint(x: x, y: y)
                                            }
                                            if let width = finalDoorData["width"] as? CGFloat,
                                               let height = finalDoorData["height"] as? CGFloat {
                                                finalDoor.doorSize = CGSize(width: width, height: height)
                                            }
                                            section.finalDoor = finalDoor
                                        }
                                        if let coins = sectionData["coins"] as? [[String: Any]] {
                                            for coin in coins {
                                                if let x = coin["x"] as? CGFloat,
                                                   let y = coin["y"] as? CGFloat,
                                                   let type = coin["type"] as? String {
                                                    
                                                    let coinSection = Coin(position: CGPoint(x: x, y: y), type: type)
                                                    section.coins.append(coinSection)
                                                }
                                            }
                                        }
                                        if let hazzard = sectionData["hazzards"] as? [[String: Any]] {
                                            for hazzardData in hazzard {
                                                let hazzard = Hazzard()
                                                if let hazzardTypeString = hazzardData["hazzardType"] as? String
                                                //,let hazzardType = HazzardTypeEnum(from: hazzardTypeString)
                                                {
                                                    hazzard.hazzardType = hazzardTypeString
                                                }
                                                if let xSpawn = hazzardData["xSpawn"] as? CGFloat,
                                                   let ySpawn = hazzardData["ySpawn"] as? CGFloat {
                                                    hazzard.startPosition = CGPoint(x: xSpawn, y: ySpawn)
                                                }
                                                if let xEnd = hazzardData["xEnd"] as? CGFloat,
                                                    let yEnd = hazzardData["yEnd"] as? CGFloat {
                                                     hazzard.endPosition = CGPoint(x: xEnd, y: yEnd)
                                                    }
                                                if let width = hazzardData["width"] as? Double,
                                                   let height = hazzardData["height"] as? Double{
                                                    hazzard.size = CGSize(width: width, height: height)
                                                    
                                                }
//                                                print(hazzard.size)
                                                section.hazzards.append(hazzard)
                                            }
                                        }
                                        level.sections.append(section)
                                    }
                                }
                            }
                        }
                    }
                    levels[key] = level
                }
                
                scene.levels = levels
                
                if debugMode {
                    debugLevelData(levels: levels)
                }

            }
        } catch {
            print("Error reading JSON file: \(error)")
        }
    }
}


// Debugging function to print out the data from the JSON file
func debugLevelData(levels: [String:Level]){
    for (_,level) in levels {
        print("---STORIES---")
        for story in level.stories {
            print("---IMAGE---")
            print(story.image)
            print("---DESCRIPTION---")
            print(story.desc)
        }
        print("---Unlocked---")
        print(level.isUnlocked)
        print("---SECTIONS---")
        for section in level.sections {
            print("---BACKGROUND---")
            print(section.background.description)
            print("---PLATFORMS---")
            print(section.platforms)
            print("---SPAWN---")
            print(section.spawnEntry)
            print(section.spawnExit)
            print("---DOOR ENTRY---")
            print(section.doorEntry.doorPosition.debugDescription)
            print(section.doorEntry.doorType.doorImageName)
            print("---DOOR EXIT---")
            print(section.doorExit.doorPosition.debugDescription)
            print(section.doorExit.doorType.doorImageName)
            print("---FINAL DOOR---")
            print(section.doorExit.doorPosition.debugDescription)
            print(section.doorExit.doorType.doorImageName)
            print("---COINS---")
            print(section.coins.description)
            print("---HAZZARDS---")
            for hazzard in section.hazzards {
                print("---HAZZARD TYPE---")
                print(hazzard.hazzardType)
                print("---START POSITION---")
                print(hazzard.startPosition)
                print("---END POSITION---")
                print(hazzard.endPosition)
                print("---SIZE---")
                print(hazzard.size)
            }
        }
    }
}
