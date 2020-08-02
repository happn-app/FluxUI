/*
 * WorkloadNavigationView.swift
 * FluxUI
 *
 * Created by François Lamboley on 02/08/2020.
 */

import SwiftUI



struct WorkloadNavigationView : View {
	
	@ObservedObject var fluxWorkloads: FluxWorkloadsViewModel
	
	var body: some View {
		switch fluxWorkloads.workloads {
			case .success(let workloads) where workloads.isEmpty: noWorkloadsView
			case .success(let workloads):                         workloadsView(workloads)
			case .failure(let error):                             errorView(error)
		}
	}
	
	func errorView(_ error: Error) -> some View {
		VStack{
			Spacer()
			HStack{
				Spacer()
				Text("\(error as NSError)")
				Spacer()
			}
			Spacer()
		}
	}
	
	func workloadsView(_ workloads: [FluxWorkload]) -> some View {
//		guard !workloads.isEmpty else {
//			return noWorkloadsView
//		}
		
		return NavigationView{
			List{
				Section(header: Text("Workloads")){
					ForEach(workloads){ workload in
						NavigationLink(destination: FluxWorkloadView(fluxWorkload: workload)){
							FluxWorkloadRow(workload: workload)
						}
					}
				}
			}
			.listStyle(SidebarListStyle())
		}.navigationViewStyle(DoubleColumnNavigationViewStyle())
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
	
}


/* *************** */

struct WorkloadNavigationView_Previews : PreviewProvider {
	
	class Obj : NSObject {}
	static let workloads = try! JSONDecoder().decode([FluxWorkload].self, from: Data(contentsOf: Bundle(for: Obj.self).url(forResource: "workloads", withExtension: "json")!))
	
	static var previews: some View {
		Text("TODO")
//		WorkloadNavigationView(fluxWorkloads: workloads)
	}
	
}
