import Foundation
import Parse

final class PAPCache {
    private var cache: NSCache
    
    // MARK:- Initialization
    
    static let sharedCache = PAPCache()
    
    private init() {
        self.cache = NSCache()
    }
    
    // MARK:- PAPCache
    
    func clear() {
        cache.removeAllObjects()
    }
    
    func keyForUser(user: PFUser) -> String {
        return "user_\(user.objectId)"
    }
    
    
    func attributesForUser(user: PFUser) -> [String:AnyObject]? {
        let key = keyForUser(user)
        return cache.objectForKey(key) as? [String:AnyObject]
    }

    func followStatusForUser(user: PFUser) -> Bool {
        if let attributes = attributesForUser(user) {
            if let followStatus = attributes[kPAPUserAttributesIsFollowedByCurrentUserKey] as? Bool {
                return followStatus
            }
        }
        
        return false
    }


    func setFollowStatus(following: Bool, user: PFUser) {
        if var attributes = attributesForUser(user) {
            attributes[kPAPUserAttributesIsFollowedByCurrentUserKey] = following
            setAttributes(attributes, forUser: user)
        }
    }
    
    
    func setAttributes(attributes: [String:AnyObject], forUser user: PFUser) {
        let key: String = self.keyForUser(user)
        cache.setObject(attributes, forKey: key)
    }
    
    

}