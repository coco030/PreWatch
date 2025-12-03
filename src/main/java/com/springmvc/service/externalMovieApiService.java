package com.springmvc.service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.springmvc.domain.movie;

// externalMovieApiService 클래스: 외부 영화 API(TMDB API) 연동 로직 구현.
@Service // Spring 빈으로 등록
public class externalMovieApiService {

    private static final Logger logger = LoggerFactory.getLogger(externalMovieApiService.class);

    private final String omdbSearchApiKey; // API Key
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    //TMDB 검색용
    private final String OMDB_BASE_URL = "https://api.themoviedb.org/3/search/movie";

    // 3. 생성자
    public externalMovieApiService(@Value("${omdb.api.key.search}") String omdbSearchApiKey) {
        this.restTemplate = new RestTemplate();
        this.objectMapper = new ObjectMapper();
        this.omdbSearchApiKey = omdbSearchApiKey;
        logger.info("externalMovieApiService 초기화 완료. TMDb 검색용 API 키가 설정되었습니다.");
    }

    // 검색 기능
    public List<movie> searchMoviesByKeyword(String keyword) {
        logger.debug("TMDB API에서 키워드 '{}'로 영화 목록 검색 시도.", keyword);

        String searchApiUrl = UriComponentsBuilder.fromHttpUrl(OMDB_BASE_URL)
                .queryParam("api_key", this.omdbSearchApiKey)
                .queryParam("query", keyword)
                .queryParam("language", "ko-KR")
                .build().toUriString();

        List<movie> moviesWithFullDetails = new ArrayList<>();
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
                            movie fullMovieDetail = getMovieFromApi(tmdbId); 
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

    // 상세 조회  (ID -> 상세 정보)
    public movie getMovieFromApi(String tmdbId) {
        String detailBaseUrl = "https://api.themoviedb.org/3/movie/";
        
        String apiUrl = UriComponentsBuilder.fromHttpUrl(detailBaseUrl + tmdbId)
                .queryParam("api_key", this.omdbSearchApiKey)
                .queryParam("language", "ko-KR")
                .build().toUriString();

        try {
            String jsonResponse = restTemplate.getForObject(apiUrl, String.class);
            JsonNode rootNode = objectMapper.readTree(jsonResponse);

            if (rootNode.has("title")) {
                movie movie = new movie();
                
                movie.setApiId(rootNode.has("id") ? rootNode.get("id").asText() : null);
                movie.setTitle(rootNode.has("title") ? rootNode.get("title").asText() : "N/A");
                
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
                    movie.setPosterPath("https://image.tmdb.org/t/p/w500" + posterPath);
                }

                // 런타임
                movie.setRuntime(rootNode.has("runtime") ? rootNode.get("runtime").asText() + "분" : "N/A");

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
}
