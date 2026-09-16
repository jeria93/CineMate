//
//  SharedPreviewMovies.swift
//  CineMate
//
//  Created by Nicholas Samuelsson Jeria on 2025-07-15.
//

import Foundation

/// A small, coherent movie universe used by the portfolio demo and previews.
/// Every list item, detail, credit, person and recommendation resolves through
/// this catalog so navigation never mixes data from different titles.
enum DemoCatalog {

    // MARK: - Movies

    static let inception = Movie(
        id: 27_205,
        title: "Inception",
        overview: "A skilled thief enters people's dreams to steal secrets and is offered a chance to erase his past.",
        posterPath: "/oYuLEt3zVCKq57qu2F8dT7NIa6f.jpg",
        backdropPath: "/s3TBrRGB1iav7gFOCNx3H31MoES.jpg",
        releaseDate: "2010-07-16",
        voteAverage: 8.4,
        genres: ["Action", "Science Fiction", "Thriller"]
    )

    static let interstellar = Movie(
        id: 157_336,
        title: "Interstellar",
        overview: "Explorers travel through a wormhole in space in an attempt to ensure humanity's survival.",
        posterPath: "/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg",
        backdropPath: "/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg",
        releaseDate: "2014-11-07",
        voteAverage: 8.5,
        genres: ["Adventure", "Drama", "Science Fiction"]
    )

    static let oppenheimer = Movie(
        id: 872_585,
        title: "Oppenheimer",
        overview: "The story of J. Robert Oppenheimer and his role in developing the atomic bomb.",
        posterPath: "/ptpr0kGAckfQkJeJIt8st5dglvd.jpg",
        backdropPath: "/tmU7GeKVybMWFButWEGl2M4GeiP.jpg",
        releaseDate: "2023-07-21",
        voteAverage: 8.1,
        genres: ["Drama", "History"]
    )

    static let starWars = Movie(
        id: 11,
        title: "Star Wars: A New Hope",
        overview: "Luke Skywalker joins a rebellion fighting to free the galaxy from the Empire.",
        posterPath: "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
        backdropPath: "/9pkZesKMnblFfKxEhQx45YQ2kIe.jpg",
        releaseDate: "1977-05-25",
        voteAverage: 8.2,
        genres: ["Adventure", "Fantasy", "Science Fiction"]
    )

    static let matrix = Movie(
        id: 603,
        title: "The Matrix",
        overview: "A hacker discovers that the world he knows is a simulation and joins the fight to free humanity.",
        posterPath: "/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg",
        backdropPath: "/ncEsesgOJDNrTUED89hYbA117wo.jpg",
        releaseDate: "1999-03-31",
        voteAverage: 8.2,
        genres: ["Action", "Science Fiction"]
    )

    static let dune = Movie(
        id: 438_631,
        title: "Dune",
        overview: "Paul Atreides travels to the desert planet Arrakis and is drawn into a struggle over its future.",
        posterPath: "/d5NXSklXo0qyIYkgV94XAgMIckC.jpg",
        backdropPath: "/bgrVplQ0GEaFoqxQGEfURp9wQpG.jpg",
        releaseDate: "2021-10-22",
        voteAverage: 7.8,
        genres: ["Adventure", "Science Fiction"]
    )

    static let getOut = Movie(
        id: 419_430,
        title: "Get Out",
        overview: "A young man uncovers a disturbing secret while visiting his girlfriend's family.",
        posterPath: "/tFXcEccSQMf3lfhfXKSU9iRBpa3.jpg",
        backdropPath: "/5Pqf9WkE4Umvt13lBMMmcd9Mt1k.jpg",
        releaseDate: "2017-02-24",
        voteAverage: 7.6,
        genres: ["Horror", "Mystery", "Thriller"]
    )

    static let spiritedAway = Movie(
        id: 129,
        title: "Spirited Away",
        overview: "A young girl enters a world ruled by spirits and must find the courage to save her parents.",
        posterPath: "/39wmItIWsg5sZMyRUHLkWBcuVCM.jpg",
        backdropPath: "/Ab8mkHmkYADjU7wQiOkia9BzGvS.jpg",
        releaseDate: "2001-07-20",
        voteAverage: 8.5,
        genres: ["Animation", "Family", "Fantasy"]
    )

    static let moviesList: [Movie] = [
        inception,
        interstellar,
        oppenheimer,
        starWars,
        matrix,
        dune,
        getOut,
        spiritedAway
    ]

    static let seedFavoriteMovies = [inception, spiritedAway]

    static let minimalMovie = Movie(
        id: PreviewID.scoped(.sharedMovies, 99),
        title: "Unknown Title",
        overview: nil,
        posterPath: nil,
        backdropPath: nil,
        releaseDate: nil,
        voteAverage: nil,
        genres: nil
    )

    static func movie(withID id: Int) -> Movie? {
        moviesList.first { $0.id == id }
    }

    static func movies(for category: MovieCategory) -> [Movie] {
        switch category {
        case .popular:
            return [inception, dune, getOut, interstellar, matrix]
        case .topRated:
            return [spiritedAway, interstellar, inception, starWars, matrix]
        case .trending:
            return [oppenheimer, dune, getOut, matrix, inception]
        case .upcoming:
            // Static demo data must not pretend that released films are upcoming.
            return []
        }
    }

    /// Time-sensitive sections stay empty instead of presenting stale release claims.
    static let nowPlayingMovies: [Movie] = []

    // MARK: - Movie details

    static let genres: [Genre] = [
        Genre(id: 28, name: "Action"),
        Genre(id: 12, name: "Adventure"),
        Genre(id: 16, name: "Animation"),
        Genre(id: 18, name: "Drama"),
        Genre(id: 10751, name: "Family"),
        Genre(id: 14, name: "Fantasy"),
        Genre(id: 36, name: "History"),
        Genre(id: 27, name: "Horror"),
        Genre(id: 9648, name: "Mystery"),
        Genre(id: 878, name: "Science Fiction"),
        Genre(id: 53, name: "Thriller")
    ]

    static func detail(for movieID: Int) -> MovieDetail? {
        guard let movie = movie(withID: movieID), let metadata = metadata(for: movieID) else {
            return nil
        }

        return MovieDetail(
            id: movie.id,
            title: movie.title,
            overview: movie.overview,
            posterPath: movie.posterPath,
            backdropPath: movie.backdropPath,
            releaseDate: movie.releaseDate,
            voteAverage: movie.voteAverage,
            runtime: metadata.runtime,
            budget: metadata.budget,
            revenue: metadata.revenue,
            homepage: metadata.homepage,
            status: "Released",
            productionCompanies: metadata.companies.map(ProductionCompany.init(name:)),
            productionCountries: metadata.countries.map(ProductionCountry.init(name:)),
            genres: (movie.genres ?? []).compactMap(genre(named:))
        )
    }

    static func credits(for movieID: Int) -> MovieCredits? {
        switch movieID {
        case inception.id:
            return makeCredits(
                movieID: movieID,
                cast: [(leonardo, "Dom Cobb"), (joseph, "Arthur")],
                director: nolan
            )
        case interstellar.id:
            return makeCredits(
                movieID: movieID,
                cast: [(matthew, "Cooper"), (anne, "Brand")],
                director: nolan
            )
        case oppenheimer.id:
            return makeCredits(
                movieID: movieID,
                cast: [(cillian, "J. Robert Oppenheimer"), (emily, "Kitty Oppenheimer")],
                director: nolan
            )
        case starWars.id:
            return makeCredits(
                movieID: movieID,
                cast: [(mark, "Luke Skywalker"), (harrison, "Han Solo")],
                director: george
            )
        case matrix.id:
            return makeCredits(
                movieID: movieID,
                cast: [(keanu, "Neo"), (carrieAnne, "Trinity")],
                director: lana
            )
        case dune.id:
            return makeCredits(
                movieID: movieID,
                cast: [(timothee, "Paul Atreides"), (zendaya, "Chani")],
                director: denis
            )
        case getOut.id:
            return makeCredits(
                movieID: movieID,
                cast: [(daniel, "Chris Washington"), (allison, "Rose Armitage")],
                director: jordan
            )
        case spiritedAway.id:
            return makeCredits(
                movieID: movieID,
                cast: [(rumi, "Chihiro Ogino"), (miyu, "Haku")],
                director: hayao
            )
        default:
            return nil
        }
    }

    static func videos(for movieID: Int) -> [MovieVideo] {
        let trailerKeys: [Int: String] = [
            inception.id: "YoHD9XEInc0",
            interstellar.id: "zSWdZVtXT7E",
            oppenheimer.id: "uYPbbksJxIg",
            starWars.id: "vZ734NWnAHA",
            matrix.id: "vKQi3bBA1y8",
            dune.id: "n9xhJrPXop4",
            getOut.id: "DzfpyUB60YY",
            spiritedAway.id: "ByXuk9QqQkk"
        ]

        guard let key = trailerKeys[movieID] else { return [] }
        return [
            MovieVideo(
                id: "demo-trailer-\(movieID)",
                key: key,
                name: "Official Trailer",
                site: "YouTube",
                type: "Trailer"
            )
        ]
    }

    static func recommendations(for movieID: Int) -> [Movie] {
        let recommendationIDs: [Int]
        switch movieID {
        case inception.id:
            recommendationIDs = [matrix.id, interstellar.id, dune.id]
        case interstellar.id:
            recommendationIDs = [inception.id, dune.id, spiritedAway.id]
        case oppenheimer.id:
            recommendationIDs = [inception.id, interstellar.id, dune.id]
        case starWars.id:
            recommendationIDs = [dune.id, matrix.id, spiritedAway.id]
        case matrix.id:
            recommendationIDs = [inception.id, starWars.id, dune.id]
        case dune.id:
            recommendationIDs = [starWars.id, interstellar.id, matrix.id]
        case getOut.id:
            recommendationIDs = [inception.id, matrix.id, oppenheimer.id]
        case spiritedAway.id:
            recommendationIDs = [starWars.id, interstellar.id, dune.id]
        default:
            recommendationIDs = []
        }
        return recommendationIDs.compactMap(movie(withID:))
    }

    static func watchProviders(for movieID: Int) -> WatchProviderAvailability? {
        guard movie(withID: movieID) != nil else { return nil }
        return WatchProviderAvailability(
            requestedRegionCode: "SE",
            fallbackRegionCode: "US",
            resolvedRegionCode: "SE",
            source: .requestedRegion,
            region: WatchProviderRegion(
                link: "https://www.themoviedb.org/movie/\(movieID)/watch?locale=SE",
                flatrate: PreviewData.mockWatchProviders,
                rent: [PreviewData.mockWatchProviders[1]],
                buy: nil,
                free: nil,
                ads: nil
            )
        )
    }

    // MARK: - People

    static let seedFavoritePeople: [PersonRef] = [nolan, cillian, hayao].map(\.reference)

    static func personDetail(for personID: Int) -> PersonDetail? {
        people.first { $0.id == personID }?.detail
    }

    static func personExternalIDs(for personID: Int) -> PersonExternalIDs? {
        guard let person = people.first(where: { $0.id == personID }) else { return nil }
        return PersonExternalIDs(
            instagramId: nil,
            twitterId: nil,
            facebookId: nil,
            imdbId: person.imdbID
        )
    }

    static func movieCredits(for personID: Int) -> [PersonMovieCredit]? {
        guard people.contains(where: { $0.id == personID }) else { return nil }

        return moviesList.compactMap { movie in
            guard let credits = credits(for: movie.id) else { return nil }
            let role = credits.cast.first(where: { $0.id == personID })?.character
                ?? credits.crew.first(where: { $0.id == personID })?.job
            guard let role else { return nil }

            return PersonMovieCredit(
                id: movie.id,
                title: movie.title,
                character: role,
                releaseDate: movie.releaseDate,
                posterPath: movie.posterPath,
                popularity: movie.voteAverage.map { $0 * 10 }
            )
        }
    }

    // MARK: - Compatibility

    /// Backward-compatible no-op for previews that previously reset generated IDs.
    static func resetIDs() {
        _ = moviesList
    }
}

/// Existing previews keep their readable source name while sharing the same catalog as demo mode.
typealias SharedPreviewMovies = DemoCatalog

// MARK: - Catalog construction

private extension DemoCatalog {
    struct DetailMetadata {
        let runtime: Int
        let budget: Int
        let revenue: Int
        let homepage: String?
        let companies: [String]
        let countries: [String]
    }

    struct PersonSeed {
        let id: Int
        let name: String
        let profilePath: String?
        let department: String
        let biography: String
        let imdbID: String?

        var reference: PersonRef {
            PersonRef(id: id, name: name, profilePath: profilePath)
        }

        var detail: PersonDetail {
            PersonDetail(
                id: id,
                name: name,
                birthday: nil,
                deathday: nil,
                biography: biography,
                placeOfBirth: nil,
                profilePath: profilePath,
                imdbId: imdbID,
                gender: nil,
                knownForDepartment: department,
                alsoKnownAs: []
            )
        }
    }

    static func metadata(for movieID: Int) -> DetailMetadata? {
        switch movieID {
        case inception.id:
            return DetailMetadata(
                runtime: 148,
                budget: 160_000_000,
                revenue: 839_000_000,
                homepage: nil,
                companies: ["Warner Bros. Pictures", "Syncopy"],
                countries: ["United States of America", "United Kingdom"]
            )
        case interstellar.id:
            return DetailMetadata(
                runtime: 169,
                budget: 165_000_000,
                revenue: 731_000_000,
                homepage: nil,
                companies: ["Paramount Pictures", "Syncopy"],
                countries: ["United States of America", "United Kingdom"]
            )
        case oppenheimer.id:
            return DetailMetadata(
                runtime: 181,
                budget: 100_000_000,
                revenue: 975_000_000,
                homepage: "https://www.oppenheimermovie.com",
                companies: ["Universal Pictures", "Syncopy"],
                countries: ["United States of America", "United Kingdom"]
            )
        case starWars.id:
            return DetailMetadata(
                runtime: 121,
                budget: 11_000_000,
                revenue: 775_398_007,
                homepage: "https://www.starwars.com/films/star-wars-episode-iv-a-new-hope",
                companies: ["Lucasfilm Ltd.", "Twentieth Century Fox"],
                countries: ["United States of America"]
            )
        case matrix.id:
            return DetailMetadata(
                runtime: 136,
                budget: 63_000_000,
                revenue: 466_000_000,
                homepage: nil,
                companies: ["Warner Bros. Pictures", "Village Roadshow Pictures"],
                countries: ["United States of America", "Australia"]
            )
        case dune.id:
            return DetailMetadata(
                runtime: 155,
                budget: 165_000_000,
                revenue: 402_000_000,
                homepage: "https://www.dunemovie.com",
                companies: ["Legendary Pictures", "Warner Bros. Pictures"],
                countries: ["United States of America"]
            )
        case getOut.id:
            return DetailMetadata(
                runtime: 104,
                budget: 4_500_000,
                revenue: 255_000_000,
                homepage: nil,
                companies: ["Blumhouse Productions", "Monkeypaw Productions"],
                countries: ["United States of America"]
            )
        case spiritedAway.id:
            return DetailMetadata(
                runtime: 125,
                budget: 19_000_000,
                revenue: 395_000_000,
                homepage: nil,
                companies: ["Studio Ghibli"],
                countries: ["Japan"]
            )
        default:
            return nil
        }
    }

    static func genre(named name: String) -> Genre? {
        genres.first { $0.name == name }
    }

    static func makeCredits(
        movieID: Int,
        cast: [(PersonSeed, String)],
        director: PersonSeed
    ) -> MovieCredits {
        MovieCredits(
            id: movieID,
            cast: cast.map { person, character in
                CastMember(
                    id: person.id,
                    name: person.name,
                    character: character,
                    profilePath: person.profilePath
                )
            },
            crew: [
                CrewMember(
                    id: director.id,
                    name: director.name,
                    job: "Director",
                    profilePath: director.profilePath
                )
            ]
        )
    }

    static let nolan = PersonSeed(
        id: 525, name: "Christopher Nolan", profilePath: "/xuAIuYSmsUzKlUMBFGVZaWsY3DZ.jpg",
        department: "Directing",
        biography: "Christopher Nolan is a filmmaker known for large-scale stories built around time, memory and identity.",
        imdbID: "nm0634240"
    )
    static let leonardo = PersonSeed(
        id: 6_193, name: "Leonardo DiCaprio", profilePath: "/wo2hJpn04vbtmh0B9utCFdsQhxM.jpg",
        department: "Acting",
        biography: "Leonardo DiCaprio is an American actor and producer known for character-driven film roles.",
        imdbID: "nm0000138"
    )
    static let joseph = PersonSeed(
        id: 24_045, name: "Joseph Gordon-Levitt", profilePath: nil,
        department: "Acting", biography: "Joseph Gordon-Levitt is an American actor, writer and filmmaker.",
        imdbID: "nm0330687"
    )
    static let matthew = PersonSeed(
        id: 10_297, name: "Matthew McConaughey", profilePath: "/lCySuYjhXix3FzQdS4oceDDrXKI.jpg",
        department: "Acting",
        biography: "Matthew McConaughey is an American actor known for dramatic and comedic film roles.",
        imdbID: "nm0000190"
    )
    static let anne = PersonSeed(
        id: 1_813, name: "Anne Hathaway", profilePath: "/s6tflSD20MGz04ZR2R1lZvhmC4Y.jpg",
        department: "Acting",
        biography: "Anne Hathaway is an American actor whose work spans drama, comedy and musicals.",
        imdbID: "nm0004266"
    )
    static let cillian = PersonSeed(
        id: 2_037, name: "Cillian Murphy", profilePath: "/llkbyWKwpfowZ6C8peBjIV9jj99.jpg",
        department: "Acting",
        biography: "Cillian Murphy is an Irish actor known for stage work and intense screen performances.",
        imdbID: "nm0614165"
    )
    static let emily = PersonSeed(
        id: 5_081, name: "Emily Blunt", profilePath: nil,
        department: "Acting",
        biography: "Emily Blunt is a British actor known for roles across drama, comedy and action films.",
        imdbID: "nm1289434"
    )
    static let mark = PersonSeed(
        id: 2, name: "Mark Hamill", profilePath: "/2ZulC2Ccq1yv3pemusks6Zlfy2s.jpg",
        department: "Acting",
        biography: "Mark Hamill is an American actor best known for playing Luke Skywalker in the Star Wars films.",
        imdbID: "nm0000434"
    )
    static let harrison = PersonSeed(
        id: 3, name: "Harrison Ford", profilePath: "/zVnHagUvXkR2StdOtquEwsiwSVt.jpg",
        department: "Acting",
        biography: "Harrison Ford is an American actor known for enduring adventure and science-fiction roles.",
        imdbID: "nm0000148"
    )
    static let george = PersonSeed(
        id: 1, name: "George Lucas", profilePath: "/mDLDvsx8PaZoEThkBdyaG1JxPdf.jpg",
        department: "Directing",
        biography: "George Lucas is an American filmmaker and the creator of the Star Wars universe.",
        imdbID: "nm0000184"
    )
    static let keanu = PersonSeed(
        id: 6_384, name: "Keanu Reeves", profilePath: "/4D0PpNI0kmP58hgrwGC3wCjxhnm.jpg",
        department: "Acting",
        biography: "Keanu Reeves is a Canadian actor known for action, science fiction and independent films.",
        imdbID: "nm0000206"
    )
    static let carrieAnne = PersonSeed(
        id: 530, name: "Carrie-Anne Moss", profilePath: nil,
        department: "Acting",
        biography: "Carrie-Anne Moss is a Canadian actor best known for playing Trinity in The Matrix films.",
        imdbID: "nm0005251"
    )
    static let lana = PersonSeed(
        id: 9_340, name: "Lana Wachowski", profilePath: nil,
        department: "Directing",
        biography: "Lana Wachowski is an American filmmaker known for visually ambitious science-fiction stories.",
        imdbID: "nm0905154"
    )
    static let timothee = PersonSeed(
        id: 1_190_668, name: "Timothée Chalamet", profilePath: "/BE2sdjpgsa2rNTFa66f7upkaOP.jpg",
        department: "Acting",
        biography: "Timothée Chalamet is an American and French actor known for contemporary and period dramas.",
        imdbID: "nm3154303"
    )
    static let zendaya = PersonSeed(
        id: 505_710, name: "Zendaya", profilePath: "/3WdOloHpjtjL96uVOhFRRCcYSwq.jpg",
        department: "Acting",
        biography: "Zendaya is an American actor and producer known for film and television performances.",
        imdbID: "nm3918035"
    )
    static let denis = PersonSeed(
        id: 137_427, name: "Denis Villeneuve", profilePath: nil,
        department: "Directing",
        biography: "Denis Villeneuve is a Canadian filmmaker known for atmospheric dramas and science fiction.",
        imdbID: "nm0898288"
    )
    static let daniel = PersonSeed(
        id: 206_919, name: "Daniel Kaluuya", profilePath: nil,
        department: "Acting",
        biography: "Daniel Kaluuya is a British actor and writer known for powerful dramatic performances.",
        imdbID: "nm2257207"
    )
    static let allison = PersonSeed(
        id: 1_255_540, name: "Allison Williams", profilePath: nil,
        department: "Acting",
        biography: "Allison Williams is an American actor known for television, horror and comedy roles.",
        imdbID: "nm4129745"
    )
    static let jordan = PersonSeed(
        id: 291_263, name: "Jordan Peele", profilePath: nil,
        department: "Directing",
        biography: "Jordan Peele is an American filmmaker, actor and producer known for socially focused horror.",
        imdbID: "nm1443502"
    )
    static let rumi = PersonSeed(
        id: 19_587, name: "Rumi Hiiragi", profilePath: nil,
        department: "Acting", biography: "Rumi Hiiragi is a Japanese actor who voiced Chihiro in Spirited Away.",
        imdbID: "nm0383708"
    )
    static let miyu = PersonSeed(
        id: 19_588, name: "Miyu Irino", profilePath: nil,
        department: "Acting", biography: "Miyu Irino is a Japanese actor and voice performer.",
        imdbID: "nm0997115"
    )
    static let hayao = PersonSeed(
        id: 608, name: "Hayao Miyazaki", profilePath: "/mG3cfxtA5jqDc7fpKgyzZMKoXDh.jpg",
        department: "Directing",
        biography: "Hayao Miyazaki is a Japanese animator, filmmaker and co-founder of Studio Ghibli.",
        imdbID: "nm0594503"
    )

    static let people: [PersonSeed] = [
        nolan, leonardo, joseph,
        matthew, anne, cillian, emily,
        mark, harrison, george,
        keanu, carrieAnne, lana,
        timothee, zendaya, denis,
        daniel, allison, jordan,
        rumi, miyu, hayao
    ]
}
