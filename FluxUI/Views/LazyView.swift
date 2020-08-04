/*
 * LazyView.swift
 * FluxUI
 *
 * Created by François Lamboley on 04/08/2020.
 */

import Foundation
import SwiftUI



struct LazyView<Content: View>: View {
	
	let build: () -> Content
	
	init(_ build: @autoclosure @escaping () -> Content) {
		self.build = build
	}
	
	var body: Content {
		build()
	}
	
}
