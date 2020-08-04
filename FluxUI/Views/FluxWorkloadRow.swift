/*
 * FluxWorkloadRow.swift
 * FluxUI
 *
 * Created by François Lamboley on 01/08/2020.
 */

import SwiftUI

import XibLoc



struct FluxWorkloadRow : View {
	
	var workload: FluxWorkload
	
	var body: some View {
		HStack{
			Text(workload.id.split(separator: "/").last!)
				.bold()
				.truncationMode(.head)
			if workload.isReadOnly {
				Text("🔐")
			}
			Text("(\(workload.rollout.available)/\(workload.rollout.desired))")
		}
	}
	
}


/* *************** */

struct FluxWorkloadRow_Previews : PreviewProvider {
	
	class Obj : NSObject {}
	static let workloads = try! JSONDecoder().decode([FluxWorkload].self, from: Data(contentsOf: Bundle(for: Obj.self).url(forResource: "workloads", withExtension: "json")!))
	
	static var previews: some View {
		Group{
			FluxWorkloadRow(workload: workloads[0])
			FluxWorkloadRow(workload: workloads[1])
			FluxWorkloadRow(workload: workloads[2])
		}
		.previewLayout(.fixed(width: 500, height: 50))
	}
	
}
