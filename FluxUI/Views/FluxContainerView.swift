/*
 * FluxContainersView.swift
 * FluxUI
 *
 * Created by François Lamboley on 03/08/2020.
 */

import Foundation
import SwiftUI



struct FluxContainerView : View {
	
	var fluxContainer: FluxContainer
	
	@State
	var selectedContainer: FluxContainer.ContainerDescription?
	
	@State
	var presentingDeploymentSheet = false
	
	@ObservedObject
	var deployViewModel: DeployViewModel
	
	init(fluxContainer fc: FluxContainer, parentWorkload w: FluxWorkload, settings: FluxSettings?) {
		fluxContainer = fc
		deployViewModel = DeployViewModel(fluxSettings: nil, workloadID: w.id)
	}
	
	var body: some View {
		List(fluxContainer.available ?? [], id: \.self, selection: $selectedContainer){ containerDescription in
			Text(containerDescription.id)
				.foregroundColor(color(for: containerDescription))
				.truncationMode(.head)
				.contextMenu{
					Button("Deploy This Version…"){
						deployViewModel.deploy(containerID: containerDescription.id)
					}
				}
		}
		.sheet(isPresented: $presentingDeploymentSheet) {
			VStack{
				switch deployViewModel.deployStatus {
					case .idle: EmptyView()
					case .deploying:
						Text("Deploying New Version…").padding([.leading, .trailing], 75)
						ActivityIndicatorView(isAnimating: true)
						
					case .deployed(.success):
						Text("New Version Is Deployed\n\nIf your deployment is monitored by Flagger, your new release is not yet available for everyone.\nMonitor the progressive deployment using Kiali.")
							.lineLimit(nil)
							.multilineTextAlignment(.center)
							.fixedSize()
						HStack{ Spacer(); Button("OK"){ deployViewModel.aknowledgeDeployment() }/*macOS 11: .keyboardShortcut(.defaultAction)*/ }
						
					case .deployed(.failure(let error)):
						Text("Error deploying the release: " + error.localizedDescription)
							.lineLimit(nil)
							.multilineTextAlignment(.center)
							.fixedSize()
						HStack{ Spacer(); Button("OK"){ deployViewModel.aknowledgeDeployment() } }
				}
			}
			.padding()
		}
		/* Probably something better to do w/ Combine, idk… */
		.onReceive(deployViewModel.$deployStatus, perform: { deployStatus in
			presentingDeploymentSheet = !deployStatus.isIdle
		})
	}
	
	func color(for container: FluxContainer.ContainerDescription) -> Color? {
		if container.id == fluxContainer.current.id {
			return Color("CurrentContainerVersion")
		} else {
			return nil
		}
	}
	
}


/* *************** */

struct FluxContainerView_Previews : PreviewProvider {
	
	class Obj : NSObject {}
	static let images = try! JSONDecoder().decode([FluxImage].self, from: Data(contentsOf: Bundle(for: Obj.self).url(forResource: "images", withExtension: "json")!))
	static let workloads = try! JSONDecoder().decode([FluxWorkload].self, from: Data(contentsOf: Bundle(for: Obj.self).url(forResource: "workloads", withExtension: "json")!))
	
	static var previews: some View {
		FluxContainerView(fluxContainer: images[1].containers[0], parentWorkload: workloads[0], settings: nil)
	}
	
}
