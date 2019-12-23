import XCTest
import XVersion

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
   func testEmpty() {
        
        let zero = Version.empty
        
        assert(zero.major == 0)
        assert(zero.minor == 0)
        assert(zero.patch == 0)
        
        assert(zero == "0.0.0")
        assert(zero == "")
        
    }
    
    func testNormal() {
        
        assert(Version(major: 0, minor: 2, patch: 3) == "0.2.3")
        
        assert(Version(major: 0, minor: 2, patch: 3) == "0.2.3.32")
        
    }
    
    func testWrong() {
        
        assert(Version.empty == "gjre")
        
        assert(Version(major: 12, minor: 0, patch: 0) == "12")
        
        assert(Version(major: 0, minor: 3, patch: 0) == "g.3")
        
        assert(Version(major: 0, minor: 3, patch: 0) >= "g.g.3")
        
        assert(Version(major: 0, minor: 3, patch: 0) >= ".g.3")
        
        assert(Version(major: 0, minor: 3, patch: 0) == ".3")
        
        assert(Version(major: 0, minor: 0, patch: 3) == "..3")
        
        assert(Version(major: 0, minor: 0, patch: 3) == "..3..")
        
        assert(Version(major: 0, minor: 1, patch: 0) == ".1.")
    }
    
    
    func testBigger() {
        assert(Version(major: 1, minor: 2, patch: 3) >= "0.2.3")
        
        assert(Version(major: 0, minor: 2, patch: 3) <= "0.2.3.32")
        
        
        assert(Version(major: 1, minor: 2, patch: 3) >= "0.25123.3342")
        
        assert(Version(major: 1, minor: 2, patch: 3) <= "1.25123.3342")
        
        assert(Version(major: 1, minor: 2, patch: 3) <= "1.2.3342")
        
        assert(Version(major: 1, minor: 2, patch: 3) <= "1.2.3")
    }
    
}
