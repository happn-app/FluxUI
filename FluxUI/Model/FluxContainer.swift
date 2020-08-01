/*
 * FluxContainer.swift
 * FluxUI
 *
 * Created by François Lamboley on 01/08/2020.
 */

import Foundation



struct FluxContainer : Decodable {
	
	var name: String
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: Self.CodingKeys)
		name = try container.decode(String.self, forKey: .Name)
	}
	
	private enum CodingKeys : String, CodingKey {
		case Name
	}
	
}
