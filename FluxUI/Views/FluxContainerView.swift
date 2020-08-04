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
	
	var body: some View {
		List(fluxContainer.available ?? [], id: \.self, selection: $selectedContainer){ containerDescription in
			Text(containerDescription.id)
				.foregroundColor(color(for: containerDescription))
				.truncationMode(.head)
		}
	}
	
	func color(for container: FluxContainer.ContainerDescription) -> Color {
		let isSelected = container == selectedContainer
		if container.id == fluxContainer.current.id {
			return .green
		} else {
			return isSelected ? .white : .primary
		}
	}
	
}


/* *************** */

struct FluxContainerView_Previews : PreviewProvider {
	
	class Obj : NSObject {}
	static let images = try! JSONDecoder().decode([FluxImage].self, from: Data(contentsOf: Bundle(for: Obj.self).url(forResource: "images", withExtension: "json")!))
	
	static var previews: some View {
		FluxContainerView(fluxContainer: images[1].containers[0])
	}
	
}
