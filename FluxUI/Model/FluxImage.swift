/*
 * FluxImage.swift
 * FluxUI
 *
 * Created by François Lamboley on 01/08/2020.
 */

import Foundation



/** This is actually a FluxWorkload, but with less properties… */
struct FluxImage : Decodable, Identifiable {
	
	var id: String
	var containers: [FluxContainer]
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: Self.CodingKeys)
		id = try container.decode(String.self, forKey: .ID)
		containers = try container.decode([FluxContainer].self, forKey: .Containers)
	}
	
	private enum CodingKeys : String, CodingKey {
		case ID
		case Containers
	}
	
}
