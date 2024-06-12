///
///
///Project name: AdHocLoudspeakerArray
/// Class name: ColumnListStyle
/// Creator: Kazuki Fujita
/// Created at: 2023/11/27
/// Updated at: 2023/12/12
///
/// ---Explanation---
///This is a style class for aligning Ccolumns as a list.
///
import SwiftUI

struct ColumnListStyle: View {
    
    var column: ColumnStyle
    
    var body: some View {
        HStack{
            column.image // Mark
                .resizable()
                .frame(width: 50, height: 50)
            
            Text(column.name)  // Name
        }
    }
    
    init(){
        self.column = ColumnStyle()
    }
    
    init(column: ColumnStyle) {
        self.column = column
    }
}

#Preview {
    ColumnListStyle()
}
