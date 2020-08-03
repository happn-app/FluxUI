/*
 * FluxWorkload.swift
 * FluxUI
 *
 * Created by François Lamboley on 01/08/2020.
 */

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
			let container = try decoder.container(keyedBy: Self.CodingKeys)
			
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
	var labels: [String: String]
	
	var automated: Bool
	var locked: Bool
	var ignore: Bool
	
	var containers: [FluxContainer]
	
//	var policies: Any
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: Self.CodingKeys)
		
		id = try container.decode(String.self, forKey: .ID)
		readOnly = try container.decode(ReadOnlyStatus.self, forKey: .ReadOnly)
		
		status = try container.decode(Status.self, forKey: .Status)
		rollout = try container.decode(Rollout.self, forKey: .Rollout)
		syncError = try container.decode(String.self, forKey: .SyncError)
		antecedent = try container.decode(String.self, forKey: .Antecedent)
		labels = try container.decode([String: String].self, forKey: .Labels)
		
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
