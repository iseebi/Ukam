//
//  UkamWindowModels.swift
//  Ukam
//
//  Created by Nobuhiro Ito on 2024/08/17.
//

import Foundation

protocol UkamWindowLike {
    typealias ID = UInt32
    
    /// ウィンドウID(CGWindowID)
    var id: UkamWindowLike.ID { get }
    /// ウィンドウID(SkyLightのWindowID)
    var skyLightID: UkamWindowLike.ID { get }
    /// ウィンドウを持っているアプリのPID
    var ownerPID: Int { get }
    /// ウィンドウタイトル
    var name: String { get }
    /// ウィンドウを持っているアプリ名
    var ownerName: String { get }
    /// ウィンドウが表示状態にあるかを判定する
    var isVisible: Bool { get }
    /// 現在モニタ上に表示されているかを判定する
    var isOnScreen: Bool { get }
    var bounds: NSRect { get }
}

struct UkamWindow: UkamWindowLike {
    let skyLightWindow: SLSWindowLike
    let cgWindow: CGWindowLike
    let monitorID: String
    let spaceID: UInt64
    
    var id: UkamWindowLike.ID { UInt32(cgWindow.number ?? 0) }
    var skyLightID: UkamWindowLike.ID { skyLightWindow.id }
    var ownerPID: Int { cgWindow.ownerPID ?? 0 }
    var name: String { cgWindow.name ?? "" }
    var ownerName: String { cgWindow.ownerName ?? "" }
    var isVisible: Bool { cgWindow.isVisible }
    var isOnScreen: Bool { cgWindow.isOnScreen }
    var bounds: NSRect { cgWindow.bounds }
}
