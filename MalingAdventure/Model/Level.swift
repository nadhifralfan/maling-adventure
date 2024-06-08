//
//  Level.swift
//  MalingAdventure
//
//  Created by Nadhif Rahman Alfan on 07/06/24.
//

import SpriteKit

struct Level {
    var level : String = "0"
    var stories : [Story] = []
    var isUnlocked : Bool = false
    var sections : [Section] = []
}
