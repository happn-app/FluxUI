/*
 * FluxWorkload.swift
 * FluxUI
 *
 * Created by François Lamboley on 01/08/2020.
 */

import Foundation



struct FluxWorkload : Decodable {
	
	enum Status : String, Codable {
		
		case ready
		
	}
	
	struct Rollout : Codable {
		
		var desired: Int
		var updated: Int
		var ready: Int
		var available: Int
		var outdated: Int
		var messages: [String] /* Don’t know the type actually… */
		
	}
	
	var id: String
	var readOnly: String
	var isReadOnly: Bool {return !readOnly.isEmpty}
	
	var status: Status
	var rollout: Rollout
	var syncError: String
	var antecedent: String
	var labels: [String: String]
	
	var automated: Bool
	var locked: Bool
	var ignore: Bool
	
	var containers: [FluxContainer]
	
//	var policies: Any
	
}
