import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("block1Setting") private var block1: String = ""
    @AppStorage("block2Setting") private var block2: String = ""
    @AppStorage("block3Setting") private var block3: String = ""
    @AppStorage("block4Setting") private var block4: String = ""
    @AppStorage("block5Setting") private var block5: String = ""
    @AppStorage("block6Setting") private var block6: String = ""
    @AppStorage("block7Setting") private var block7: String = ""
    @AppStorage("block8Setting") private var block8: String = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Class Names (Block Schedule)").font(.subheadline)) {
                    HStack { Text("Block 1").frame(width: 80, alignment: .leading); TextField("Class name", text: $block1) }
                    HStack { Text("Block 2").frame(width: 80, alignment: .leading); TextField("Class name", text: $block2) }
                    HStack { Text("Block 3").frame(width: 80, alignment: .leading); TextField("Class name", text: $block3) }
                    HStack { Text("Block 4").frame(width: 80, alignment: .leading); TextField("Class name", text: $block4) }
                    HStack { Text("Block 5").frame(width: 80, alignment: .leading); TextField("Class name", text: $block5) }
                    HStack { Text("Block 6").frame(width: 80, alignment: .leading); TextField("Class name", text: $block6) }
                    HStack { Text("Block 7").frame(width: 80, alignment: .leading); TextField("Class name", text: $block7) }
                    HStack { Text("Block 8").frame(width: 80, alignment: .leading); TextField("Class name", text: $block8) }
                }
                
                Section(header: Text("Show in Calendar").font(.subheadline)) {
                    if viewModel.availableCategories.isEmpty {
                        Text("No categories available yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.availableCategories, id: \.self) { category in
                            Toggle(isOn: Binding(
                                get: { !viewModel.hiddenCategories.contains(category) },
                                set: { isShowing in
                                    if isShowing {
                                        viewModel.hiddenCategories.remove(category)
                                    } else {
                                        viewModel.hiddenCategories.insert(category)
                                    }
                                }
                            )) {
                                Text(category)
                            }
                            .tint(.red)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}
