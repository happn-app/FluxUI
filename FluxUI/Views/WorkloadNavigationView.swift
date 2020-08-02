/*
 * WorkloadNavigationView.swift
 * FluxUI
 *
 * Created by François Lamboley on 02/08/2020.
 */

import SwiftUI



struct WorkloadNavigationView : View {
	
	var fluxWorkloads: [FluxWorkload]
	
	var body: some View {
		if !fluxWorkloads.isEmpty {withWorkloadsView}
		else                      {noWorkloadsView}
	}
	
	var noWorkloadsView: some View {
		VStack{
			Spacer()
			HStack{
				Spacer()
				Text("No workloads found.").font(.title).bold()
				Spacer()
			}
			Spacer()
		}
	}
	
	var withWorkloadsView: some View {
		NavigationView{
			List{
				Section(header: Text("Workloads")){
					ForEach(fluxWorkloads){ workload in
						NavigationLink(destination: FluxWorkloadView(fluxWorkload: workload)){
							FluxWorkloadRow(workload: workload)
						}
					}
				}
			}
			.listStyle(SidebarListStyle())
		}.navigationViewStyle(DoubleColumnNavigationViewStyle())
	}
	
}


/* *************** */

struct WorkloadNavigationView_Previews : PreviewProvider {
	
	class Obj : NSObject {}
	static let workloads = try! JSONDecoder().decode([FluxWorkload].self, from: Data(contentsOf: Bundle(for: Obj.self).url(forResource: "workloads", withExtension: "json")!))
	
	static var previews: some View {
		WorkloadNavigationView(fluxWorkloads: workloads)
	}
	
}
