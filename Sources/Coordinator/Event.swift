//
//  Event.swift
//
//
//  Created by Lucas Rebelato on 14/12/20.
//

/// Something that happened on a screen and that a coordinator may react to,
/// such as a button tap that should lead somewhere else.
///
/// Screens never navigate on their own: they send events, and the first
/// coordinator in the chain that handles the event decides what happens.
public protocol Event: Sendable {}
