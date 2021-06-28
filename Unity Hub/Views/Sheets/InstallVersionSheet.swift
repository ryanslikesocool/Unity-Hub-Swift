//
//  InstallVersionPopup.swift
//  Unity Hub
//
//  Created by Ryan Boyer on 9/23/20.
//

import SwiftUI

struct InstallVersionSheet: View {
	@EnvironmentObject var settings: AppState
	@Environment(\.presentationMode) var presentationMode

	@State private var tab: String = "Version"

	@State private var selectedVersion = UnityVersion.null
	@State private var selectedModules: [UnityModule: Bool] = [:]
    
	@State private var availableModules: [UnityModule] = []

	var body: some View {
		let availableVersions = Binding(get: { settings.availableVersions }, set: { _ = $0 })
        
		return VStack(alignment: .leading) {
			if availableVersions.wrappedValue.count == 0 {
				ProgressView("Loading")
					.padding()
			} else {
				Group {
					HStack {
						Button("Cancel", action: closeMenu)
							.padding(8)
						Spacer()
					}
					HStack {
						moreVersionsText()
						TabView(selection: $tab) {
							VersionSheet(selectedVersion: $selectedVersion, availableVersions: availableVersions)
							ModuleSheet(selectedModules: $selectedModules, availableModules: $availableModules)
						}
						.padding(.horizontal, 8)
					}
					HStack {
						Spacer()
						Button("Install", action: installSelectedItems)
							.disabled(selectedVersion == UnityVersion.null)
							.padding(8)
					}
				}
				.frame(minWidth: 500)
			}
		}
		.onAppear {
			if availableVersions.wrappedValue.count == 0 {
				settings.getAvailableVersions()
			}
			tab = "Version"
			availableModules = UnityModule.getAvailableModules()
			for module in availableModules {
				selectedModules[module] = false
			}
		}
	}
        
	func closeMenu() {
		presentationMode.wrappedValue.dismiss()
	}
    
	func installSelectedItems() {
		var command = "\(settings.hubCommandBase) im --version \(selectedVersion.version)"
        
		for module in availableModules {
			if selectedModules[module] ?? false {
				command.append(" -m \(module.rawValue)")
			}
		}
        
		command.append(" --cm")
        
		let version = selectedVersion.version
        
		DispatchQueue.global(qos: .background).async {
			let string = shell(command)
            
			DispatchQueue.main.async {
				let index = settings.hub.versions.firstIndex(where: { $0.version == version })!
				if string.contains("successfully downloaded") {
					var versionSet = settings.hub.versions[index]
					versionSet.installing = false
					settings.hub.versions[index] = versionSet
				} else {
					settings.hub.versions.remove(at: index)
				}
				settings.wrap()
			}
		}
        
		selectedVersion.installing = true
		selectedVersion.path = "/Applications/Unity/Hub/Editor/\(selectedVersion.version)"
        
		settings.hub.versions.append(selectedVersion)
		settings.wrap()
        
		closeMenu()
	}
	
	func moreVersionsText() -> some View {
		return VStack(alignment: .leading) {
			Text("Visit the download archive for access to long-term support and patch releases, or join the Open Beta program.")
			VStack(alignment: .leading, spacing: 4) {
				Link("Download Archive", destination: URL(string: "https://unity3d.com/get-unity/download/archive")!)
				Link("Long-Term Support", destination: URL(string: "https://unity3d.com/unity/qa/lts-releases")!)
				Link("Open Beta", destination: URL(string: "https://unity3d.com/unity/beta")!)
			}
			Spacer()
		}
		.padding()
	}
}
