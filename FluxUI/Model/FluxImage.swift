/*
Copyright 2020 happn

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

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
