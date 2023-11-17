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



struct FluxWorkload : Decodable, Identifiable {
	
	enum Status : String, Decodable {
		
		case unknown
		case error
		case ready
		case updating
		case started
		
	}
	
	enum ReadOnlyStatus : String, Decodable {
		
		case notReadonly = ""
		
		case readOnlyMode = "ReadOnlyMode"
		
		case noRepo = "NoRepo"
		case notInRepo = "NotInRepo"
		
		case notReady = "NotReady"
		
		case system = "System"
		
	}
	
	struct Rollout : Decodable {
		
		var desired: Int
		var updated: Int
		var ready: Int
		var available: Int
		var outdated: Int
		var messages: [String]? /* Don’t know the type actually… */
		
		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: Self.CodingKeys.self)
			
			desired = try container.decode(Int.self, forKey: .Desired)
			updated = try container.decode(Int.self, forKey: .Updated)
			ready = try container.decode(Int.self, forKey: .Ready)
			available = try container.decode(Int.self, forKey: .Available)
			outdated = try container.decode(Int.self, forKey: .Outdated)
			messages = try container.decode([String]?.self, forKey: .Messages)
		}
		
		private enum CodingKeys : String, CodingKey {
			case Desired
			case Updated
			case Ready
			case Available
			case Outdated
			case Messages
		}
		
	}
	
	var id: String
	var readOnly: ReadOnlyStatus
	var isReadOnly: Bool {return readOnly != .notReadonly}
	
	var status: Status
	var rollout: Rollout
	var syncError: String
	var antecedent: String
	var labels: [String: String]?
	
	var automated: Bool
	var locked: Bool
	var ignore: Bool
	
	var containers: [FluxContainer]
	
//	var policies: Any
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: Self.CodingKeys.self)
		
		id = try container.decode(String.self, forKey: .ID)
		readOnly = try container.decode(ReadOnlyStatus.self, forKey: .ReadOnly)
		
		status = try container.decode(Status.self, forKey: .Status)
		rollout = try container.decode(Rollout.self, forKey: .Rollout)
		syncError = try container.decode(String.self, forKey: .SyncError)
		antecedent = try container.decode(String.self, forKey: .Antecedent)
		labels = try container.decodeIfPresent([String: String].self, forKey: .Labels)
		
		automated = try container.decode(Bool.self, forKey: .Automated)
		locked = try container.decode(Bool.self, forKey: .Locked)
		ignore = try container.decode(Bool.self, forKey: .Ignore)
		
		containers = try container.decode([FluxContainer].self, forKey: .Containers)
	}
	
	private enum CodingKeys : String, CodingKey {
		case ID
		case ReadOnly
		case Status
		case Rollout
		case SyncError
		case Antecedent
		case Labels
		case Automated
		case Locked
		case Ignore
		case Containers
//		case Policies
	}
	
}
