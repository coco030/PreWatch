package com.springmvc.service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.springmvc.domain.Movie;

// ExternalMovieApiService 클래스: 외부 영화 API(TMDB API) 연동 로직 구현.
@Service // Spring 빈으로 등록
public class ExternalMovieApiService {

    private static final Logger logger = LoggerFactory.getLogger(ExternalMovieApiService.class);

    private final String omdbSearchApiKey; // API Key
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    private final TmdbApiService tmdbApiService;

    //TMDB 검색용
    private final String OMDB_BASE_URL = "https://api.themoviedb.org/3/search/movie";
    private final String TMDB_UPCOMING_URL = "https://api.themoviedb.org/3/movie/upcoming";
    private final String TMDB_IMAGE_BASE_URL = "https://image.tmdb.org/t/p/w500";
    private static final Map<Integer, String> TMDB_MOVIE_GENRES_BY_ID = Map.ofEntries(
            Map.entry(28, "액션"),
            Map.entry(12, "모험"),
            Map.entry(16, "애니메이션"),
            Map.entry(35, "코미디"),
            Map.entry(80, "범죄"),
            Map.entry(99, "다큐멘터리"),
            Map.entry(18, "드라마"),
            Map.entry(10751, "가족"),
            Map.entry(14, "판타지"),
            Map.entry(36, "역사"),
            Map.entry(27, "공포"),
            Map.entry(10402, "음악"),
            Map.entry(9648, "미스터리"),
            Map.entry(10749, "로맨스"),
            Map.entry(878, "SF"),
            Map.entry(10770, "TV 영화"),
            Map.entry(53, "스릴러"),
            Map.entry(10752, "전쟁"),
            Map.entry(37, "서부")
    );

    // 3. 생성자
    public ExternalMovieApiService(@Value("${omdb.api.key.search}") String omdbSearchApiKey,
                                   TmdbApiService tmdbApiService) {
        this.restTemplate = new RestTemplate();
        this.objectMapper = new ObjectMapper();
        this.omdbSearchApiKey = omdbSearchApiKey;
        this.tmdbApiService = tmdbApiService;
        logger.info("ExternalMovieApiService 초기화 완료. TMDb 검색용 API 키가 설정되었습니다.");
    }

    // 검색 기능
    public List<Movie> searchMoviesByKeyword(String keyword) {
        logger.debug("TMDB API에서 키워드 '{}'로 영화 목록 검색 시도.", keyword);

        String searchApiUrl = UriComponentsBuilder.fromHttpUrl(OMDB_BASE_URL)
                .queryParam("api_key", this.omdbSearchApiKey)
                .queryParam("query", keyword)
                .queryParam("language", "ko-KR")
                .build().toUriString();

        List<Movie> moviesWithFullDetails = new ArrayList<>();
        try {
            logger.debug("TMDB API 검색 호출 URL: {}", searchApiUrl);
            String jsonResponse = restTemplate.getForObject(searchApiUrl, String.class);

            JsonNode rootNode = objectMapper.readTree(jsonResponse);

            if (rootNode.has("results")) {
                JsonNode searchResults = rootNode.get("results");
                
                if (searchResults != null && searchResults.isArray()) {
                    for (JsonNode movieNode : searchResults) {
                        String tmdbId = movieNode.has("id") ? movieNode.get("id").asText() : null;

                        if (tmdbId != null) {
                            Movie fullMovieDetail = getMovieFromApi(tmdbId);
                            if (fullMovieDetail != null) {
                                moviesWithFullDetails.add(fullMovieDetail);
                            }
                        }
                    }
                    logger.info("TMDB API에서 키워드 '{}'로 {}개의 영화 상세 정보 검색 성공.", keyword, moviesWithFullDetails.size());
                }
            } else {
                logger.warn("결과가 없습니다.");
            }
        } catch (Exception e) {
            logger.error("API 오류: {}", e.getMessage(), e);
        }
        return moviesWithFullDetails;
    }

    public List<Movie> searchMoviesForUserCards(String keyword) {
        return searchMoviesForUserCards(keyword, 1, 0, 12).getMovies();
    }

    public List<Movie> getUpcomingMovieCandidates(int page) {
        int safePage = Math.max(page, 1);
        String upcomingApiUrl = UriComponentsBuilder.fromHttpUrl(TMDB_UPCOMING_URL)
                .queryParam("api_key", this.omdbSearchApiKey)
                .queryParam("language", "ko-KR")
                .queryParam("region", "KR")
                .queryParam("page", safePage)
                .build()
                .toUriString();

        List<Movie> movies = new ArrayList<>();
        try {
            String jsonResponse = restTemplate.getForObject(upcomingApiUrl, String.class);
            JsonNode rootNode = objectMapper.readTree(jsonResponse);
            JsonNode results = rootNode.path("results");

            if (results.isArray()) {
                for (JsonNode movieNode : results) {
                    Movie movie = createMovieCardFromSearchResult(movieNode);
                    if (movie != null) {
                        movies.add(movie);
                    }
                }
            }

            logger.info("TMDB 개봉예정 후보 {}페이지에서 {}개를 가져왔습니다.", safePage, movies.size());
        } catch (Exception e) {
            logger.error("TMDB 개봉예정 후보 조회 오류: {}", e.getMessage(), e);
        }
        return movies;
    }

    public MovieSearchResult searchMoviesForUserCards(String keyword, int page, int offset, int limit) {
        int safePage = Math.max(page, 1);
        int safeOffset = Math.max(offset, 0);
        int safeLimit = Math.max(limit, 1);
        logger.debug("TMDB API에서 키워드 '{}'로 사용자 카드용 영화 목록 검색 시도. page={}, offset={}, limit={}",
                keyword, safePage, safeOffset, safeLimit);

        List<Movie> movies = new ArrayList<>();
        boolean hasMore = false;
        int currentPage = safePage;
        int currentOffset = safeOffset;

        try {
            int totalPages = safePage;

            while (movies.size() < safeLimit && currentPage <= totalPages) {
                String searchApiUrl = UriComponentsBuilder.fromHttpUrl(OMDB_BASE_URL)
                        .queryParam("api_key", this.omdbSearchApiKey)
                        .queryParam("query", keyword)
                        .queryParam("language", "ko-KR")
                        .queryParam("page", currentPage)
                        .build().toUriString();

                String jsonResponse = restTemplate.getForObject(searchApiUrl, String.class);
                JsonNode rootNode = objectMapper.readTree(jsonResponse);
                JsonNode searchResults = rootNode.path("results");
                totalPages = rootNode.path("total_pages").asInt(currentPage);

                if (!searchResults.isArray() || searchResults.size() == 0) {
                    break;
                }

                int resultCount = searchResults.size();
                int start = Math.min(currentOffset, resultCount);
                int nextIndex = start;

                for (int i = start; i < resultCount && movies.size() < safeLimit; i++) {
                    JsonNode movieNode = searchResults.get(i);
                    Movie movie = createMovieCardFromSearchResult(movieNode);
                    if (movie != null) {
                        movies.add(movie);
                    }
                    nextIndex = i + 1;
                }

                boolean reachedEndOfPage = nextIndex >= resultCount;
                if (movies.size() >= safeLimit) {
                    hasMore = !reachedEndOfPage || currentPage < totalPages;
                    currentOffset = nextIndex;
                    if (reachedEndOfPage && currentPage < totalPages) {
                        currentPage++;
                        currentOffset = 0;
                    }
                    break;
                }

                if (reachedEndOfPage) {
                    if (currentPage >= totalPages) {
                        currentOffset = resultCount;
                        hasMore = false;
                        break;
                    }
                    currentPage++;
                    currentOffset = 0;
                    hasMore = true;
                } else {
                    currentOffset = nextIndex;
                    hasMore = true;
                    break;
                }
            }

            logger.info("TMDB API에서 키워드 '{}'로 사용자 카드용 영화 {}개 검색 성공. hasMore={}",
                    keyword, movies.size(), hasMore);
        } catch (Exception e) {
            logger.error("사용자 카드용 영화 검색 API 오류: {}", e.getMessage(), e);
        }

        return new MovieSearchResult(movies, hasMore, currentPage, currentOffset);
    }

    // 상세 조회  (ID -> 상세 정보)
    public Movie getMovieFromApi(String tmdbId) {
        String detailBaseUrl = "https://api.themoviedb.org/3/movie/";
        
        String apiUrl = UriComponentsBuilder.fromHttpUrl(detailBaseUrl + tmdbId)
                .queryParam("api_key", this.omdbSearchApiKey)
                .queryParam("language", "ko-KR")
                .build().toUriString();

        try {
            String jsonResponse = restTemplate.getForObject(apiUrl, String.class);
            JsonNode rootNode = objectMapper.readTree(jsonResponse);

            if (rootNode.has("title")) {
                Movie movie = new Movie();
                
                movie.setApiId(rootNode.has("id") ? rootNode.get("id").asText() : null);
                movie.setTitle(rootNode.has("title") ? rootNode.get("title").asText() : "N/A");
                movie.setDirector(getDirectorFromCredits(tmdbId));
                
                // 날짜 파싱
                if (rootNode.has("release_date")) {
                    String released = rootNode.get("release_date").asText();
                    if (released != null && !released.isEmpty()) {
                         movie.setReleaseDate(LocalDate.parse(released)); 
                         movie.setYear(movie.getReleaseDate().getYear());
                    }
                }

                // 줄거리
                movie.setOverview(rootNode.has("overview") ? rootNode.get("overview").asText() : "");
                
                // 포스터
                if (rootNode.has("poster_path")) {
                    String posterPath = rootNode.get("poster_path").asText();
                    if (!isBlank(posterPath)) {
                        movie.setPosterPath(TMDB_IMAGE_BASE_URL + posterPath);
                    }
                }

                // 런타임
                movie.setRuntime(rootNode.has("runtime") ? rootNode.get("runtime").asText() + "분" : "N/A");

                Integer parsedTmdbId = parseTmdbId(tmdbId);
                if (parsedTmdbId != null) {
                    movie.setRated(tmdbApiService.getCertification(parsedTmdbId));
                }

                // 평점 (Rating/Violence_score_avg)
                movie.setRating(0.0); 
                movie.setViolence_score_avg(0.0); // 폭력성 지수도 0.0

                // 장르 처리 (배열 -> 쉼표 문자열)
                if (rootNode.has("genres") && rootNode.get("genres").isArray()) {
                    List<String> genreNames = new ArrayList<>();
                    for (JsonNode genreNode : rootNode.get("genres")) {
                        genreNames.add(genreNode.get("name").asText());
                    }
                    movie.setGenre(String.join(", ", genreNames));
                } else {
                    movie.setGenre("N/A");
                }

                return movie;
            }
        } catch (Exception e) {
            logger.error("TMDB 상세 조회 오류: {}", e.getMessage());
        }
        return null;
    }

    private Integer parseTmdbId(String tmdbId) {
        if (tmdbId == null || tmdbId.isBlank()) {
            return null;
        }

        try {
            return Integer.parseInt(tmdbId.trim());
        } catch (NumberFormatException e) {
            logger.warn("TMDB ID가 숫자 형식이 아닙니다: {}", tmdbId);
            return null;
        }
    }

    private Movie createMovieCardFromSearchResult(JsonNode movieNode) {
        String tmdbId = movieNode.path("id").asText(null);
        if (isBlank(tmdbId)) {
            return null;
        }

        Movie movie = new Movie();
        movie.setApiId(tmdbId);
        movie.setTitle(movieNode.path("title").asText("N/A"));
        movie.setOverview(movieNode.path("overview").asText(""));
        movie.setRating(0.0);
        movie.setViolence_score_avg(0.0);
        movie.setLikeCount(0);

        String releaseDateText = movieNode.path("release_date").asText(null);
        if (!isBlank(releaseDateText)) {
            try {
                LocalDate releaseDate = LocalDate.parse(releaseDateText);
                movie.setReleaseDate(releaseDate);
                movie.setYear(releaseDate.getYear());
            } catch (Exception e) {
                logger.debug("검색 결과 release_date 파싱 실패: tmdbId={}, releaseDate={}", tmdbId, releaseDateText);
            }
        }

        String posterPath = movieNode.path("poster_path").asText(null);
        if (!isBlank(posterPath)) {
            movie.setPosterPath(TMDB_IMAGE_BASE_URL + posterPath);
        }

        movie.setGenre(resolveGenreNames(movieNode.path("genre_ids")));

        return movie;
    }

    private String resolveGenreNames(JsonNode genreIdsNode) {
        if (genreIdsNode == null || !genreIdsNode.isArray()) {
            return "";
        }

        List<String> genres = new ArrayList<>();
        for (JsonNode genreIdNode : genreIdsNode) {
            String genreName = TMDB_MOVIE_GENRES_BY_ID.get(genreIdNode.asInt());
            if (!isBlank(genreName)) {
                genres.add(genreName);
            }
        }
        return String.join(", ", genres);
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty() || "null".equalsIgnoreCase(value.trim());
    }

    public static class MovieSearchResult {
        private final List<Movie> movies;
        private final boolean hasMore;
        private final int nextPage;
        private final int nextOffset;

        public MovieSearchResult(List<Movie> movies, boolean hasMore, int nextPage, int nextOffset) {
            this.movies = movies;
            this.hasMore = hasMore;
            this.nextPage = nextPage;
            this.nextOffset = nextOffset;
        }

        public List<Movie> getMovies() {
            return movies;
        }

        public boolean isHasMore() {
            return hasMore;
        }

        public int getNextPage() {
            return nextPage;
        }

        public int getNextOffset() {
            return nextOffset;
        }
    }

    private String getDirectorFromCredits(String tmdbId) {
        String creditsUrl = UriComponentsBuilder.fromHttpUrl("https://api.themoviedb.org/3/movie/" + tmdbId + "/credits")
                .queryParam("api_key", this.omdbSearchApiKey)
                .build().toUriString();

        try {
            String jsonResponse = restTemplate.getForObject(creditsUrl, String.class);
            JsonNode rootNode = objectMapper.readTree(jsonResponse);
            JsonNode crew = rootNode.get("crew");
            List<String> directors = new ArrayList<>();

            if (crew != null && crew.isArray()) {
                for (JsonNode member : crew) {
                    if ("Director".equalsIgnoreCase(member.path("job").asText())) {
                        directors.add(member.path("name").asText());
                    }
                }
            }

            return directors.isEmpty() ? null : String.join(", ", directors);
        } catch (Exception e) {
            logger.warn("TMDB 감독 정보 조회 실패: tmdbId = {}, 오류 = {}", tmdbId, e.getMessage());
            return null;
        }
    }
}
