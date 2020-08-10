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
					ForEach(workloads){ workload -> NavigationLink<FluxWorkloadRow, LazyView<FluxWorkloadView>> in
						let model = FluxContainersViewModel(fluxSettings: fluxWorkloads.fluxSettings, workloadID: workload.id)
						/* The LazyView is not strictly required but I think it’s
						 * better w/ it. */
						return NavigationLink(destination: LazyView(FluxWorkloadView(fluxSettings: fluxWorkloads.fluxSettings, fluxWorkload: workload, fluxContainers: model))){
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
