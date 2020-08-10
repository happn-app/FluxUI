/*
 * ActivityIndicatorView.swift
 * FluxUI
 *
 * Created by François Lamboley on 05/08/2020.
 */

import Cocoa
import Foundation
import SwiftUI



@available(macOS, deprecated: 11)
struct ActivityIndicatorView : NSViewRepresentable {
	
	typealias NSView = NSProgressIndicator
	
	var isAnimating: Bool
	
	func makeNSView(context: NSViewRepresentableContext<Self>) -> NSView {
		NSView()
	}
	
	func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<Self>) {
		isAnimating ? nsView.startAnimation(nil) : nsView.stopAnimation(nil)
	}
	
}
