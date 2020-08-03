/*
 * FluxSettings.swift
 * FluxUI
 *
 * Created by François Lamboley on 03/08/2020.
 */

import Foundation



struct FluxSettings {
	
	typealias UserDefaultRepresentation = [String: String]
	
	var url: URL
	var namespace: String
	
	init(url: URL, namespace: String) {
		self.url = url
		self.namespace = namespace
	}
	
	init?(userDefaultRepresentation: UserDefaultRepresentation) {
		guard
			let s = userDefaultRepresentation["url"],
			let u = URL(string: s),
			let n = userDefaultRepresentation["ns"]
		else {
			return nil
		}
		url = u
		namespace = n
	}
	
	var userDefaultRepresentation: UserDefaultRepresentation {
		return [
			"url": url.absoluteString,
			"ns": namespace
		]
	}
	
}
