/*
 * WorkloadNavigationView.swift
 * FluxUI
 *
 * Created by François Lamboley on 02/08/2020.
 */

import SwiftUI

import LegibleError



struct WorkloadNavigationView : View {
	
	@ObservedObject
	var fluxWorkloads: FluxWorkloadsViewModel
	
	var body: some View {
		switch fluxWorkloads.workloads {
			case .success(let w) where w.isEmpty: noWorkloadsView
			case .success(let w):                 workloadsView(w)
			case .failure(let error):             errorView(error)
		}
	}
	
	func workloadsView(_ workloads: [FluxWorkload]) -> some View {
		NavigationView{
			List{
				Section(header: Text("Workloads")){
					ForEach(workloads){ workload -> NavigationLink<FluxWorkloadRow, FluxWorkloadView> in
						let model = FluxContainersViewModel(fluxSettings: fluxWorkloads.fluxSettings, workloadID: workload.id)
						return NavigationLink(destination: FluxWorkloadView(fluxWorkload: workload, fluxContainers: model)){
							FluxWorkloadRow(workload: workload)
						}
					}
				}
			}
			.listStyle(SidebarListStyle())
			.frame(minWidth: 250)
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
	
	func errorView(_ error: Error) -> some View {
		VStack{
			Spacer()
			HStack{
				Spacer()
				Text(error.legibleLocalizedDescription)
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
		let m = FluxWorkloadsViewModel()
		m.workloads = .success(workloads)
		return ContentView(fluxWorkloads: m)
	}
	
}
