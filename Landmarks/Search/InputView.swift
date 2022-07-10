//
//  InputView.swift
//  Landmarks
//
//  Created by Christy Ye on 7/24/21.
//  Copyright © 2021 Sean Fraga. All rights reserved.
//

import SwiftUI

struct InputView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

	@State var fieldValue: String = ""
	@State var isAlert: Bool = false
	@State var activeAlert: ActiveAlert = .first
	@State private var showLoading: Bool = false
    @State private var newItemLabel: String = ""
    @FocusState private var focusedField: Field?
    private enum Field: CaseIterable, Hashable {
        case url
    }
	
	var delegate: AssetRowProtocol?
	
    var body: some View {
        ZStack(alignment: .top, content: {
            Color.init(.systemGray6)
            VStack {
                Text("Add from IIIF Manifest")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 25)

                Text("Libraries, museums, and archives around the world use IIIF, the International Image Interoperability Framework, to share digitized archival materials.\n\nFor instructions on how to find an item's IIIF manifest URL in different archives, visit:")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20))

                Button(action: {
                    UIApplication.shared.open(URL(string:"https://guides.iiif.io")!)
                }, label: {
                    Text("https://guides.iiif.io.").font(.subheadline)
                })
                    .buttonStyle(BorderlessButtonStyle())

                TextField("Enter IIIF manifest URL", text: $fieldValue, onCommit: {
                    urlEnter()
                })
                .focused($focusedField, equals: .url)
                .padding(.horizontal, 20.0)
                .multilineTextAlignment(.leading)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.gray)
                .font(.body)
                .padding(EdgeInsets(top: 25, leading: 0, bottom: 0, trailing: 0))

                Text("Type or paste an item's IIIF manifest URL to add it to Booksnake.")
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.leading)
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
            }

            ZStack {
                ActivityIndicator(isAnimating: $showLoading, text: "Adding to Booksnake", style: .large)
                    .frame(width: 200.0, height: 200.0, alignment: .center)
                    .background(Color(white: 0.7, opacity: 0.7))
                    .cornerRadius(20)
            }
            .isHidden(!showLoading)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        })
        .navigationBarItems(trailing: HStack() {
            Button(action: {
                // Resign keyboard to fix AttributeGraph: cycle detected through attribute error
                DispatchQueue.main.async {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
                    )
                }

                urlEnter()
            }, label:{
                Text("Add")
            })
        })
        .onAppear(perform: {
            // The focusedField won't work if we don't delay the signal, https://stackoverflow.com/a/67892111 . It's a bug from Apple.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.focusedField = .url
            }
        })
        .alert(isPresented: $isAlert) {
            switch activeAlert {
            case .first:
                return Alert(title: Text("Unable to add item"),
                             message: Text("The item catalog page doesn't have the necessary information"),
                             dismissButton: .default(Text("OK")))
            case .second:
                return Alert(title: Text("URL has spaces and/or nothing is entered"),
                             message: Text("Please remove spaces from URL address and/or type something"),
                             dismissButton: .default(Text("OK")))
            case .third:
                return Alert(title: Text("\(newItemLabel) Download Complete!"),
                             message: Text("Tap OK to return to main page."),
                             dismissButton: .default(Text("OK"), action: {
                    delegate?.switchToLibraryTab()
                    NavigationUtil.popToRootView()
                }))
            }
        }
    }

	private func urlEnter() {
        showLoading = true

        // Check if textField is valid
        guard !fieldValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            activeAlert = .second
            isAlert = true
            showLoading = false
            return
        }

        Task {
            defer {
                isAlert = true
                showLoading = false
            }

            // Check if url is valid for ifff
            let status = await validateURLForIIIF(url: fieldValue)

            // If the textField is incorrect, show error
            guard status else {
                activeAlert = .first
                return
            }

            // Add manifest.json at the end of the url if needed
            if (!fieldValue.hasSuffix("manifest.json") && fieldValue.contains("loc.gov")) {
                fieldValue.append("/manifest.json")
            }

            // Add the manifest into DB
            let result = await ManifestDataHandler.addNewManifest(from: fieldValue, managedObjectContext: self.managedObjectContext)

            switch result {
            case .success(let newItemLabel):
                print("sucess in downloading")
                self.newItemLabel = newItemLabel
                activeAlert = .third
            case .failure(let error):
                print("can't download manifest. Error \(error)")
                activeAlert = .first
            }
        }
	}

    private func validateURLForIIIF(url: String) async -> Bool {
        var path: String = url

        // only for loc.gov
        if (!path.hasSuffix("manifest.json") && path.contains("loc.gov")) {
            path.append("/manifest.json")
        }

        let url_path = NSURL(string: path)

        // No need to switch to Mainthread because UIApplication has @MainActor
        guard !url.isEmpty,
              url_path != nil,
              await UIApplication.shared.canOpenURL((url_path!) as URL) else {
                  return false
              }

        var request = URLRequest(url: url_path! as URL)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 1.0

        guard let (_, response) = try? await URLSession.shared.data(for: request),
              let httpResp: HTTPURLResponse = response as? HTTPURLResponse else {
                  return false
              }

        return httpResp.statusCode == 200
    }
}
