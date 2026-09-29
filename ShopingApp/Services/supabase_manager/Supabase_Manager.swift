import Foundation
import Supabase

final class SupabaseManager {
    
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private let supabaseURL =
        "https://rysxcmfhldxxndpcyvhu.supabase.co"
    
    private let supabaseKey =
        "sb_publishable_we0kt3VYF390v9Ro-PBYyQ_1cgfX0aH"
    
    private init() {
        
        guard let url = URL(string: supabaseURL) else {
            fatalError("Invalid Supabase URL")
        }
        
        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: supabaseKey
        )
        
        print("✅ Supabase initialized")
        print("Supabase URL:", supabaseURL)
    }
}
