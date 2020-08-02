/*
 * FluxWorkloadView.swift
 * FluxUI
 *
 * Created by François Lamboley on 01/08/2020.
 */

import SwiftUI



struct FluxWorkloadView : View {
	
	var fluxWorkload: FluxWorkload
	
	var body: some View {
		VStack{
			HStack{
				Text(fluxWorkload.id).font(.title).padding()
				Spacer()
			}
			Spacer()
		}
	}
	
}


/* *************** */

struct FluxWorkloadView_Previews : PreviewProvider {
	
	class Obj : NSObject {}
	static let workloads = try! JSONDecoder().decode([FluxWorkload].self, from: Data(contentsOf: Bundle(for: Obj.self).url(forResource: "workloads", withExtension: "json")!))
	
	static var previews: some View {
		FluxWorkloadView(fluxWorkload: workloads[0])
	}
	
}
