import SwiftUI

struct BlockSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
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
            Form {
                Section(header: Text("Block Settings")) {
                    HStack { Text("Block 1").frame(width: 65, alignment: .leading); TextField("Class name", text: $block1) }
                    HStack { Text("Block 2").frame(width: 65, alignment: .leading); TextField("Class name", text: $block2) }
                    HStack { Text("Block 3").frame(width: 65, alignment: .leading); TextField("Class name", text: $block3) }
                    HStack { Text("Block 4").frame(width: 65, alignment: .leading); TextField("Class name", text: $block4) }
                    HStack { Text("Block 5").frame(width: 65, alignment: .leading); TextField("Class name", text: $block5) }
                    HStack { Text("Block 6").frame(width: 65, alignment: .leading); TextField("Class name", text: $block6) }
                    HStack { Text("Block 7").frame(width: 65, alignment: .leading); TextField("Class name", text: $block7) }
                    HStack { Text("Block 8").frame(width: 65, alignment: .leading); TextField("Class name", text: $block8) }
                }
            }
            .navigationTitle("Block Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
