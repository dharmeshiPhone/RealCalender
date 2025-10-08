import Foundation
import SwiftUI
import CoreLocation
import MapKit

// MARK: - Enhanced Location Database
class LocationDatabase {
    static let shared = LocationDatabase()
    private init() {}

    // searches based on the user's query with enhanced filtering
    func searchLocations(query: String, type: LocationSearchType) -> [String] {
        guard !query.isEmpty else { return [] }
        let searchArray: [String]
        switch type {
        case .university: searchArray = getUniversitySuggestions(for: query)
        case .highSchool: searchArray = getHighSchoolSuggestions(for: query)
        case .workplace: searchArray = getWorkplaceSuggestions(for: query)
        case .homeAddress: searchArray = getHomeAddressSuggestions(for: query)
        case .all: searchArray = getAllLocationSuggestions(for: query)
        }
        return searchArray.prefix(10).map { String($0) }
    }

    // --- UNIVERSITY SUGGESTIONS (PRIORITIZED BY REGION WITH SMART FILTERING) ---
    private func getUniversitySuggestions(for query: String) -> [String] {
        let known = getKnownUniversities()
        let filtered = known.filter {
            $0.localizedCaseInsensitiveContains(query)
        }.sorted { location1, location2 in
            let query = query.lowercased()
            let loc1 = location1.lowercased()
            let loc2 = location2.lowercased()
            
            // Prioritize exact matches, then prefix matches, then contains
            if loc1.hasPrefix(query) && !loc2.hasPrefix(query) { return true }
            if !loc1.hasPrefix(query) && loc2.hasPrefix(query) { return false }
            
            // Prioritize US universities for broader appeal
            let loc1IsUS = location1.contains(", CA") || location1.contains(", NY") || location1.contains(", TX") || location1.contains(", MA") || location1.contains(", IL")
            let loc2IsUS = location2.contains(", CA") || location2.contains(", NY") || location2.contains(", TX") || location2.contains(", MA") || location2.contains(", IL")
            
            if loc1IsUS && !loc2IsUS { return true }
            if !loc1IsUS && loc2IsUS { return false }
            
            return location1 < location2
        }
        return filtered
    }

    // --- HIGH SCHOOL SUGGESTIONS (ENHANCED WITH REGIONAL PRIORITIZATION) ---
    private func getHighSchoolSuggestions(for query: String) -> [String] {
        var suggestions: [String] = []
        
        // Generate common school name patterns
        let patterns = [
            "\(query) High School", "\(query) Secondary School", "\(query) Preparatory School",
            "\(query) Academy", "\(query) Grammar School", "\(query) College Preparatory",
            "St. \(query) High School", "\(query) Public High School", "\(query) Catholic High School",
            "\(query) Magnet High School", "\(query) Charter School"
        ]
        suggestions.append(contentsOf: patterns)
        
        // Add known schools that match
        let all = getKnownHighSchools()
        let matches = all.filter { $0.localizedCaseInsensitiveContains(query) }
            .sorted { location1, location2 in
                let query = query.lowercased()
                let loc1 = location1.lowercased()
                let loc2 = location2.lowercased()
                
                // Prioritize prefix matches
                if loc1.hasPrefix(query) && !loc2.hasPrefix(query) { return true }
                if !loc1.hasPrefix(query) && loc2.hasPrefix(query) { return false }
                
                return location1 < location2
            }
        suggestions.append(contentsOf: matches)
        
        return Array(Set(suggestions)).sorted { $0 < $1 }
    }

    // --- WORKPLACE SUGGESTIONS (ENHANCED WITH JOB CATEGORIES) ---
    private func getWorkplaceSuggestions(for query: String) -> [String] {
        var suggestions: [String] = []
        
        // Generate common workplace patterns
        let patterns = [
            "\(query) Office", "\(query) Corporation", "\(query) Company", "\(query) Inc.",
            "\(query) Building", "\(query) Business Center", "\(query) Corporate Campus",
            "\(query) Headquarters", "\(query) Branch", "\(query) Store", "\(query) Clinic",
            "\(query) Hospital", "\(query) Medical Center", "\(query) Law Firm", "\(query) Bank"
        ]
        suggestions.append(contentsOf: patterns)
        
        // Add specific job categories if query matches
        let queryLower = query.lowercased()
        if queryLower.contains("tech") || queryLower.contains("software") || queryLower.contains("it") {
            suggestions.append(contentsOf: [
                "Tech Startup", "Software Company", "IT Department", "Development Team",
                "Data Center", "Innovation Lab", "Research & Development"
            ])
        }
        
        if queryLower.contains("health") || queryLower.contains("medical") || queryLower.contains("hospital") {
            suggestions.append(contentsOf: [
                "Medical Practice", "Dental Office", "Veterinary Clinic", "Physical Therapy",
                "Medical Laboratory", "Pharmacy", "Health Center"
            ])
        }
        
        if queryLower.contains("retail") || queryLower.contains("store") || queryLower.contains("shop") {
            suggestions.append(contentsOf: [
                "Retail Store", "Department Store", "Specialty Shop", "Boutique",
                "Shopping Center", "Outlet Store", "Franchise Location"
            ])
        }
        
        // Add known workplaces that match
        let all = getKnownWorkplaces()
        let matches = all.filter { $0.localizedCaseInsensitiveContains(query) }
            .sorted { location1, location2 in
                let query = query.lowercased()
                let loc1 = location1.lowercased()
                let loc2 = location2.lowercased()
                
                // Prioritize exact company matches
                if loc1.hasPrefix(query) && !loc2.hasPrefix(query) { return true }
                if !loc1.hasPrefix(query) && loc2.hasPrefix(query) { return false }
                
                return location1 < location2
            }
        suggestions.append(contentsOf: matches)
        
        return Array(Set(suggestions)).sorted { $0 < $1 }
    }

    // --- HOME ADDRESS SUGGESTIONS (PROPER ADDRESS FORMAT: Number Street Name, Suburb, State/Country) ---
    private func getHomeAddressSuggestions(for query: String) -> [String] {
        var suggestions: [String] = []
        
        // Generate proper street address formats
        let streetTypes = ["Street", "Avenue", "Drive", "Lane", "Road", "Boulevard", "Circuit", "Parade", "Crescent", "Place", "Terrace", "Court", "Way", "Close", "Walk", "Square"]
        
        // If query starts with numbers, generate full address suggestions
        if let firstWord = query.components(separatedBy: " ").first, Int(firstWord) != nil {
            // User is typing a street number - suggest full addresses
            let remainingQuery = query.replacingOccurrences(of: firstWord, with: "").trimmingCharacters(in: .whitespaces)
            
            for type in streetTypes {
                if remainingQuery.isEmpty {
                    // Just typed number - suggest various street names
                    suggestions.append("\(firstWord) Main \(type), Sydney, NSW")
                    suggestions.append("\(firstWord) Park \(type), Melbourne, VIC")
                    suggestions.append("\(firstWord) King \(type), Brisbane, QLD")
                    suggestions.append("\(firstWord) Queen \(type), Perth, WA")
                    suggestions.append("\(firstWord) George \(type), Adelaide, SA")
                } else {
                    // Typed number + street name
                    suggestions.append("\(firstWord) \(remainingQuery) \(type), Sydney, NSW")
                    suggestions.append("\(firstWord) \(remainingQuery) \(type), Melbourne, VIC")
                    suggestions.append("\(firstWord) \(remainingQuery) \(type), Brisbane, QLD")
                }
            }
        } else {
            // User is typing street name - suggest with common numbers
            for type in streetTypes {
                suggestions.append("10 \(query) \(type), Sydney, NSW")
                suggestions.append("25 \(query) \(type), Melbourne, VIC")
                suggestions.append("15 \(query) \(type), Brisbane, QLD")
                suggestions.append("8 \(query) \(type), Perth, WA")
            }
        }
        
        // Add known formatted addresses that match
        let all = getKnownHomeAddresses()
        suggestions.append(contentsOf: all.filter { $0.localizedCaseInsensitiveContains(query) })
        
        // Add apartment/unit formats
        if query.contains(where: { $0.isNumber }) {
            let number = query.components(separatedBy: .whitespaces).first(where: { Int($0) != nil }) ?? "1"
            suggestions.append("Unit \(number), \(number) Collins Street, Melbourne, VIC")
            suggestions.append("\(number)/45 George Street, Sydney, NSW")
            suggestions.append("Apartment \(number), \(number) Queen Street, Brisbane, QLD")
        }
        
        return Array(Set(suggestions)).sorted { $0 < $1 }.prefix(10).map { String($0) }
    }

    // --- ALL COMBINED SUGGESTIONS FOR GENERAL SEARCH ---
    private func getAllLocationSuggestions(for query: String) -> [String] {
        var allSuggestions: [String] = []
        allSuggestions.append(contentsOf: getUniversitySuggestions(for: query).prefix(2))
        allSuggestions.append(contentsOf: getHighSchoolSuggestions(for: query).prefix(2))
        allSuggestions.append(contentsOf: getWorkplaceSuggestions(for: query).prefix(2))
        allSuggestions.append(contentsOf: getHomeAddressSuggestions(for: query).prefix(2))
        return Array(Set(allSuggestions)).sorted { $0 < $1 }
    }

    // New method for getting suggestions based on context (popular jobs around universities/schools)
    func getContextualWorkplaceSuggestions(nearLocation: String) -> [String] {
        let location = nearLocation.lowercased()
        var suggestions: [String] = []
        
        // If it's a university area, suggest academic and student jobs
        if location.contains("university") || location.contains("college") || location.contains("ucla") || location.contains("mit") || location.contains("harvard") {
            suggestions.append(contentsOf: [
                "Campus Library", "Student Union", "Campus Bookstore", "Campus Cafe", "Dining Hall",
                "Research Assistant", "Teaching Assistant", "Campus Tour Guide", "Residence Hall Advisor",
                "Campus Recreation Center", "Student Health Center", "Campus IT Support", "Academic Department",
                "Tutoring Center", "Study Group Leader", "Campus Security", "Parking Services",
                "Starbucks on Campus", "Subway on Campus", "Campus Convenience Store"
            ])
        }
        
        // If it's a high school area, suggest typical teen jobs
        if location.contains("high school") || location.contains("secondary") || location.contains("grammar") {
            suggestions.append(contentsOf: [
                "McDonald's", "Starbucks", "Target", "Local Grocery Store", "Movie Theater",
                "Ice Cream Shop", "Pizza Place", "Babysitting", "Pet Sitting", "Lawn Care",
                "Tutoring", "After School Program", "Swimming Instructor", "Lifeguard",
                "Summer Camp", "Retail Store", "Fast Food Restaurant"
            ])
        }
        
        // If it's a tech hub area, suggest tech companies and internships
        if location.contains("silicon valley") || location.contains("palo alto") || location.contains("mountain view") || location.contains("cupertino") || location.contains("seattle") || location.contains("austin") {
            suggestions.append(contentsOf: [
                "Apple Inc.", "Google LLC", "Meta (Facebook)", "Tesla Inc.", "Netflix Inc.",
                "Uber Technologies", "Airbnb Inc.", "Salesforce", "Adobe Inc.", "Intel Corporation",
                "Software Engineering Intern", "Product Management Intern", "UX Design Intern",
                "Data Science Intern", "Marketing Intern", "Tech Startup", "Coding Bootcamp"
            ])
        }
        
        // If it's a major city center, suggest common urban jobs
        if location.contains("downtown") || location.contains("cbd") || location.contains("city centre") {
            suggestions.append(contentsOf: [
                "Coffee Shop", "Restaurant Server", "Retail Associate", "Bank Teller",
                "Hotel Front Desk", "Tour Guide", "Event Staff", "Office Assistant",
                "Customer Service", "Food Delivery", "Uber Driver", "Administrative Assistant"
            ])
        }
        
        return Array(suggestions.prefix(8))
    }

    // --- Additional search methods for specific types ---
    func searchUniversitiesOnly(query: String) -> [String] {
        return getUniversitySuggestions(for: query).prefix(10).map { String($0) }
    }
    
    func searchHighSchoolsOnly(query: String) -> [String] {
        return getHighSchoolSuggestions(for: query).prefix(10).map { String($0) }
    }
    
    func searchWorkplacesOnly(query: String) -> [String] {
        return getWorkplaceSuggestions(for: query).prefix(10).map { String($0) }
    }
    
    func searchHomeAddressesOnly(query: String) -> [String] {
        return getHomeAddressSuggestions(for: query).prefix(10).map { String($0) }
    }
    
    func searchLocationsWithCountryPriority(query: String, type: LocationSearchType, preferredCountry: String? = nil) -> [String] {
        let results = searchLocations(query: query, type: type)
        
        guard let country = preferredCountry?.lowercased() else { return results }
        
        // Prioritize results from preferred country
        let prioritized = results.sorted { location1, location2 in
            let loc1Lower = location1.lowercased()
            let loc2Lower = location2.lowercased()
            
            let loc1MatchesCountry = country == "us" ? 
                (loc1Lower.contains(", ca") || loc1Lower.contains(", ny") || loc1Lower.contains(", tx")) :
                loc1Lower.contains(country)
                
            let loc2MatchesCountry = country == "us" ? 
                (loc2Lower.contains(", ca") || loc2Lower.contains(", ny") || loc2Lower.contains(", tx")) :
                loc2Lower.contains(country)
            
            if loc1MatchesCountry && !loc2MatchesCountry { return true }
            if !loc1MatchesCountry && loc2MatchesCountry { return false }
            
            return location1 < location2
        }
        
        return prioritized
    }

    // ---------------------------------------------------------------------------------
    // CURATED/AUGMENTED DATA: AUSTRALIAN UNIVERSITIES, HIGH SCHOOLS, WORKPLACES, AREAS
    // ---------------------------------------------------------------------------------

    private func getKnownUniversities() -> [String] {
        return [
            // --- GROUP OF EIGHT (Go8) AUSTRALIA ---
            "University of Sydney, NSW", "University of New South Wales, Sydney, NSW",
            "University of Melbourne, VIC", "Monash University, Melbourne, VIC", "Australian National University, Canberra, ACT",
            "University of Queensland, Brisbane, QLD", "University of Western Australia, Perth, WA", "University of Adelaide, SA",
            // --- OTHER MAJOR AUSTRALIAN UNIVERSITIES ---
            "Macquarie University, Sydney, NSW", "RMIT University, Melbourne, VIC",
            "Queensland University of Technology, QLD", "University of Technology Sydney, NSW",
            "Deakin University, VIC", "Curtin University, WA", "Griffith University, QLD",
            "La Trobe University, VIC", "University of Wollongong, NSW", "University of Newcastle, NSW",
            "Swinburne University of Technology, VIC", "Western Sydney University, NSW",
            "Flinders University, SA", "Federation University, VIC", "Victoria University, VIC",
            "Charles Sturt University, NSW", "Edith Cowan University, WA", "Central Queensland University, QLD",
            "Southern Cross University, NSW/QLD", "James Cook University, QLD",
            // --- TAFEs & SPECIAL TERTIARY INSTITUTIONS ---
            "TAFE NSW, Statewide", "Melbourne Polytechnic, VIC", "Holmesglen Institute, VIC",
            "Australian Catholic University, Nationwide", "Notre Dame University, Australia", "Bond University, Gold Coast, QLD",
            
            // --- NEW ZEALAND UNIVERSITIES ---
            "University of Auckland, Auckland, New Zealand", "University of Otago, Dunedin, New Zealand",
            "Victoria University of Wellington, Wellington, New Zealand", "University of Canterbury, Christchurch, New Zealand",
            "Massey University, Palmerston North, New Zealand", "Auckland University of Technology, Auckland, New Zealand",
            "University of Waikato, Hamilton, New Zealand", "Lincoln University, Canterbury, New Zealand",
            
            // --- UNITED KINGDOM UNIVERSITIES ---
            // Russell Group Universities
            "University of Oxford, Oxford, UK", "University of Cambridge, Cambridge, UK",
            "Imperial College London, London, UK", "London School of Economics, London, UK",
            "University College London, London, UK", "King's College London, London, UK",
            "University of Edinburgh, Edinburgh, Scotland", "University of Manchester, Manchester, UK",
            "University of Bristol, Bristol, UK", "University of Warwick, Coventry, UK",
            "University of Birmingham, Birmingham, UK", "University of Leeds, Leeds, UK",
            "University of Sheffield, Sheffield, UK", "University of Nottingham, Nottingham, UK",
            "University of Glasgow, Glasgow, Scotland", "Durham University, Durham, UK",
            "University of St Andrews, St Andrews, Scotland", "University of Bath, Bath, UK",
            "University of York, York, UK", "University of Exeter, Exeter, UK",
            "Newcastle University, Newcastle, UK", "University of Liverpool, Liverpool, UK",
            "Queen Mary University of London, London, UK", "University of Southampton, Southampton, UK",
            "Cardiff University, Cardiff, Wales", "Queen's University Belfast, Belfast, Northern Ireland",
            "University of Aberdeen, Aberdeen, Scotland", "University of Dundee, Dundee, Scotland",
            // Other Notable UK Universities
            "Loughborough University, Loughborough, UK", "University of Surrey, Guildford, UK",
            "Lancaster University, Lancaster, UK", "University of Leicester, Leicester, UK",
            "University of Reading, Reading, UK", "University of Sussex, Brighton, UK",
            "Heriot-Watt University, Edinburgh, Scotland", "Brunel University London, London, UK",
            
            // --- UNITED STATES UNIVERSITIES ---
            // Ivy League
            "Harvard University, Cambridge, MA", "Yale University, New Haven, CT", "Princeton University, Princeton, NJ",
            "Columbia University, New York, NY", "University of Pennsylvania, Philadelphia, PA", "Dartmouth College, Hanover, NH",
            "Brown University, Providence, RI", "Cornell University, Ithaca, NY",
            // Top Public Universities
            "University of California, Berkeley, CA", "University of California, Los Angeles (UCLA), CA",
            "University of Michigan, Ann Arbor, MI", "University of Virginia, Charlottesville, VA",
            "University of North Carolina, Chapel Hill, NC", "University of California, San Diego, CA",
            "University of Florida, Gainesville, FL", "University of Texas at Austin, TX",
            "University of Wisconsin-Madison, WI", "University of Illinois Urbana-Champaign, IL",
            "University of Washington, Seattle, WA", "University of Georgia, Athens, GA",
            "Pennsylvania State University, University Park, PA", "Ohio State University, Columbus, OH",
            "University of California, Santa Barbara, CA", "University of California, Irvine, CA",
            // Top Private Universities
            "Stanford University, Stanford, CA", "Massachusetts Institute of Technology (MIT), Cambridge, MA",
            "California Institute of Technology (Caltech), Pasadena, CA", "University of Chicago, Chicago, IL",
            "Northwestern University, Evanston, IL", "Duke University, Durham, NC",
            "Vanderbilt University, Nashville, TN", "Rice University, Houston, TX",
            "Washington University in St. Louis, MO", "Emory University, Atlanta, GA",
            "University of Southern California (USC), Los Angeles, CA", "Carnegie Mellon University, Pittsburgh, PA",
            "Georgetown University, Washington, DC", "University of Notre Dame, Notre Dame, IN",
            "Wake Forest University, Winston-Salem, NC", "Tufts University, Medford, MA",
            // Major State Universities
            "Arizona State University, Tempe, AZ", "University of Arizona, Tucson, AZ",
            "University of Colorado Boulder, CO", "Colorado State University, Fort Collins, CO",
            "University of Connecticut, Storrs, CT", "Florida State University, Tallahassee, FL",
            "Georgia Institute of Technology, Atlanta, GA", "University of Hawaii, Honolulu, HI",
            "Iowa State University, Ames, IA", "University of Iowa, Iowa City, IA",
            "University of Kansas, Lawrence, KS", "Kansas State University, Manhattan, KS",
            "University of Kentucky, Lexington, KY", "Louisiana State University, Baton Rouge, LA",
            "University of Maryland, College Park, MD", "Boston University, Boston, MA",
            "Michigan State University, East Lansing, MI", "University of Minnesota, Minneapolis, MN",
            "University of Missouri, Columbia, MO", "University of Nebraska, Lincoln, NE",
            "University of Nevada, Reno, NV", "Rutgers University, New Brunswick, NJ",
            "University of New Mexico, Albuquerque, NM", "New York University (NYU), New York, NY",
            "University of Oregon, Eugene, OR", "Oregon State University, Corvallis, OR",
            "Temple University, Philadelphia, PA", "University of South Carolina, Columbia, SC",
            "University of Tennessee, Knoxville, TN", "Texas A&M University, College Station, TX",
            "University of Utah, Salt Lake City, UT", "Virginia Tech, Blacksburg, VA",
            "University of Wisconsin-Milwaukee, WI", "West Virginia University, Morgantown, WV",
            // California State Universities
            "San Diego State University, San Diego, CA", "California State University, Long Beach, CA",
            "San Francisco State University, San Francisco, CA", "California State University, Fullerton, CA",
            "California State University, Northridge, CA", "San Jose State University, San Jose, CA",
            // Community Colleges (Popular Transfer Schools)
            "Santa Monica College, Santa Monica, CA", "De Anza College, Cupertino, CA",
            "Pasadena City College, Pasadena, CA", "Orange Coast College, Costa Mesa, CA"
        ]
    }

    private func getKnownHighSchools() -> [String] {
        return [
            // --- TOP AUSTRALIAN SELECTIVE/PUBLIC HIGH SCHOOLS (NSW, VIC, QLD) ---
            "James Ruse Agricultural High School, Sydney NSW (Selective)", "North Sydney Boys High School, NSW (Selective)",
            "North Sydney Girls High School, NSW (Selective)", "Sydney Boys High School, NSW (Selective)",
            "Sydney Girls High School, NSW", "Baulkham Hills High School, NSW (Selective)", "Girraween High School, NSW (Selective)",
            "Melbourne High School, VIC (Selective)", "Mac.Robertson Girls' High School, VIC (Selective)",
            // --- MAJOR PRIVATE SCHOOLS (NSW, VIC, QLD) ---
            "Sydney Grammar School, Sydney, NSW", "The King's School, Parramatta, NSW", "St Joseph's College, Hunters Hill NSW",
            "Scotch College, Melbourne, VIC", "Melbourne Grammar School, VIC", "Brisbane Grammar School, QLD",
            "Brisbane Girls Grammar School, QLD", "St Peters Lutheran College, Indooroopilly, QLD",
            // --- PUBLIC SCHOOL NAMES COMMONLY USED ---
            "Randwick Boys High School, NSW", "Randwick Girls High School, NSW", "Chatswood High School, NSW",
            "Ashfield Boys High School, NSW", "Willoughby Girls High School, NSW", "Canberra Grammar School, ACT",
            "Perth Modern School, WA", "Adelaide High School, SA", "St Peters College, Adelaide, SA",
            // --- NOTABLE BOARDING & ALL-BOYS/GIRLS ---
            "St Ignatius' College, Riverview, NSW", "St Aloysius' College, Milsons Point NSW",
            "Loreto Kirribilli, NSW", "PLC Sydney, Croydon, NSW", "SCEGGS Darlinghurst, NSW", "Wenona School, North Sydney, NSW",
            
            // --- NEW ZEALAND HIGH SCHOOLS ---
            "Auckland Grammar School, Auckland, New Zealand", "Rangitoto College, Auckland, New Zealand",
            "Wellington College, Wellington, New Zealand", "Christchurch Boys' High School, Christchurch, New Zealand",
            "Otago Boys' High School, Dunedin, New Zealand", "Hamilton Boys' High School, Hamilton, New Zealand",
            "Palmerston North Boys' High School, Palmerston North, New Zealand", "Nelson College, Nelson, New Zealand",
            "King's College, Auckland, New Zealand", "St Peter's School, Cambridge, New Zealand",
            "Diocesan School for Girls, Auckland, New Zealand", "Wellington Girls' College, Wellington, New Zealand",
            "Christchurch Girls' High School, Christchurch, New Zealand", "Otago Girls' High School, Dunedin, New Zealand",
            "Epsom Girls Grammar School, Auckland, New Zealand", "Baradene College, Auckland, New Zealand",
            
            // --- UNITED KINGDOM SCHOOLS ---
            // Independent Schools
            "Eton College, Windsor, UK", "Harrow School, London, UK", "Winchester College, Winchester, UK",
            "Westminster School, London, UK", "St Paul's School, London, UK", "Charterhouse School, Surrey, UK",
            "Rugby School, Rugby, UK", "Shrewsbury School, Shrewsbury, UK", "Marlborough College, Wiltshire, UK",
            "Tonbridge School, Kent, UK", "Dulwich College, London, UK", "King's College School, London, UK",
            "St Paul's Girls' School, London, UK", "North London Collegiate School, London, UK",
            "Godolphin and Latymer School, London, UK", "Cheltenham Ladies' College, Gloucestershire, UK",
            "Roedean School, Brighton, UK", "Wycombe Abbey School, Buckinghamshire, UK",
            // Grammar Schools
            "Reading School, Reading, UK", "Latymer School, London, UK", "King Edward VI School Birmingham, UK",
            "Manchester Grammar School, Manchester, UK", "Leeds Grammar School, Leeds, UK",
            "Royal Grammar School Newcastle, Newcastle, UK", "Bristol Grammar School, Bristol, UK",
            "Nottingham High School, Nottingham, UK", "Edinburgh Academy, Edinburgh, Scotland",
            "Glasgow High School, Glasgow, Scotland", "The High School of Glasgow, Glasgow, Scotland",
            "Fettes College, Edinburgh, Scotland", "Gordonstoun School, Scotland, UK",
            // Comprehensive Schools
            "Holland Park School, London, UK", "Brampton Manor Academy, London, UK",
            "Cardinal Vaughan Memorial School, London, UK", "The Oratory School, Reading, UK",
            
            // --- UNITED STATES HIGH SCHOOLS ---
            // Elite Private Schools
            "Phillips Exeter Academy, Exeter, NH", "Phillips Academy Andover, Andover, MA",
            "The Lawrenceville School, Lawrenceville, NJ", "Choate Rosemary Hall, Wallingford, CT",
            "Deerfield Academy, Deerfield, MA", "Hotchkiss School, Lakeville, CT",
            "St. Paul's School, Concord, NH", "Groton School, Groton, MA",
            "Milton Academy, Milton, MA", "Middlesex School, Concord, MA",
            // Top Public High Schools (Magnet/Specialized)
            "Stuyvesant High School, New York, NY", "Bronx High School of Science, Bronx, NY",
            "Brooklyn Technical High School, Brooklyn, NY", "LaGuardia High School, New York, NY",
            "Thomas Jefferson High School for Science and Technology, Alexandria, VA",
            "Montgomery Blair High School, Silver Spring, MD", "Walter Johnson High School, Bethesda, MD",
            "Lowell High School, San Francisco, CA", "Mission San Jose High School, Fremont, CA",
            "Lynbrook High School, San Jose, CA", "Monta Vista High School, Cupertino, CA",
            "Gunn High School, Palo Alto, CA", "Palo Alto High School, Palo Alto, CA",
            "Troy High School, Fullerton, CA", "University High School, Irvine, CA",
            "New Trier High School, Winnetka, IL", "Adlai E. Stevenson High School, Lincolnshire, IL",
            "Plano West Senior High School, Plano, TX", "The School for the Talented and Gifted, Dallas, TX",
            // Regional Top Public Schools
            "Scarsdale High School, Scarsdale, NY", "Great Neck South High School, Great Neck, NY",
            "Jericho High School, Jericho, NY", "Half Hollow Hills High School West, Dix Hills, NY",
            "Ridgewood High School, Ridgewood, NJ", "Bergen County Academies, Hackensack, NJ",
            "Millburn High School, Millburn, NJ", "West Windsor-Plainsboro High School North, Plainsboro, NJ",
            "McLean High School, McLean, VA", "Langley High School, McLean, VA",
            "Richard Montgomery High School, Rockville, MD", "Wootton High School, Rockville, MD",
            "Northside College Preparatory High School, Chicago, IL", "Whitney M. Young Magnet High School, Chicago, IL",
            "Highland Park High School, Highland Park, IL", "Hinsdale Central High School, Hinsdale, IL",
            "Westfield High School, Westfield, IN", "Carmel High School, Carmel, IN",
            "Edina High School, Edina, MN", "Wayzata High School, Plymouth, MN",
            // California Public Schools
            "Henry M. Gunn High School, Palo Alto, CA", "Saratoga High School, Saratoga, CA",
            "Los Altos High School, Los Altos, CA", "Mountain View High School, Mountain View, CA",
            "Piedmont High School, Piedmont, CA", "Beverly Hills High School, Beverly Hills, CA",
            "Santa Monica High School, Santa Monica, CA", "Palos Verdes Peninsula High School, Rolling Hills Estates, CA",
            // Texas Public Schools
            "Highland Park High School, University Park, TX", "Westlake High School, Austin, TX",
            "Liberal Arts and Science Academy, Austin, TX", "School for the Talented and Gifted, Dallas, TX"
        ]
    }

    private func getKnownWorkplaces() -> [String] {
        return [
            // --- MAJOR AUSTRALIAN TECH HUBS & BUSINESS CENTRES ---
            "Atlassian Sydney HQ", "Commonwealth Bank HQ, Darling Harbour Sydney", "Westpac Headquarters, Sydney",
            "Google Australia, Pyrmont Sydney", "Microsoft Australia, North Ryde NSW", "Macquarie Group, Sydney",
            "Qantas HQ, Mascot, Sydney", "Telstra HQ, Melbourne", "ANZ Bank HQ, Docklands, Melbourne",
            "Amazon Australia, Sydney", "Afterpay HQ, Melbourne",
            // --- GENERIC CBD/Business Names ---
            "Barangaroo Towers, Sydney", "Sydney CBD", "Melbourne CBD", "Brisbane CBD", "Docklands, Melbourne",
            "Parramatta Business Centre, NSW", "Chatswood Commercial Centre, NSW", "North Sydney Business Park",
            // --- UNIVERSITY CAMPUSES (for workplace/edu intersection) ---
            "UNSW Kensington Campus, Sydney", "University of Melbourne Parkville Campus, VIC",
            "UQ St Lucia Campus, Brisbane", "Curtin Kent Street Campus, Perth",
            // --- NEW ZEALAND MAJOR WORKPLACES ---
            "Kiwibank Centre, Wellington, New Zealand", "ANZ Centre, Auckland, New Zealand",
            "Westpac Tower, Auckland, New Zealand", "ASB Centre, Auckland, New Zealand",
            "Xero HQ, Wellington, New Zealand", "Trade Me HQ, Wellington, New Zealand",
            "Auckland CBD, New Zealand", "Wellington CBD, New Zealand", "Christchurch CBD, New Zealand",
            "Viaduct Harbour, Auckland, New Zealand", "Wynyard Quarter, Auckland, New Zealand",
            "Spark City, Auckland, New Zealand", "Air New Zealand HQ, Auckland, New Zealand",
            "Fonterra Centre, Auckland, New Zealand", "Fletcher Building, Auckland, New Zealand",
            // --- UNITED KINGDOM MAJOR WORKPLACES ---
            // London Financial District
            "Canary Wharf, London, UK", "The City of London, UK", "Leadenhall Building, London, UK",
            "The Shard, London, UK", "30 St Mary Axe (The Gherkin), London, UK", "Lloyd's of London, UK",
            "Bank of England, London, UK", "London Stock Exchange, London, UK", "Barclays HQ, London, UK",
            "HSBC UK HQ, London, UK", "Standard Chartered HQ, London, UK", "NatWest HQ, London, UK",
            "Lloyds Banking Group HQ, London, UK", "Goldman Sachs London, UK", "JP Morgan London, UK",
            "Morgan Stanley London, UK", "Deutsche Bank London, UK", "Credit Suisse London, UK",
            // Tech Companies UK
            "Google UK, London", "Microsoft UK, Reading", "Amazon UK, London", "Facebook UK, London",
            "Apple UK, London", "Uber London, UK", "Deliveroo HQ, London, UK", "Revolut HQ, London, UK",
            "Monzo HQ, London, UK", "Wise HQ, London, UK", "ARM Holdings, Cambridge, UK",
            // Other Major UK Business Centers
            "Birmingham Business District, UK", "Manchester Business District, UK", "Leeds Business District, UK",
            "Bristol Business District, UK", "Edinburgh Financial District, Scotland", "Glasgow Business District, Scotland",
            "Cardiff Business District, Wales", "Belfast Business District, Northern Ireland",
            "MediaCity UK, Manchester", "Cambridge Science Park, UK", "Oxford Science Park, UK",
            "Bletchley Park, UK", "Bracknell Technology Park, UK", "Reading Business Park, UK",
            // --- UNITED STATES MAJOR WORKPLACES ---
            // Silicon Valley Tech Giants
            "Apple Park, Cupertino, CA", "Googleplex, Mountain View, CA", "Meta Headquarters, Menlo Park, CA",
            "Tesla Gigafactory, Fremont, CA", "Netflix Headquarters, Los Gatos, CA", "Adobe Headquarters, San Jose, CA",
            "Intel Headquarters, Santa Clara, CA", "NVIDIA Headquarters, Santa Clara, CA", "Salesforce Tower, San Francisco, CA",
            "Uber Headquarters, San Francisco, CA", "Airbnb Headquarters, San Francisco, CA", "Twitter Headquarters, San Francisco, CA",
            "LinkedIn Headquarters, Sunnyvale, CA", "PayPal Headquarters, San Jose, CA", "eBay Headquarters, San Jose, CA",
            "Cisco Systems, San Jose, CA", "Oracle Headquarters, Austin, TX", "HP Inc., Palo Alto, CA",
            // Seattle Tech Hub
            "Amazon Headquarters, Seattle, WA", "Microsoft Headquarters, Redmond, WA", "Boeing Headquarters, Chicago, IL",
            "Starbucks Headquarters, Seattle, WA", "Costco Headquarters, Issaquah, WA", "Expedia Group, Seattle, WA",
            // New York Financial District
            "Goldman Sachs Headquarters, New York, NY", "JP Morgan Chase Headquarters, New York, NY",
            "Morgan Stanley Headquarters, New York, NY", "Citigroup Headquarters, New York, NY",
            "Bank of America Tower, New York, NY", "Wells Fargo Headquarters, San Francisco, CA",
            "American Express Headquarters, New York, NY", "BlackRock Headquarters, New York, NY",
            "New York Stock Exchange, New York, NY", "NASDAQ Headquarters, New York, NY",
            // Media & Entertainment
            "Disney Headquarters, Burbank, CA", "Warner Bros. Studios, Burbank, CA", "Universal Studios, Universal City, CA",
            "Sony Pictures Studios, Culver City, CA", "Paramount Pictures, Hollywood, CA", "Netflix Studios, Hollywood, CA",
            "CNN Center, Atlanta, GA", "Fox News Headquarters, New York, NY", "NBC Studios, New York, NY",
            "CBS Headquarters, New York, NY", "ABC Studios, Burbank, CA", "ESPN Headquarters, Bristol, CT",
            // Major Corporations by City
            // Los Angeles
            "SpaceX Headquarters, Hawthorne, CA", "Northrop Grumman, Los Angeles, CA", "Aerospace Corporation, El Segundo, CA",
            "RAND Corporation, Santa Monica, CA", "UCLA Medical Center, Los Angeles, CA", "Cedars-Sinai Medical Center, Los Angeles, CA",
            // Chicago
            "Boeing Headquarters, Chicago, IL", "Abbott Laboratories, Abbott Park, IL", "Caterpillar Inc., Peoria, IL",
            "McDonald's Headquarters, Chicago, IL", "Allstate Headquarters, Northbrook, IL", "United Airlines Headquarters, Chicago, IL",
            // Boston/Cambridge
            "MIT Lincoln Laboratory, Lexington, MA", "Harvard Medical School, Boston, MA", "Massachusetts General Hospital, Boston, MA",
            "Biogen Headquarters, Cambridge, MA", "Moderna Headquarters, Cambridge, MA", "Raytheon Technologies, Waltham, MA",
            // Austin
            "Dell Technologies, Round Rock, TX", "IBM Austin, Austin, TX", "Applied Materials, Austin, TX",
            "Samsung Austin Semiconductor, Austin, TX", "3M Austin Center, Austin, TX",
            // Research Triangle, North Carolina
            "IBM Research Triangle Park, NC", "Cisco Research Triangle Park, NC", "GlaxoSmithKline, Research Triangle Park, NC",
            "SAS Institute, Cary, NC", "Red Hat, Raleigh, NC", "Credit Suisse Research Triangle Park, NC",
            // Washington DC Area
            "The Pentagon, Arlington, VA", "NASA Goddard Space Flight Center, Greenbelt, MD",
            "National Institutes of Health (NIH), Bethesda, MD", "Lockheed Martin, Bethesda, MD",
            "Booz Allen Hamilton, McLean, VA", "Deloitte, Arlington, VA", "Capital One, McLean, VA",
            // Popular Job Categories for Students
            "Starbucks Coffee", "Target Store", "Best Buy", "Apple Store", "Barnes & Noble",
            "Local Restaurant", "Campus Bookstore", "Tutoring Center", "Recreation Center", "Library",
            "Internship Program", "Research Assistant Position", "Teaching Assistant Position",
            "Student Government", "Campus Tour Guide", "Residence Hall Advisor",
            // --- COMPREHENSIVE STUDENT & POPULAR JOBS ---
            // Coffee Shops & Cafes (Very Popular Student Jobs)
            "Starbucks", "Dunkin' Donuts", "Tim Hortons", "Costa Coffee", "Cafe Nero", "Pret A Manger",
            "Local Coffee Shop", "Campus Cafe", "Bubble Tea Shop", "Smoothie Bar", "Juice Bar",
            
            // Retail Jobs (Most Common Student Employment)
            "Target", "Walmart", "Best Buy", "Apple Store", "GameStop", "Barnes & Noble", "Bookstore",
            "H&M", "Zara", "Uniqlo", "Gap", "Urban Outfitters", "American Eagle", "Forever 21",
            "JB Hi-Fi", "Harvey Norman", "Coles", "Woolworths", "Big W", "Kmart Australia",
            "John Lewis", "Marks & Spencer", "Tesco", "ASDA", "Sainsbury's", "Primark",
            "The Warehouse", "Countdown", "New World", "Farmers", "Briscoes",
            
            // Food Service (High Student Employment)
            "McDonald's", "KFC", "Subway", "Pizza Hut", "Domino's Pizza", "Burger King",
            "Chipotle", "Chick-fil-A", "Taco Bell", "In-N-Out Burger", "Five Guys",
            "Nando's", "Grill'd", "Red Rooster", "Hungry Jack's", "Oporto",
            "Local Restaurant", "Pizza Place", "Sushi Restaurant", "Food Truck", "Catering Company",
            
            // Campus-Specific Jobs
            "Campus Bookstore", "Student Union", "Campus Recreation Center", "Campus Library",
            "Residential Life Office", "Admissions Office", "Campus Tour Guide", "Campus Security",
            "Student Health Center", "Campus IT Help Desk", "Campus Dining Services", "Campus Mail Room",
            "Athletic Department", "Student Activities Office", "Career Services", "Academic Advising",
            
            // Tutoring & Education Support
            "Tutoring Center", "Math Help Center", "Writing Center", "Language Lab", "Study Group Leader",
            "Private Tutoring", "Test Prep Center", "Kumon", "Sylvan Learning", "Mathnasium",
            "After School Program", "Summer Camp", "Daycare Center", "Preschool", "Youth Program",
            
            // Popular Part-Time & Entry-Level Jobs
            "Movie Theater", "Gym/Fitness Center", "Lifeguard", "Swimming Instructor", "Personal Trainer",
            "Babysitting", "Pet Sitting", "Dog Walking", "Pet Store", "Veterinary Clinic Assistant",
            "Pharmacy Assistant", "Dental Office Receptionist", "Medical Office Assistant",
            "Bank Teller", "Customer Service Representative", "Call Center", "Data Entry Clerk",
            
            // Delivery & Transportation Jobs
            "Uber Driver", "Lyft Driver", "DoorDash Driver", "Uber Eats Driver", "Food Delivery",
            "Amazon Delivery", "FedEx", "UPS", "Postal Service", "Campus Shuttle Driver",
            "Bike Courier", "Package Handler", "Warehouse Worker", "Stock Associate",
            
            // Seasonal & Event Jobs
            "Holiday Retail Worker", "Summer Camp Counselor", "Lifeguard", "Beach Patrol",
            "Event Staff", "Concert Venue", "Sports Stadium", "Wedding Venue", "Catering Server",
            "Festival Worker", "Theme Park Employee", "Ski Resort Worker", "Hotel Front Desk",
            
            // Research & Academic Jobs
            "Research Assistant", "Lab Assistant", "Graduate Teaching Assistant", "Grader",
            "Academic Department Assistant", "Research Lab Coordinator", "Data Analyst Intern",
            "Marketing Intern", "Social Media Intern", "Graphic Design Intern", "Web Development Intern",
            
            // Creative & Media Jobs
            "Photography Assistant", "Social Media Manager", "Content Creator", "Freelance Writer",
            "Graphic Designer", "Video Editor", "Music Teacher", "Art Instructor", "Dance Instructor",
            "Theater Production Assistant", "Radio Station", "Campus Newspaper", "Campus TV Station",
            
            // Healthcare & Wellness
            "Hospital Volunteer", "Nursing Home Assistant", "Physical Therapy Assistant", "Pharmacy Technician",
            "Dental Assistant", "Optometry Assistant", "Massage Therapy Assistant", "Fitness Instructor",
            "Nutrition Assistant", "Mental Health Support Worker", "Home Care Assistant",
            
            // Technology & Online Jobs
            "Campus IT Support", "Computer Repair Shop", "Software Testing", "App Development Intern",
            "Web Design Freelancer", "Online Tutor", "Virtual Assistant", "E-commerce Assistant",
            "Digital Marketing Assistant", "SEO Assistant", "Tech Startup Intern",
            
            // Government & Public Service
            "City Hall Intern", "Library Assistant", "Park Ranger", "Museum Guide", "Tourist Information",
            "Community Center Worker", "Non-Profit Organization", "Volunteer Coordinator", "Event Planner",
            "Local Government Office", "Public Relations Intern", "Policy Research Assistant",
        ]
    }

    private func getKnownHomeAddresses() -> [String] {
        return [
            // --- SYDNEY ADDRESSES (NSW) ---
            "65 Walcott Street, Bondi Beach, NSW", "12 Campbell Parade, Bondi Beach, NSW", "8 Arden Street, Coogee, NSW",
            "25 Anzac Parade, Randwick, NSW", "15 Crown Street, Surry Hills, NSW", "22 New South Head Road, Rose Bay, NSW",
            "18 Macleay Street, Potts Point, NSW", "35 Oxford Street, Paddington, NSW", "42 Military Road, Manly, NSW",
            "28 Mosman Street, Mosman, NSW", "16 Miller Street, Neutral Bay, NSW", "85 Victoria Avenue, Chatswood, NSW",
            "45 Blaxland Road, Epping, NSW", "123 Church Street, Parramatta, NSW", "67 The Boulevarde, Strathfield, NSW",
            "89 Burwood Road, Burwood, NSW", "34 Liverpool Road, Ashfield, NSW", "56 King Street, Newtown, NSW",
            "78 Glebe Point Road, Glebe, NSW", "12 Murray Street, Pyrmont, NSW", "29 Cleveland Street, Redfern, NSW",
            "44 Marrickville Road, Marrickville, NSW", "33 New Canterbury Road, Dulwich Hill, NSW", "71 Anzac Parade, Kingsford, NSW",
            "19 Anzac Highway, Kensington, NSW", "54 Pacific Highway, St Leonards, NSW", "62 George Street, Hornsby, NSW",
            "38 Forest Road, Hurstville, NSW", "27 Kingsway, Cronulla, NSW", "41 Anzac Parade, Maroubra, NSW",
            "73 Pacific Highway, Roseville, NSW", "26 Darling Street, Balmain, NSW", "48 Norton Street, Leichhardt, NSW",
            "17 New South Head Road, Double Bay, NSW", "92 Miller Street, North Sydney, NSW", "36 Ocean Street, Woollahra, NSW",
            "105 Great Western Highway, Blacktown, NSW", "63 Herring Road, Macquarie Park, NSW", "81 Old Northern Road, Castle Hill, NSW",
            
            // --- MELBOURNE ADDRESSES (VIC) ---
            "24 Smith Street, Fitzroy, VIC", "87 Swan Street, Richmond, VIC", "45 Acland Street, St Kilda, VIC",
            "32 Toorak Road, South Yarra, VIC", "156 Bay Street, Brighton, VIC", "78 Burke Road, Hawthorn, VIC",
            "23 Lygon Street, Carlton, VIC", "91 Sydney Road, Brunswick, VIC", "67 Collins Street, Docklands, VIC",
            "52 Whitehorse Road, Box Hill, VIC", "128 Toorak Road, Toorak, VIC", "84 Burke Road, Camberwell, VIC",
            "39 Springvale Road, Glen Waverley, VIC", "145 Ormond Road, Elwood, VIC", "76 Mount Alexander Road, Essendon, VIC",
            "201 Nicholson Street, Footscray, VIC", "119 Bay Street, Port Melbourne, VIC", "68 High Street, Preston, VIC",
            "55 Sydney Road, Coburg, VIC", "143 City Road, Southbank, VIC", "82 Doncaster Road, Doncaster, VIC",
            "47 Gilbert Road, Reservoir, VIC", "126 Chapel Street, Windsor, VIC", "93 Balwyn Road, Balwyn, VIC",
            "38 Puckle Street, Moonee Ponds, VIC", "164 Dandenong Road, Caulfield, VIC", "75 Pier Street, Altona, VIC",
            
            // --- BRISBANE ADDRESSES (QLD) ---
            "65 Walcott Street, St Lucia, QLD", "28 Hawken Drive, St Lucia, QLD", "42 Sylvan Road, Toowong, QLD",
            "156 Mains Road, Sunnybank, QLD", "73 Moggill Road, Indooroopilly, QLD", "89 Boundary Street, West End, QLD",
            "34 Brunswick Street, Fortitude Valley, QLD", "127 Grey Street, South Brisbane, QLD", "55 Main Street, Kangaroo Point, QLD",
            "78 Brunswick Street, New Farm, QLD", "46 Given Terrace, Paddington, QLD", "92 Waterworks Road, Auchenflower, QLD",
            "135 Gympie Road, Chermside, QLD", "84 Stanley Street, Woolloongabba, QLD", "67 Kedron Park Road, Wilston, QLD",
            "123 Waterworks Road, Ashgrove, QLD", "58 Dornoch Terrace, Red Hill, QLD", "175 Dornoch Terrace, Highgate Hill, QLD",
            "95 Wynnum Road, Norman Park, QLD", "42 Racecourse Road, Ascot, QLD", "86 Sandgate Road, Albion, QLD",
            "134 Samford Road, Mitchelton, QLD", "76 Logan Road, Greenslopes, QLD", "68 Kessels Road, Mount Gravatt, QLD",
            "29 Moggill Road, Taringa, QLD", "145 Leichhardt Street, Spring Hill, QLD", "87 Old Cleveland Road, Carindale, QLD",
            
            // --- PERTH ADDRESSES (WA) ---
            "45 South Terrace, Fremantle, WA", "127 Rokeby Road, Subiaco, WA", "83 Stirling Highway, Claremont, WA",
            "26 Marine Parade, Cottesloe, WA", "74 Oxford Street, Leederville, WA", "152 Beaufort Street, Mount Lawley, WA",
            "98 Mends Street, South Perth, WA", "65 The Esplanade, Scarborough, WA", "134 Albany Highway, Victoria Park, WA",
            "57 Stirling Highway, Nedlands, WA", "89 Canning Highway, Applecross, WA", "72 Royal Street, East Perth, WA",
            
            // --- ADELAIDE ADDRESSES (SA) ---
            "156 O'Connell Street, North Adelaide, SA", "85 Jetty Road, Glenelg, SA", "67 The Parade, Norwood, SA",
            "92 Unley Road, Unley, SA", "45 Greenhill Road, Burnside, SA", "128 Salisbury Highway, Mawson Lakes, SA",
            "73 Prospect Road, Prospect, SA", "89 Seaview Road, Henley Beach, SA", "34 The Esplanade, Semaphore, SA",
            "126 Magill Road, Magill, SA",
            
            // --- CANBERRA ADDRESSES (ACT) ---
            "78 Giles Street, Kingston, ACT", "45 Lonsdale Street, Braddon, ACT", "92 Benjamin Way, Belconnen, ACT",
            "134 Canberra Avenue, Narrabundah, ACT", "67 Northbourne Avenue, Lyneham, ACT", "156 Hibberson Street, Gungahlin, ACT",
            "89 Bunda Street, Manuka, ACT", "23 Woolley Street, Dickson, ACT", "145 Adelaide Avenue, Yarralumla, ACT",
            "76 Constitution Avenue, Campbell, ACT",
            
            // --- NEW ZEALAND ADDRESSES ---
            // Auckland
            "125 Ponsonby Road, Ponsonby, Auckland, New Zealand", "67 Parnell Road, Parnell, Auckland, New Zealand",
            "89 Remuera Road, Remuera, Auckland, New Zealand", "45 Tamaki Drive, Mission Bay, Auckland, New Zealand",
            "156 Victoria Road, Devonport, Auckland, New Zealand", "78 Hurstmere Road, Takapuna, Auckland, New Zealand",
            "92 Broadway, Newmarket, Auckland, New Zealand", "134 Great North Road, Grey Lynn, Auckland, New Zealand",
            "23 New North Road, Kingsland, Auckland, New Zealand", "145 Mount Eden Road, Mount Eden, Auckland, New Zealand",
            
            // Wellington
            "67 The Terrace, Thorndon, Wellington, New Zealand", "89 Kelburn Parade, Kelburn, Wellington, New Zealand",
            "45 Courtenay Place, Mount Victoria, Wellington, New Zealand", "156 Oriental Parade, Oriental Bay, Wellington, New Zealand",
            "78 The Parade, Island Bay, Wellington, New Zealand", "92 Riddiford Street, Newtown, Wellington, New Zealand",
            
            // Christchurch
            "134 Fendalton Road, Fendalton, Christchurch, New Zealand", "76 Papanui Road, Merivale, Christchurch, New Zealand",
            "23 Riccarton Road, Riccarton, Christchurch, New Zealand", "145 Lincoln Road, Addington, Christchurch, New Zealand",
            
            // --- UNITED KINGDOM ADDRESSES ---
            // London
            "45 Park Lane, Mayfair, London, UK", "78 Kensington High Street, Kensington, London, UK",
            "92 King's Road, Chelsea, London, UK", "156 Belgrave Square, Belgravia, London, UK",
            "23 Brompton Road, Knightsbridge, London, UK", "134 Gloucester Road, South Kensington, London, UK",
            "67 Portobello Road, Notting Hill, London, UK", "89 Baker Street, Marylebone, London, UK",
            "145 Tottenham Court Road, Fitzrovia, London, UK", "76 Russell Square, Bloomsbury, London, UK",
            "234 Covent Garden, London, UK", "123 Old Compton Street, Soho, London, UK",
            "178 Victoria Street, Westminster, London, UK", "89 Eccleston Square, Pimlico, London, UK",
            "45 Camden High Street, Camden, London, UK", "67 Upper Street, Islington, London, UK",
            "92 Hampstead High Street, Hampstead, London, UK", "156 Highgate Hill, Highgate, London, UK",
            "234 Clapham High Street, Clapham, London, UK", "123 Brixton Road, Brixton, London, UK",
            "178 Shoreditch High Street, Shoreditch, London, UK", "89 Hackney Road, Hackney, London, UK",
            
            // --- UNITED STATES ADDRESSES ---
            // New York City
            "123 5th Avenue, Manhattan, New York, NY", "456 Broadway, Manhattan, New York, NY",
            "789 Madison Avenue, Upper East Side, Manhattan, NY", "234 Columbus Avenue, Upper West Side, Manhattan, NY",
            "567 Bleecker Street, Greenwich Village, Manhattan, NY", "890 Spring Street, SoHo, Manhattan, NY",
            "345 West Broadway, Tribeca, Manhattan, NY", "678 8th Avenue, Chelsea, Manhattan, NY",
            "901 Avenue A, East Village, Manhattan, NY", "123 Delancey Street, Lower East Side, Manhattan, NY",
            "456 Court Street, Brooklyn Heights, Brooklyn, NY", "789 Bedford Avenue, Williamsburg, Brooklyn, NY",
            "234 7th Avenue, Park Slope, Brooklyn, NY", "567 Northern Boulevard, Long Island City, Queens, NY",
            
            // Los Angeles
            "123 Hollywood Boulevard, Hollywood, Los Angeles, CA", "456 Rodeo Drive, Beverly Hills, CA",
            "789 Santa Monica Boulevard, Santa Monica, CA", "234 Abbott Kinney Boulevard, Venice, CA",
            "567 Manhattan Beach Boulevard, Manhattan Beach, CA", "890 Hermosa Avenue, Hermosa Beach, CA",
            "345 Sunset Boulevard, West Hollywood, CA", "678 Washington Boulevard, Culver City, CA",
            "901 Wilshire Boulevard, Downtown Los Angeles, CA", "123 Silver Lake Boulevard, Silver Lake, Los Angeles, CA",
            
            // San Francisco
            "123 Market Street, Downtown San Francisco, CA", "456 Mission Street, SOMA, San Francisco, CA",
            "789 Castro Street, Castro District, San Francisco, CA", "234 Fillmore Street, Pacific Heights, San Francisco, CA",
            "567 Lombard Street, Russian Hill, San Francisco, CA", "890 California Street, Nob Hill, San Francisco, CA",
            "345 University Avenue, Palo Alto, CA", "678 Castro Street, Mountain View, CA",
            "901 De Anza Boulevard, Cupertino, CA", "123 El Camino Real, Sunnyvale, CA",
            
            // Chicago
            "123 Michigan Avenue, Downtown Chicago, IL", "456 Lincoln Avenue, Lincoln Park, Chicago, IL",
            "789 North Avenue, Wicker Park, Chicago, IL", "234 Armitage Avenue, Bucktown, Chicago, IL",
            "567 Milwaukee Avenue, Logan Square, Chicago, IL", "890 Rush Street, River North, Chicago, IL",
            "345 Oak Street, Gold Coast, Chicago, IL", "678 Wells Street, Old Town, Chicago, IL",
            
            // Boston
            "123 Newbury Street, Back Bay, Boston, MA", "456 Beacon Street, Beacon Hill, Boston, MA",
            "789 Hanover Street, North End, Boston, MA", "234 Washington Street, South End, Boston, MA",
            "567 Massachusetts Avenue, Cambridge, MA", "890 Davis Square, Somerville, MA",
            
            // Washington DC
            "123 Connecticut Avenue, Downtown Washington, DC", "456 M Street, Georgetown, Washington, DC",
            "789 Dupont Circle, Washington, DC", "234 18th Street, Adams Morgan, Washington, DC",
            "567 Pennsylvania Avenue, Capitol Hill, Washington, DC", "890 Wilson Boulevard, Arlington, VA",
            
            // Seattle
            "123 Pine Street, Downtown Seattle, WA", "456 Broadway, Capitol Hill, Seattle, WA",
            "789 Fremont Avenue, Fremont, Seattle, WA", "234 Market Street, Ballard, Seattle, WA",
            "567 Queen Anne Avenue, Queen Anne, Seattle, WA", "890 1st Avenue, Belltown, Seattle, WA",
            
            // College Towns
            "123 University Avenue, College Station, TX", "456 College Avenue, University Park, PA",
            "789 State Street, Ithaca, NY", "234 Nassau Street, Princeton, NJ",
            "567 Chapel Street, New Haven, CT", "890 State Street, Ann Arbor, MI"
        ]
    }
}

// --- (unchanged) Enhanced Location Manager ---
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    func requestPermission() { locationManager.requestWhenInUseAuthorization() }
    func requestLocation() { locationManager.requestLocation() }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse { locationManager.requestLocation() }
    }
    func getCurrentLocationAddress(completion: @escaping (String?) -> Void) {
        guard let location = currentLocation else { completion(nil); return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let placemark = placemarks?.first {
                // Format address properly: "Number Street Name, Suburb, State/Country"
                var addressComponents: [String] = []
                
                // Add street number and name
                if let streetNumber = placemark.subThoroughfare,
                   let streetName = placemark.thoroughfare {
                    addressComponents.append("\(streetNumber) \(streetName)")
                } else if let streetName = placemark.thoroughfare {
                    addressComponents.append(streetName)
                }
                
                // Add suburb/locality
                if let locality = placemark.locality {
                    addressComponents.append(locality)
                }
                
                // Add state/administrative area
                if let state = placemark.administrativeArea {
                    addressComponents.append(state)
                }
                
                // Add country if it's not already implied by state abbreviation
                if let country = placemark.country,
                   let state = placemark.administrativeArea,
                   !["NSW", "VIC", "QLD", "WA", "SA", "ACT", "NT", "TAS"].contains(state) &&
                   !["CA", "NY", "TX", "FL", "IL", "PA", "OH", "GA", "NC", "MI"].contains(state) {
                    addressComponents.append(country)
                }
                
                let formattedAddress = addressComponents.joined(separator: ", ")
                DispatchQueue.main.async { 
                    completion(formattedAddress.isEmpty ? nil : formattedAddress)
                }
            } else { 
                DispatchQueue.main.async { completion(nil) } 
            }
        }
    }
}

// --- Matching Type Enum ---
enum LocationSearchType {
    case university
    case highSchool
    case workplace
    case homeAddress
    case all
}