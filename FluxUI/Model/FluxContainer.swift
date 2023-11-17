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



struct FluxContainer : Decodable {
	
	struct ContainerDescription : Decodable, Identifiable, Hashable {
		
		var id: String
		var digest: String?
		var imageID: String?
		var labels: [String: String]?
		var createdAt: Date?
		var lastFetched: Date?
		
		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: Self.CodingKeys.self)
			id = try container.decode(String.self, forKey: .ID)
			digest = try container.decodeIfPresent(String.self, forKey: .Digest)
			imageID = try container.decodeIfPresent(String.self, forKey: .ImageID)
			labels = try container.decodeIfPresent([String: String].self, forKey: .Labels)
			
			let dateFormatter = ISO8601DateFormatter()
			dateFormatter.formatOptions = .withFractionalSeconds
			if let dstr = try container.decodeIfPresent(String.self, forKey: .CreatedAt) {
				guard let d = dateFormatter.date(from: dstr) else {
					throw DecodingError.dataCorruptedError(forKey: .CreatedAt, in: container, debugDescription: "Malformed date")
				}
				createdAt = d
			} else {
				createdAt = nil
			}
			
			if let dstr = try container.decodeIfPresent(String.self, forKey: .LastFetched) {
				guard let d = dateFormatter.date(from: dstr) else {
					throw DecodingError.dataCorruptedError(forKey: .LastFetched, in: container, debugDescription: "Malformed date")
				}
				lastFetched = d
			} else {
				lastFetched = nil
			}
		}
		
		private enum CodingKeys : String, CodingKey {
			case ID
			case Digest
			case ImageID
			case Labels
			case CreatedAt
			case LastFetched
		}
		
	}
	
	var name: String
	
	var current: ContainerDescription
	var latestFiltered: ContainerDescription
	var available: [ContainerDescription]?
	
	var availableImagesCount: Int
	var filteredImagesCount: Int
	var newAvailableImagesCount: Int
	var newFilteredImagesCount: Int
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: Self.CodingKeys.self)
		name = try container.decode(String.self, forKey: .Name)
		
		current = try container.decode(ContainerDescription.self, forKey: .Current)
		latestFiltered = try container.decode(ContainerDescription.self, forKey: .LatestFiltered)
		available = try container.decodeIfPresent([ContainerDescription].self, forKey: .Available) ?? []
		
		availableImagesCount = try container.decodeIfPresent(Int.self, forKey: .AvailableImagesCount) ?? 0
		filteredImagesCount = try container.decodeIfPresent(Int.self, forKey: .FilteredImagesCount) ?? 0
		newAvailableImagesCount = try container.decodeIfPresent(Int.self, forKey: .NewAvailableImagesCount) ?? 0
		newFilteredImagesCount = try container.decodeIfPresent(Int.self, forKey: .NewFilteredImagesCount) ?? 0
	}
	
	private enum CodingKeys : String, CodingKey {
		case Name
		
		case Current
		case LatestFiltered
		case Available
		
		case AvailableImagesCount
		case FilteredImagesCount
		case NewAvailableImagesCount
		case NewFilteredImagesCount
	}
	
}
